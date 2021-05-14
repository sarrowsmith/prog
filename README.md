# Prog
**Pro**cedural music **g**eneration. This is the source code repository; to download the app go to https://sarrowsmith.itch.io/prog

## Basic Requirements

 * [Godot](https://godotengine.org/) (obviously)
 * [Godot MIDI Player](https://godotengine.org/asset-library/asset/240)
 * A .sf2 soundfont as `res://recources/default-GM.sf2`. I'm bundling [General User Soundfont](http://www.schristiancollins.com/generaluser.php)

## Additional Requiremts For The Prog App

 * [AllSkyFree](https://godotengine.org/asset-library/asset/579) I've pulled out selected ones (see below), renamed them and put the rest under a `.gitignore`.
 * [Nova Square](https://fonts.google.com/specimen/Nova+Square) and [Nova Round](https://fonts.google.com/specimen/Nova+Round) fonts (in `res://resources`)

### Sky Selection

The `BackroundPicker` expects to be given a directory which contains the sky assets, which are named according to the convetion that if the name contains no `_` then this is one option with the sky inverted or the first option is the file name up to the first `_` which gives the sky as-is then the remained is an inverted option.

## Using In Your Own Project

 1. Make sure you have the Basic Requirements
 2. Clone or download this repo in whatever way works best for you
 3. You need the `ProgPlayer` directory in your project
 4. Instance a `RandomPlayer` node and give it a soundfont
 5. Use `Main.gd` as a guide for how to drive it. Basically, call `create(rng_seed: int, parameters: Dictionary, sections: enum)` to create a track, then `play_next()` to play and `stop()` to stop.

### Sections

The `sections` parameter to `RandomPlayer.create()` can be `RandomPlayer.SINGLE`, `RandomPlayer.AUTO`, `RandomPlayer.ENDLESS` or `RandomPlayer.LOOP`:

`SINGLE`: One section of at least `parameters.Length` bars

`AUTO`: Up to four sections, totalling at least `parameters.Length` bars, with parameters automatically adjusted between sections

`ENDLESS`: An endless stream of sections, each one at least `parameters.Length` bars long, with parameters *including `Length`* randomly adjusted between sections

`LOOP`: An endless stream of sections, each one at least `parameters.Length` bars long, all using the given parameters

An `ENDLESS` or `LOOP` stream can be switched to a new set of parameters by calling `create()` again. The new values will be automatically switched in at the end of the current section. (At least, that's the intended opeation. I've not tested it yet.) Or you can call `random_next()` on a `LOOP` stream which will do an `ENDLESS`-style random adjustment at the end of the current section. (This is what "Next" in the app does.)

Calling `end_next()` while playing an `ENDLESS` or `LOOP` stream will queue a final, half-length, section after which the stream will stop. (This is what "Last" in the app does.)

### Signals

`RandomPlayer` emits `finished` when it's finished playing. It sets up its `midi_player` to emit `appeared_instrument` for each instrument it uses and to signal key changes, and `appeared_cue_point` on each note. Both of these signals from `midi_player` send a string which consists of four `:`-separated integers, the first of which is the track number (0--15) and the rest are:

`appeared_instrument`: instrument (0--128, 0 = track silenced), mode (0--6, an index into `RandomPlayer.Modes`), key (0--11 = C--B)

`appeared_cue_point`: pitch, duration, volume (MIDI values)

`appeared_cue_point` is also sent with a track of -1 to signal the downbeat of each bar.

### Parameters

Basically,
```
var parameters = RandomPlayer.Randomizable.duplicate()
for parameter in parameters:
    var limits = RandomPlayer.Randomizable[paramater]
    parameters[parameter] = # a value between limits[0] and limits[1] inclusive
```
