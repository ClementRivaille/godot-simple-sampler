extends Node2D

# Hi! This script is a good demo of what you can do with Simple Sampler, and how it works

# Each button in the demo corresponds to a single sampler. Check out their settings in the scene.
@onready var basicSampler : Sampler = $Sampler
@onready var chordSampler : SamplerInstrument = $SamplerInstrument
@onready var samplerInstrument : SamplerInstrument = $SamplerInstrument2
@onready var envSampler : Sampler = $EnvSampler
@onready var glidingChordSampler: SamplerInstrument = $GlidingChordSampler

# Here are the notes that we play in the scene. You can edit them to hear the result.
@export var notes : Array[String] = ["C", "E", "G", "B"]

# (don't mind this dirty logic, it's just here to make the scene work without hassle)
var index0 := 0
var index1 := 0
var index2 := 0
var gliding := false

# To play a note with a sampler, just use the method "play_note" with the name of the note and its octave.
# Example : play_note("C", 4)
func playBasicSampler():
	var note: String = notes[index0]
	basicSampler.play_note(note, 4)
	index0 = (index0 + 1)%notes.size()

# Playing several notes at the same time with a SamplerInstrument
# is made just by calling "play_note" for each notes! Easy!
func playChord():
	chordSampler.play_note("C", 4)
	chordSampler.play_note("E", 4)
	chordSampler.play_note("G", 4)
	chordSampler.play_note("B", 4)

# Not much diff than from above, except that since we use a SamplerInstrument,
# notes will play on top of each other instead of being replaced.
# Useful if you have long delay or reverb.
func playMultiSampler():
	var note: String = notes[index1]
	# Also, the octave parameter of play_note is optional! Its default value is 4.
	samplerInstrument.play_note(note)
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
	gliding = false

# When a SamplerInstrument is playing several notes "release" will release all notes currently playing.

###
# Gliding
###

# When a sustained sampler is playing, you can glide its note to a target value

# We use a bit of logic with a timer to glide every one second
@onready var timer :Timer = $Timer
func on_timemout():
	if gliding:
		glideNote()
		glideChord()

@export var glide_duration := 0.2

# We start the sampler normally
func startGliding():
	playEnvSampler()
	gliding = true
# Then to glide, we provide a target note and octave, as well as a duration
func glideNote():
	var note: String = notes[index2]
	envSampler.glide(note, 4, glide_duration)
	index2 = (index2 + 1)%notes.size()

# Since gliding only updates the pitch of the same stream, it produces a odd sound
# Ideal for synth or theremins!

# You can also glide chords with a SamplerInstrument
var chords : Array[Array] = [
	['C', 'E', 'G'],
	['C', 'F', 'A'],
	['D', 'G', 'B'],
	['D', 'F', 'B']
]
var chord_idx := 0

# Just like above, we call play_note for each note in the chord
func startGlideChord():
	var chord := chords[chord_idx]
	for note in chord:
		glidingChordSampler.play_note(note)
	chord_idx = (chord_idx + 1)%chords.size()
	gliding = true
# Use chord_glide to glide notes in the order they were played
func glideChord():
	var chord := chords[chord_idx]
	for note in chord:
		glidingChordSampler.chord_glide(note, 4, glide_duration)
	chord_idx = (chord_idx + 1)%chords.size()

func releaseChordGlide():
	glidingChordSampler.release()
	gliding = false

##
# Rich instrument
##

# Instruments can use several samples for the same note, providing a richer sound

# Guitar has 4 different samples for each note, as well as 3 levels of velocity
# (see its samples settings in the scene)
@onready var guitar: SamplerInstrument = $Guitar

var gindex := 0
# Here we use 3 for piano, 5 for mezzo, and 7 for forte
var g_velocity := 5

# When a note is played, a random sample of the matching velocity is selected
func playGuitar():
	var note := notes[gindex]
	# Velocity is passed as the third argument (default is 5)
	guitar.play_note(note, 4, g_velocity)
	gindex = (gindex+1)%notes.size()


# Callback for the selection menu
func onSelectVelocity(velocity: int) -> void:
	g_velocity = velocity
