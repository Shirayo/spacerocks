extends RigidBody2D
var screen_size = Vector2.ZERO
signal test(position, rotation)

func _process(delta: float) -> void:
	pass

func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screen_size.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screen_size.y)
	physics_state.transform = xform
	test.emit(position, physics_state.transform.get_rotation())
