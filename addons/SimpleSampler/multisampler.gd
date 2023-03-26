extends Sampler
class_name Multisampler

@export var max_notes: int = 1

var samplers : Array[Sampler] = []
var next_available := 0

func _ready():
  # Create samplers
  # warning-ignore:unused_variable
  for i in range(max_notes):
    var sampler := Sampler.new()
    sampler.samples = samples
    sampler.env_attack = env_attack
    sampler.env_sustain = env_sustain
    sampler.env_release = env_release
    sampler.volume_db = volume_db
    sampler.bus = bus

    add_child(sampler)
    samplers.append(sampler)

func play_note(note: String, octave: int = 4):
  # Call one of the sampler to play the note
  var sampler: Sampler = samplers[next_available]
  sampler.play_note(note, octave)
  next_available = (next_available + 1) % max_notes

func stop():
  for s in samplers:
    var sampler: Sampler = s
    sampler.stop()

# Stop the note with a release
func release():
  for s in samplers:
    var sampler: Sampler = s
    sampler.release()
