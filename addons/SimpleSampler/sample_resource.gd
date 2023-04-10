extends Resource
class_name NoteSample

## Sound sample for a single note
##
## Provides a sound file associated to its corresponding note

## Sound file or source
@export var stream: AudioStream
## Corresponding note
@export_enum("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B") var tone: String = "C"
## Corresponding octave
@export var octave : int = 4
## Velocity
@export_range(0, 10) var velocity : int = 5

var value: int

func initValue(calculator: NoteValueCalculator):
  value = calculator.get_note_value(tone, octave)
