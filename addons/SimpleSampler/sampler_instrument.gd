@icon("multisampler_icon.png")
extends Sampler
class_name SamplerInstrument

## Audio instrument using samples to play notes [br][br]
## [url=https://github.com/ClementRivaille/godot-simple-sampler?tab=readme-ov-file#simple-sampler]Documentation[/url]

## Maximum of simultaneous notes allowed
@export var max_notes: int = 4

var samplers : Array[Sampler] = []
var next_available := 0
var last_sampler_used: Sampler

func _ready():
	# Create samplers
	# warning-ignore:unused_variable
	for i in range(max_notes):
		var sampler := _build_sampler()

		add_child(sampler)
		samplers.append(sampler)

func play_note(note: String, octave: int = 4, velocity: int = 5):
	# Call one of the sampler to play the note
	var sampler: Sampler = samplers[next_available]
	sampler.play_note(note, octave, velocity)
	next_available = (next_available + 1) % max_notes
	last_sampler_used = sampler

func stop():
	for s in samplers:
		var sampler: Sampler = s
		sampler.stop()

func release():
	for s in samplers:
		var sampler: Sampler = s
		sampler.release()

func glide(note: String, octave: int = 4, duration: float = 0.1):
	if (last_sampler_used != null && last_sampler_used.playing):
		last_sampler_used.glide(note, octave, duration)

## Glide a note within a chord.
## Will glide the first available playing note that is not already gliding.
func chord_glide(note: String, octave: int = 4, duration: float = 0.1):
	# Order samplers from least to most recent play
	var ordered_samplers: Array[Sampler] = samplers.duplicate()
	for idx in range(next_available):
		ordered_samplers.append(ordered_samplers.pop_front())
	# Pick a playing sampler
	var sampler := ordered_samplers[0]
	var idx := 0
	while (idx < ordered_samplers.size() - 1 && !_can_glide(sampler)):
		idx += 1
		sampler = ordered_samplers[idx]

	# Glide
	if (_can_glide(sampler)):
		sampler.glide(note, octave, duration)

func _can_glide(s: Sampler) -> bool:
	return s.playing && !s.in_release && !(s.glissando != null && s.glissando.is_running())

func _build_sampler() -> Sampler:
	var sampler := Sampler.new()
	sampler.samples = samples
	sampler.env_attack = env_attack
	sampler.env_sustain = env_sustain
	sampler.env_release = env_release
	sampler.volume_db = volume_db
	sampler.bus = bus
	## COPY_SAMPLER_2D: _copy_player2D_properties(self, sampler)
	## COPY_SAMPLER_3D: _copy_player3D_properties(self, sampler)

	return sampler

func _copy_player2D_properties(from: AudioStreamPlayer2D, to: AudioStreamPlayer2D):
	to.max_distance = from.max_distance
	to.attenuation = from.attenuation
	to.panning_strength = from.panning_strength
	to.area_mask = from.area_mask

func _copy_player3D_properties(from: AudioStreamPlayer3D, to: AudioStreamPlayer3D):
	to.max_distance = from.max_distance
	to.panning_strength = from.panning_strength
	to.area_mask = from.area_mask
	to.attenuation_filter_cutoff_hz = from.attenuation_filter_cutoff_hz
	to.attenuation_filter_db = from.attenuation_filter_db
	to.attenuation_model = from.attenuation_model
	to.doppler_tracking = from.doppler_tracking
	to.emission_angle_degrees = from.emission_angle_degrees
	to.emission_angle_enabled = from.emission_angle_enabled
	to.emission_angle_filter_attenuation_db = from.emission_angle_filter_attenuation_db
	to.max_db = from.max_db
	to.unit_size = from.unit_size
