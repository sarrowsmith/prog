class_name Structure


# track to octave, using tracks for:
enum {CHORDS, DRONE, BASS, MELODY, HARMONY, RHYTHM, PERCUSSION, COUNTER, DESCANT, DRUMS, OTHER}
const Tracks = ["Chords", "Drone", "Bass", "Melody", "Harmony", "Rhythm", "Percussion", "Alto", "Descant", "Drums"]
const Octaves = [4, 3, 3, 5, 5, 4, 5, 6, 7, 5, 5]
const Overrides = {BASS: 4, COUNTER: 5, DESCANT: 6}

const Loops = [
	[1, 3, 5, 4],
	[1, 5, 4, 6],
	[1, 3, 7, 2],
	[1, 9, 5, 4],
	[1, 4, 5, 9],
	[1, 6, 4, 5],
]

static func styles() -> Array:
	return ["Random", "Mixed", "Chaotic"] + Banks.Presets.keys()


static func track_name(track: int) -> String:
	if track < OTHER:
		return Tracks[track]
	return "Additional %d" % (track + 1 - OTHER)


static func get_octave(style: String, track: int) -> int:
	var octave = Octaves[min(track, DRUMS)]
	match style:
		"Orchestral", "Band", "Strings", "Acoustic", "Chamber":
			octave = Overrides.get(track, octave)
	return octave


# structure is an array of chunks
# a chunk is loop repeated a given number of times
# it is defined by a program, a number of repeats, the bar it starts on,
# a density and the chords
# the repeated loops *do not need to be generated identical*
static func create_structure(programs: Array, parameters: Dictionary, section: int, rng: RandomNumberGenerator) -> Array:
	var length = parameters.Length
	var base_density = 0.01 * parameters.Density
	var base_intricacy = parameters.Intricacy
	var outro_tracks = parameters.IntroOutro
	var final = section == 1 or section == -1
	var endless = section == 0
	var intro_tracks = parameters.IntroTracks
	# section = 1 => SINGLE, section = 2 => AUTO 1st
	if not (0 < section and section < 3):
		intro_tracks = outro_tracks
	var intro_rate = parameters.IntroRate
	var intro_start = parameters.IntroStart
	var chunks = []
	var bars = 1
	var top = intro_tracks
	var program = null
	while bars < length:
# warning-ignore:integer_division
		var repeats = 1 + rng.randi_range(1, 1 + base_intricacy / 2)
		var chords = Banks.choose(Loops, rng)
		var next = bars + repeats * len(chords)
		program = programs.duplicate()
		var chunk = len(chunks)
		if bars == 1:
			top = intro_tracks
		elif final or next < length:
			top = intro_tracks + int(max(0, intro_rate * (1 + chunk - intro_start)))
		else:
			top = outro_tracks
		if top < 16:
			for p in range(top, 16):
				program[p] = 0
		elif next < length:
			for p in range(intro_tracks + outro_tracks, 16):
				if rng.randf() > sqrt(base_density):
					program[p] = 0
		var density = base_density + (1 - base_density) / (2 + chunk)
		chunks.append({program = program, repeats = repeats, bar = bars, density = density, intricacy = base_intricacy, chords = chords})
		bars = next
	if not program:
		program = programs.duplicate()
		for p in range(top, 16):
			program[p] = 0
	if final or not endless:
		chunks.append({program = program, repeats = 1, bar = bars, density = base_density, chords = [1]})
		bars += 1
	if final:
		program = programs.duplicate()
		for p in range(outro_tracks, 16):
			program[p] = 0
		chunks.append({program = program, repeats = 1, bar = bars, density = base_density, chords = [1]})
		program = program.duplicate()
		for p in range(0, 16):
			program[p] = 0
		chunks.append({program = program, repeats = 0, bar = bars + 1, density = base_density, chords = [1]})
	return chunks
