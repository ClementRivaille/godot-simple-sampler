extends Node2D
class_name SpatialSpeaker

@onready var sampler: Sampler = $Sampler

var note_idx := 0
var notes: Array[String] = ["C", "E", "G", "A"]

func play_note():
	var note := notes[note_idx]
	sampler.play_note(note)
	note_idx = (note_idx + 1) % notes.size()
