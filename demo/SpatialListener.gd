extends Node2D
class_name SpatialListener

@export var locked := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if locked:
		return

	var cursor_pos := get_viewport().get_mouse_position()
	var pos := Vector2(cursor_pos.x - get_viewport_rect().size.x / 2,
		cursor_pos.y - get_viewport_rect().size.y / 2)
	set_global_position(pos)
