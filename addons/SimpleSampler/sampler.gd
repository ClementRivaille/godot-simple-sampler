extends AudioStreamPlayer
class_name Sampler

@export var samples: Array[NoteSample]

@export_group("Envelop", "env_")
@export var env_attack: float = -1.0
@export var env_sustain: float = -1.0
@export var env_release: float = -1.0

@onready var max_volume := volume_db
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
  samples.sort_custom(func(a: NoteSample, b: NoteSample): a.value < b.value)

  # Create sustain timer
  timer = Timer.new()
  add_child(timer)
  # Initialize with sustain
  if env_sustain > 0:
    timer.wait_time = env_sustain
    timer.one_shot = true;
    timer.connect("timeout", _end_sustain)

func play_note(note: String, octave: int = 4):
  if samples.size() == 0:
    return

  # look for the closest note in the samples
  var calculator: NoteValueCalculator = get_node("/root/NoteValue")
  var note_val := calculator.get_note_value(note, octave)
  var idx := 0
  var sample: NoteSample = samples[0]
  var diff := absi(note_val - sample.value)
  while (idx <  samples.size() - 1):
    sample = samples[idx+1]
    var next_diff := absi(note_val - sample.value)
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

  if env_attack > 0:
    volume_db = -50
    tween = create_tween()
    tween.tween_property(self, "volume_db", max_volume, env_attack
      ).set_trans(Tween.TRANS_SINE
      ).set_ease(Tween.EASE_OUT)
    tween.tween_callback(_end_attack)
    in_attack = true

  play(0.0)

  # If sustain is set with no atack, plan a release
  if (env_sustain > 0 && env_attack <= 0):
    timer.start()

# Stop the note with a release
func release():
  if playing && !in_release:
    if in_attack:
      tween.kill()
      in_attack = false
      _end_sustain(volume_db)
    else:
      _end_sustain()

func _end_attack():
  in_attack = false
  if (env_sustain >= 0):
    timer.start()

func _end_sustain(volume_from: float = max_volume):
  if playing:
    if env_release <= 0:
      stop()
    else:
      # Start release
      volume_db = volume_from
      tween = create_tween()
      tween.tween_property(self, "volume_db",
        -50, env_release
        ).set_trans(Tween.TRANS_SINE
        ).set_ease(Tween.EASE_IN_OUT)
      tween.tween_callback(_end_release)
      in_release = true

func _end_release():
  stop()
  in_release = false
  _reset_envelope()

# Reinitialize envelope tween & timer to prepare for the next note
func _reset_envelope():
  if !timer.is_stopped():
    timer.stop()
  if in_attack:
    # During or after attack, stop & disconnect tween
    tween.kill()
    in_attack = false
  if in_release:
    # During or after release, stop & disconnect tween
    tween.kill()
    in_release = false

  # Stop sound
  if playing:
    stop()

  # Reset volume
  if env_attack < 0:
    volume_db = max_volume
  else:
    volume_db = -50
