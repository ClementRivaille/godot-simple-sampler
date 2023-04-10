@icon("sampler_icon.png")
extends AudioStreamPlayer
class_name Sampler

## Audio instrument playing single notes
##
## For playing several simultaneous notes, use Multisampler instead

## List of audio samples from which to generate notes
@export var samples: Array[NoteSample]

@export_group("Envelop", "env_")
## Attack in secondes
@export var env_attack: float = -1.0
## Sustain in seconds
@export var env_sustain: float = -1.0
## Release in secondes
@export var env_release: float = -1.0

@onready var max_volume := volume_db
var tween: Tween
var timer: Timer;

var in_attack := false
var in_release := false

# Used for gliding
var playing_sample: NoteSample
var playing_note_value: int
var glissando: Tween

func _ready():
  # Calculate samples' values and sort them
  var calculator: NoteValueCalculator = get_node("/root/NoteValue")
  for s in samples:
    var sample: NoteSample = s
    sample.initValue(calculator)
  samples.sort_custom(func(a: NoteSample, b: NoteSample): return a.value < b.value)

  # Create sustain timer
  timer = Timer.new()
  add_child(timer)
  # Initialize with sustain
  if env_sustain > 0:
    timer.wait_time = env_sustain
    timer.one_shot = true;
    timer.connect("timeout", _end_sustain)

func play_note(note: String, octave: int = 4, velocity : int = 5):
  # play only samples matching velocity
  var matching_samples: Array[NoteSample] = samples.filter(
    func(sample: NoteSample): return sample.velocity == velocity
  )
  if matching_samples.size() == 0:
    return

  # look for the closest notes in the samples
  var calculator: NoteValueCalculator = get_node("/root/NoteValue")
  var note_val := calculator.get_note_value(note, octave)
  playing_note_value = note_val  
  var idx := 0
  var closest_samples: Array[NoteSample] = []
  var diff := absi(note_val - matching_samples[0].value)
  while (idx <  matching_samples.size()):
    var sample := matching_samples[idx]
    var next_diff := absi(note_val - sample.value)
    # if note is closer
    if (next_diff < diff):
      diff = next_diff
      closest_samples.clear()
      closest_samples.append(sample)
    # if note is equal
    elif (next_diff == diff):
      closest_samples.append(sample)
    # if note is further (stop searching)
    else:
      break
    idx += 1

  # Pick one of the close samples
  playing_sample = closest_samples[randi()%closest_samples.size()]
  stream = playing_sample.stream

  # Set pitch relatively to sample
  pitch_scale = pow(2, (note_val - playing_sample.value) / 12.0)

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
      
## When a note is playing, progressively change its pitch to the target
func glide(note: String, octave: int = 4, duration: float = 0.1):
  if glissando != null && glissando.is_running():
    glissando.kill()
  if playing:
    var calculator: NoteValueCalculator = get_node("/root/NoteValue")
    var note_val := calculator.get_note_value(note, octave)
    playing_note_value = note_val
    var new_pitch = pow(2, (note_val - playing_sample.value) / 12.0)
    glissando = create_tween()
    glissando.tween_property(self, "pitch_scale", new_pitch, duration
      ).set_trans(Tween.TRANS_SINE
      ).set_ease(Tween.EASE_IN_OUT)

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
  if glissando != null && glissando.is_running():
    glissando.kill()
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
