# Simple Sampler

_Simple Sampler_ is a plugin for Godot for creating musical samplers in a game. Basically it allows you to play any musical note from a set of sound samples. Useful for making generative, interactive or procedural music, or for creating dynamic sound effects!

The repository includes a small demo that showcases what the plugin allows to do. Check out its scene and source code to quickly see how to use the samplers!

## Installing

Copy the `addons/SimpleSampler` folder and put it in your project at the path `addons/SimplerSampler`. Then open _Project > Project Settings_ and go to the _Plugins_ tab. You should see the plugin Simple Sampler in the list. Activate it to use it in your project.

## Usage

### Basics

_SimpleSampler_ gives you access to two new Nodes: **Sampler Instrument** and **Sampler**. For most of your projects, you should use _Sampler Instrument_, as it allows to play several notes simultaneously. But if you know that it won't be the case, Sampler might slightly lighter. Both nodes share the same methods.

![Add new sampler](doc/add-sampler.png)

Samplers are musical instruments that take several sound samples as input, and can then play any note by calculating the sample to play and the pitch to apply.

To configure a Sampler, you need to register its note samples. For this, you must provide your own sound files (see the section below to know where you can find some). Each file must correspond to a single note. Of course, you don't need to have a file for every possible note (that would be too heavy)! Usually, having three samples per octave gives great results. Files can be single sounds, or loops, depending on how you import them. Samplers work well with .wav or .ogg!

Once you have your samples, you must add them to the Sampler, in the _samples_ array. _Simple Sampler_ provides a Resource to manage samples: **NoteSample**. Add one of them for each sample files you have.

For each sample, you must enter 3 properties:

- The sound file (Stream)
- Corresponding note (Tone)
- Corresponding octave (Octave)

![Configure samples](doc/sample-config.png)

You must do this for every samples. The order you put them in the array doesn't matter. If you want to go faster, you can save NoteSample as resources. This allows you to use them elsewhere!

Once you have done that, your sampler is ready to use! To play a note, just call the function `play_note` with the note name (in uppercase) and the octave.

```
sampler.play_note("C", 4)
```

And that's it!

Also note that samplers are based on _AudioStreamPlayers_. Which means that you can set their volume or connect them to an audio bus just like any AudioStreamPlayer.

:warning: Don't edit their volume or runtime though, as it is used by the sampler's envelop. Use a bus instead for these kind of dynamic effects.

If your sample is played on a loop, and you want to stop it, call the `release` method:

```
sampler.release()
```

### Polyphony

As said above, SamplerInstruments are able to play several notes at the same time. This is useful for playing chords, but also for overlapping notes with long reverb or delay!

The number of simultaneous note possible is not infinite though. The limit must be set on the parameter _Max Notes_. If you go beyond that number, the first note played will be replaced.

To play a chord, simply call `play_note` several time:

```(gdscript)
# C minor 7
sampler.play_note("C")
sampler.play_note("Eb")
sampler.play_note("G")
sampler.play_note("A#")
# When omitting the octave parameter, the default value is 4
```

Calling `release` will release every currently playing note.

### Envelop

_Sampler_ and _SamplerInstrument_ have a simplified sound envelop system to customize the sound of the instrument. It consists of three parameters: _Attack_, _Sustain_ and _Release_. Their default value is -1, meaning that they are not active.

- _Attack_ is the length (in seconds) of a fade-in at the beginning of the sound. If negative, the sound will play immediately at its default volume.
- _Sustain_ is the length (in seconds) of the sound after the attack. Once this delay is passed, it will automatically call `release`. If negative, the sound will play entirely or in loop.
- _Release_ is the length (in seconds) of a fade-out once `release` has been called, either manually or after the sustain. If negative, the sound will stop immediately.

You can use those to have more dynamic instruments (with looping sounds), or if you find the length of your sample too long (using _sustain_ and _release_ allows you to interrupt it earlier).

### Velocity and richer sound

Some instruments, especially acoustic ones, have a large array of possible sounds. They can play short notes, long ones, pizzicato, forte, piano… Some VST provide a lot of samples for the same notes, allowing the instrument to sound more organic. Simple Sampler offer some utilities to configure richer instrument in such a way.

You can set a velocity value on an instrument sample. It is an integer value that goes from 0 to 10 (default is 5). When you play a note, you can specify the desired velocity, and the matching sample will be played.

```(gdscript)
# Play piano
sampler.play_note("C", 4, 3)

# Play forte
sampler.play_note("C", 4, 7)
```

:warning: **Warning:** You have to provide the exact same value that you set on the sample. If no sample matches the velocity, no sound will be played.

You can also configure several samples for the same note. This way, when this note will be played (or a close one), the sample will be randomly chosen among them. This can be useful to make an instrument feel more alive!

### Gliding

You can create a glissando effect by gliding a sustained note from one value to another. This allows you to mimic the sound of some analog instruments, like musical saw or theremin. To do so, when a note is already being played and sustained, use the `glide` function with the target note and the glide duration in seconds.

```(gdscript)
sampler.glide("G", 4, 0.3)
```

Note that gliding keeps the same stream played and only change its pitch. It can produces odd sounds if you stretch it too far!

On SamplerInstrument, when several notes are being played simultaneously, `glide` will only change the last played one. However, this might not be the ideal behavior if you want to glide entire chords. To do so, use the `chord_glide` function. This will glide the notes _in the same order you initially played them_. Thus allowing more complex transitions between one chord and another.

```(gdscript)
func play_chord():
  sampler.play("D", 4)
  sampler.play("G", 4)
  sampler.play("B", 4)

func shift_chord():
  sampler.chord_glide("E", 4, 0.2)
  sampler.chord_glide("G", 4, 0.2) # Will stay on G
  sampler.chord_glide("C", 5, 0.2)
```

### Note Value Calculator

For a more advanced use, you can access the class _NoteValueValculator_ used by the samplers:

```
var calculator: NoteValueCalculator = get_node("/root/NoteValue")
```

This tool converts notes into number values, and reciprocally. It can be useful if you want to do some arithmetic manipulation with the notes! Here are the functions it provides:

- `get_note_value(note: String, octave: int = 4) -> int` returns the value of a note, where C0 is 0.
- `get_note_name(value: int) -> String` returns the name of a note given its value
- `get_note_octave(value: int) -> int` returns the octace of a note given its value

Those tools come in handy if you want to make procedural music based on mathematics and music theory!

## Where can I find samples?

There are multiple places on the web where you can find audio samples for all kind of instruments. Here are some websites that provides free samples of great quality:

- **[Philarmonia Orchestra](https://philharmonia.co.uk/resources/sound-samples/) :** A collection of samples from the Philarmonia Orchestra's instruments. Comes with several length and variations (piano, forte, pizzicato, etc…)
- **[FreePats project](http://freepats.zenvoid.org/index.html) :** A bank of free virtual instruments. A lot of them are available in the _SFZ_ format, meaning you have access to the WAV files.
- **[Karoryfer lecolds](https://www.karoryfer.com/karoryfer-samples) :** A libray of sampled instruments. Most of them are not free, but you can still find some good ones at the end of the page that are under Creative Commons License.

There are surely plenty other places where you can find or purchase great sound samples. You can also make your own! As you've seen, you don't actually need a lot of them to make a sampler. So you can use the musical tool of your choice, play a bunch of notes, and make your own sample files!

Also, you can save and share your own samplers between projects (or even users!), either by saving _NoteSample_ resources, or a Godot scene with a _Sampler_ or _SamplerInstrument_ as root.
