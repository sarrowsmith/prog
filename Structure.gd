class_name Structure


# track to octave, using tracks for:
enum {CHORDS, DRONE, BASS, MELODY, HARMONY, RHYTHM, PERCUSSION, COUNTER, DESCANT, DRUMS, OTHER}
const Octaves = [4, 3, 3, 5, 5, 4, 5, 6, 7, 5, 5]
const Banks = {
	Orchestral = [
		[1, 2, 20, 41, 47, 49, 50, 62],
		[42, 43, 49, 50, 62],
		[44, 58, 59, 71],
		[1, 2, 7, 41, 47, 57, 58, 60, 61, 69, 70, 72, 74],
		[1, 2, 7, 41, 47, 57, 58, 60, 61, 69, 70, 72, 74],
		[1, 2, 20, 41, 47, 49, 50, 62],
		[10, 12, 13, 14, 15, 46],
		[1, 2, 41, 57, 65, 72, 73],
		[1, 2, 41, 57, 65, 72, 73],
		[0],
		[1, 2, 7, 41, 47, 57, 58, 60, 61, 69, 70, 72, 74],
	],
	Acoustic = [
		[3, 22, 25, 26],
		[22, 24, 41, 67, 110],
		[33, 34,35, 36, 67, 68],
		[2, 3, 4, 25, 26, 27, 41, 47, 66, 74, 76, 105, 106, 111],
		[2, 3, 4, 25, 26, 27, 41, 47, 66, 74],
		[3, 22, 25, 26],
		[4, 10, 16, 109, 115],
		[2, 3, 4, 25, 26, 27, 41, 47, 65, 66, 73, 74, 75],
		[2, 3, 4, 25, 26, 27, 41, 47, 65, 66, 73, 74, 75, 79],
		[0],
		[2, 3, 4, 25, 26, 27, 41, 47, 65, 66, 73, 74, 75, 76, 106, 111],
	],
	Electric = [
		[5, 6, 17, 18, 19, 28, 30, 31, 51, 52, 63, 64],
		[17, 19, 28, 30, 51, 52, 63, 64],
		[34, 35, 36, 39, 40],
		[5, 6, 17, 18, 19, 27, 28, 30, 31],
		[5, 6, 17, 18, 19, 27, 28, 30, 31],
		[5, 6, 17, 18, 19, 28, 30, 31, 51, 52, 63, 64],
		[29, 37, 38],
		[5, 6, 17, 18, 19, 27, 28, 30, 31],
		[5, 6, 17, 18, 19, 27, 28, 30, 31],
		[0],
		[5, 6, 17, 18, 19, 27, 28, 29, 30, 31],
	],
	Electronic = [
		[81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96],
		[89, 90, 91, 92, 93, 94, 95, 96],
		[89, 90, 91, 92, 93, 94, 95, 96],
		[81, 82, 83, 84, 85, 86, 87, 88],
		[81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96],
		[81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96],
		[97, 98, 99, 100, 101, 102, 103, 104],
		[81, 82, 83, 84, 85, 86, 87, 88],
		[81, 82, 83, 84, 85, 86, 87, 88],
		[0],
		[81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96],
	],
}
const Overrides = {BASS: 4, COUNTER: 5, DESCANT: 6}

const Loops = [
	[1, 3, 5, 4],
	[1, 5, 4, 6],
	[1, 3, 7, 2],
	[1, 1, 5, 4],
	[1, 4, 5, 1],
]

static func styles() -> Array:
	return ["Random", "Mixed", "Chaotic"] + Banks.keys()


static func instrument_name(program: int) -> String:
	return String(program)


static func choose(from: Array, rng: RandomNumberGenerator):
	return from[rng.randi_range(0, len(from) - 1)]


static func get_octave(style: String, track: int) -> int:
	var octave = Octaves[min(track, DRUMS)]
	match style:
		"Orchestral", "Acoustic":
			if Overrides.has(track):
				octave = Overrides[track]
	return octave


static func create_programs(style: String, rng: RandomNumberGenerator) -> Array:
	var programs = []
	if Banks.has(style):
		for track in Banks[style]:
			programs.append(choose(track, rng))
		while len(programs) < 16:
			var track = choose(Banks[style], rng)
			programs.append(choose(track, rng))
	else:
		for track in 16:
			match style:
				"Random":
					programs.append(rng.randi_range(track * 8 + 1, track * 8 + 8))
				"Mixed":
					var bank = Banks[choose(Banks.keys(), rng)]
					programs.append(choose(bank[min(track, OTHER)], rng))
				_:
					programs.append(rng.randi_range(1, 128))
	return programs


# structure is an array of chunks
# a chunk is loop repeated a given number of times
# it is defined by a program, a number of repeats, the bar it starts on,
# a density and the chords
# the repeated loops *do not need to be generated identical*
static func create_structure(programs: Array, length: int, base_density: float, base_intricacy: int, final: bool, rng: RandomNumberGenerator) -> Array:
	var chunks = []
	var bars = 1
	var top = HARMONY
	while bars < length:
# warning-ignore:integer_division
		var repeats = 1 + rng.randi_range(1, 1 + base_intricacy / 2)
		var chords = choose(Loops, rng)
		var program = programs.duplicate()
		var chunk = len(chunks)
		top = max(0, 2 * (chunk - 1)) + HARMONY
		if top > DRUMS and bars + repeats < length and rng.randf() <= base_density:
			top = rng.randi_range(DESCANT, 15)
		for p in range(top, 16):
			program[p] = 0
		var density = base_density + (1 - base_density) / (2 + chunk)
		chunks.append({program = program, repeats = repeats, bar = bars, density = density, intricacy = base_intricacy, chords = chords})
		bars += repeats * len(chords)
	if final:
		for p in range(top, OTHER):
			programs[p] = 0
		chunks.append({program = programs, repeats = 0, bar = bars, density = base_density, chords = [1]})
	return chunks
