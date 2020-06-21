extends Resource
class_name NoteSample

# warning-ignore:unused_class_variable
export(AudioStream) var stream: AudioStream
export(String, "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B") var tone: String = "C"
export(int) var octave := 4

var value: int

func initValue(calculator: NoteValueCalculator):
  value = calculator.get_note_value(tone, octave)
