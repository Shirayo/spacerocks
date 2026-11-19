extends Node2D
@export var rock_scene : PackedScene
var screen_size = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	for i in 2:
		spawn_rock(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_rock(size, pos=null, vel=null):
	if pos == null:
		$RockPath/RockSpawn.progress = randi()
		pos = $RockPath/RockSpawn.position
		print("position:", pos)
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	var r = rock_scene.instantiate()
	r.screen_size = screen_size
	r.start(pos, vel, size)
	r.exploded.connect(self._on_rock_exploded)
	call_deferred("add_child", r)
	
func _on_rock_exploded(size, radius, pos, vel):
	print("size of destroyed rock: ", size)
	if size == 1:
		return
	for offset in [-1, 1]:
		var dir = $Player.position.direction_to(pos).orthogonal() * offset #единичный вектор
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newpos, newvel)
	
