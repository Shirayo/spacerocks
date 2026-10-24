extends Node2D


var screen_size = Vector2.ZERO

@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene: PackedScene
@export var fire_rate = 0.25

var canShoot = true
var thrust = Vector2.ZERO
var rotation_dir = 0

enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = INIT
var shipSprites: Array[Sprite2D] = []
# Called when the node enters the scene tree for the first time.\

func _ready() -> void:
	$GunCooldown.wait_time = fire_rate
	screen_size = get_viewport_rect().size
	$RigidBody2D.screen_size = screen_size
	change_state(ALIVE) #debug?
	setShips()
	pass # Replace with function body.

func setShips():
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			var ship = $RigidBody2D/Sprite2D.duplicate() as Sprite2D
			ship.transform.origin.x = randi_range(10, 1000)
			shipSprites.append(ship)
			add_child(ship)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_input()
	setShipPositions()
	pass


func change_state(new_state):
	state = new_state
	match new_state:
		INIT:
			$RigidBody2D/CollisionShape2D.set_deferred("disabled", true)
		ALIVE:
			$RigidBody2D/CollisionShape2D.set_deferred("disabled", false)
		INVULNERABLE:
			$RigidBody2D/CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$RigidBody2D/CollisionShape2D.set_deferred("disabled", true)

func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	
	if Input.is_action_pressed("thrust"):
		thrust = $RigidBody2D.transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	
	if Input.is_action_just_pressed("shoot") and canShoot:
		shoot()

func shoot(): 
	if state == INVULNERABLE:
		return
	canShoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($RigidBody2D/Muzzle.global_transform)	

func _physics_process(delta: float) -> void:
	$RigidBody2D.constant_force = thrust
	$RigidBody2D.constant_torque = rotation_dir * spin_power

func _on_gun_cooldown_timeout() -> void:
	canShoot = true

func setShipPositions():
	var counter = 0
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			shipSprites[counter].global_transform = ($RigidBody2D/Sprite2D.global_transform).translated(screen_size * Vector2(i, j))
			counter += 1
