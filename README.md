# Prog
**Pro**cedural music **g**eneration

## Basic Requirements

 * [Godot](https://godotengine.org/) (obviously)
 * [Godot MIDI Player](https://godotengine.org/asset-library/asset/240)
 * A .sf2 soundfont as `res://recources/default-GM.sf2`. I'm bundling [General User Soundfont](http://www.schristiancollins.com/generaluser.php)

## Additional Requiremts For The Prog App

 * [AllSkyFree](https://godotengine.org/asset-library/asset/579) I've pulled out Epic Glorious Pink `res://resources/AllSkyFree/Epic_GloriousPink.png` and put the rest under a `.gitignore`.
 * [Nova Square](https://fonts.google.com/specimen/Nova+Square) and [Nova Round](https://fonts.google.com/specimen/Nova+Round) fonts (in `res://resources`)

## Using In Your Own Project

 1. Make sure you have the Basic Requirements
 2. Clone or download this repo in whatever way works best for you
 3. You need the `ProgPlayer` directory in your project
 4. Instance a `RandomPlayer` node and give it a soundfont
 5. Use `Main.gd` as a guide for how to drive it. Basically, call `create(rng_seed: int, parameters: Dictionary)` to create a track, then `play_next()` to play and `stop()` to stop.

### Parameters

### Signals
