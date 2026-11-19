extends RigidBody2D
signal exploded(size, radius, position, linear_velocity)
var screen_size = Vector2.ZERO
var size
var radius
var scale_factor = 0.2
var mass_factor = 1.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start(_position, _velocity, _size):
	position = _position
	size = _size
	mass = mass_factor * size
	$Sprite2D.scale = Vector2.ONE * scale_factor * size
	radius = int($Sprite2D.texture.get_size().x / 2 * $Sprite2D.scale.x)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)
	$Explosion.scale = Vector2.ONE * 0.75 * size

func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screen_size.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screen_size.y + radius)
	physics_state.transform = xform

func explode():
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Explosion/AnimationPlayer.play("explosion")
	$Explosion.show()
	exploded.emit(size, radius, position, linear_velocity)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	await  $Explosion/AnimationPlayer.animation_finished
	queue_free()
