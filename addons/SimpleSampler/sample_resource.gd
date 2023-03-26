extends Resource
class_name NoteSample

@export var stream: AudioStream
@export_enum("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B") var tone: String = "C"
@export var octave : int = 4

var value: int

func initValue(calculator: NoteValueCalculator):
  value = calculator.get_note_value(tone, octave)
