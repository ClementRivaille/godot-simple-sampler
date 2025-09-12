extends Node2D
class_name SpatialSpeaker

@export var moving := false

@onready var sampler: Sampler = $Sampler

var note_idx := 0
var notes: Array[String] = ["C", "E", "G", "A"]

func play_note():
	var note := notes[note_idx]
	sampler.play_note(note)
	note_idx = (note_idx + 1) % notes.size()

func _process(delta: float) -> void:
	if !moving:
		return

	var cursor_pos := get_viewport().get_mouse_position()
	var pos := Vector2(cursor_pos.x - get_viewport().size.x / 2,
		cursor_pos.y - get_viewport().size.y / 2)
	set_global_position(pos)
