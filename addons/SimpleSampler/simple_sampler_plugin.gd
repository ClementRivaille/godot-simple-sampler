@tool
extends EditorPlugin

var ADDON_PATH := "res://addons/SimpleSampler"

func _enter_tree():
	# Add Common types & singleton
	add_custom_type(
		"NoteSample",
		"Resource",
		preload("sample_resource.gd"),
		preload("sample_icon.png")
	)
	add_autoload_singleton("NoteValue", ADDON_PATH.path_join("note_value.gd"))

	## Add basic sampler
	add_custom_type(
		"SamplerInstrument",
		"AudioStreamPlayer",
		preload("sampler_instrument.gd"),
		preload("multisampler_icon.png")
	)

	# Add Samplers for spatial 2D & 3D
	add_custom_type("SamplerInstrument2D", "AudioStreamPlayer2D", preload("sampler_instrument_2D.gd"), preload("multisampler_icon.png"))
	add_custom_type("SamplerInstrument3D", "AudioStreamPlayer3D", preload("sampler_instrument_3D.gd"), preload("multisampler_icon.png"))

func _exit_tree():
	remove_custom_type("NoteSample")
	remove_custom_type("SamplerInstrument")
	remove_custom_type("SamplerInstrument2D")
	remove_custom_type("SamplerInstrument3D")
	remove_autoload_singleton("NoteValue")
