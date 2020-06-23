extends Sampler
class_name Multisampler

export(int) var max_notes:= 1

var samplers := []
var next_available = 0

func _ready():
  # Create samplers
  # warning-ignore:unused_variable
  for i in range(max_notes):
    var sampler := Sampler.new()
    sampler.samples = samples
    sampler.attack = attack
    sampler.sustain = sustain
    sampler.release = release
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
