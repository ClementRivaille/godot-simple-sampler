extends Node2D
class_name SpatialListener

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cursor_pos := get_viewport().get_mouse_position()
	var pos := Vector2(cursor_pos.x - get_viewport().size.x / 2,
		cursor_pos.y - get_viewport().size.y / 2)
	set_global_position(pos)
