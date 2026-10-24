extends RigidBody2D


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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GunCooldown.wait_time = fire_rate
	screen_size = get_viewport_rect().size
	change_state(ALIVE) #debug?
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_input()
	pass

func change_state(new_state):
	state = new_state
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)

func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
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
	b.start($Muzzle.global_transform)	

func _physics_process(delta: float) -> void:
	constant_force = thrust
	constant_torque = rotation_dir * spin_power

func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screen_size.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screen_size.y)
	physics_state.transform = xform


func _on_gun_cooldown_timeout() -> void:
	canShoot = true
