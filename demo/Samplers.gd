extends Node2D

# Hi! This script is a good demo of what you can do with Simple Sampler, and how it works

# Each button in the demo corresponds to a single sampler. Check out their settings in the scene.
onready var basicSampler : Sampler = $Sampler
onready var chordSampler : Multisampler = $Multisampler
onready var multisampler : Multisampler = $Multisampler2
onready var envSampler : Sampler = $EnvSampler

# Here are the notes that we play in the scene. You can edit them to hear the result.
var notes := ["C", "E", "G", "B"]

# (don't mind this dirty logic, it's just here to make the scene work without hassle)
var index0 := 0
var index1 := 0
var index2 := 0

# To play a note with a sampler, just use the method "play_note" with the name of the note and its octave.
# Example : play_note("C", 4)
func playBasicSampler():
  var note: String = notes[index0]
  basicSampler.play_note(note, 4)
  index0 = (index0 + 1)%notes.size()

# Playing several notes at the same time with a multisampler
# is made just by calling "play_note" for each notes! Easy!
func playChord():
  chordSampler.play_note("C", 4)
  chordSampler.play_note("E", 4)
  chordSampler.play_note("G", 4)
  chordSampler.play_note("B", 4)

# Not much diff than from above, except that since we use a Multisampler,
# notes will play on top of each other instead of being replaced.
# Useful if you have long delay or reverb.
func playMultiSampler():
  var note: String = notes[index1]
  # Also, the octave parameter of play_note is optional! Its default value is 4.
  multisampler.play_note(note)
  index1 = (index1 + 1)%notes.size()

# Again, that's exactly the same code from above!
# Except that the note will play on loop instead of once, because the ogg file has been imported so
func playEnvSampler():
  var note: String = notes[index2]
  envSampler.play_note(note, 4)
  index2 = (index2 + 1)%notes.size()
  
# Check out the envSampler setting in the scene:
# It has an attack of 0.3, meaning that there will be a fade in at the start
# Its sustain is still -1 in order to let it loop ; but if you set it to a positive value, the note will automatically release after this delay
# Finally, the release is 1, which means it will fade out for 1 second before stopping

# To manually release a note, just use the "release" function
func releaseEnvSampler():
  envSampler.release()
  
# This works exactly the same for a multisampler. "release" will release all notes currently playing.
# Also, MultiSampler inherits from Sampler, and has the same methods. So you can use it as a Sampler if you need to!
