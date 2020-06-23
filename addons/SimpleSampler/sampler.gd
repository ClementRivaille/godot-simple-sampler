extends AudioStreamPlayer
class_name Sampler

export(Array, AudioStreamSample) var samples: Array

export(float) var attack := -1.0
export(float) var sustain := -1.0
export(float) var release := -1.0

onready var max_volume := volume_db
var tween: Tween
var timer: Timer;

var in_attack := false
var in_release := false

func _ready():
  # Calculate samples' values and sort them
  var calculator: NoteValueCalculator = get_node("/root/NoteValue")
  for s in samples:
    var sample: NoteSample = s
    sample.initValue(calculator)
  samples.sort_custom(self, "_compare_samples")

  # Create tween & timer for sustain and release
  tween = Tween.new()
  add_child(tween)
  timer = Timer.new()
  add_child(timer)
  # Initialize with sustain
  if sustain > 0:
    timer.wait_time = sustain
    timer.one_shot = true;
    timer.connect("timeout", self, "_end_sustain")

func play_note(note: String, octave: int = 4):
  if samples.size() == 0:
    return

  # look for the closest note in the samples
  var calculator: NoteValueCalculator = get_node("/root/NoteValue")
  var note_val := calculator.get_note_value(note, octave)
  var idx := 0
  var sample: NoteSample = samples[0]
  var diff := abs(note_val - sample.value)
  while (idx <  samples.size() - 1):
    sample = samples[idx+1]
    var next_diff := abs(note_val - sample.value)
    if (diff < next_diff):
      break
    diff = next_diff
    idx += 1

  # Set sample
  sample = samples[idx]
  stream = sample.stream

  # Set pitch relatively to sample
  pitch_scale = pow(2, (note_val - sample.value) / 12.0)

  _reset_envelope()

  if attack > 0:
    tween.interpolate_property(self, "volume_db",
      -50, max_volume,
      attack, Tween.TRANS_SINE, Tween.EASE_OUT)
    tween.connect("tween_completed", self, "_end_attack")
    in_attack = true
    tween.start()

  play(0.0)

  # If sustain is set with no atack, plan a release
  if (sustain > 0 && attack <= 0):
    timer.start()

# Stop the note with a release
func release():
  if playing && !in_release:
    if in_attack:
      tween.remove_all()
      tween.disconnect("tween_completed", self, "_end_attack")
      in_attack = false
      _end_sustain(volume_db)
    else:
      _end_sustain()

func _compare_samples(a: NoteSample, b: NoteSample):
  return a.value < b.value

func _end_attack(_object: Object, _path: NodePath):
  in_attack = false
  tween.disconnect("tween_completed", self, "_end_attack")
  if (sustain >= 0):
    timer.start()

func _end_sustain(volume_from: float = max_volume):
  if playing:
    if release <= 0:
      stop()
    else:
      # Start release
      tween.interpolate_property(self, "volume_db",
        volume_from, -50,
        release, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
      tween.connect("tween_completed", self, "_end_release")
      in_release = true
      tween.start()

func _end_release(_object: Object, _path: NodePath):
  stop()
  in_release = false
  tween.disconnect("tween_completed", self, "_end_release")
  _reset_envelope()

# Reinitialize envelope tween & timer to prepare for the next note
func _reset_envelope():
  if !timer.is_stopped():
    timer.stop()
  if in_attack:
    # During or after attack, stop & disconnect tween
    tween.remove_all()
    tween.disconnect("tween_completed", self, "_end_attack")
    in_attack = false
  if in_release:
    # During or after release, stop & disconnect tween
    tween.remove_all()
    tween.disconnect("tween_completed", self, "_end_release")
    in_release = false

  # Stop sound
  if playing:
    stop()

  # Reset volume
  if attack < 0:
    volume_db = max_volume
  else:
    volume_db = -50
