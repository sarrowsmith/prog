class_name Structure


# track to octave, using tracks for:
enum {CHORDS, DRONE, BASS, MELODY, HARMONY, COUNTER_HARMONY, RHYTHM, DESCANT, OTHER, DRUMS}
const Octaves = [4, 3, 3, 5, 5, 6, 5, 7, 5, 5]
const Banks = {
	Orchestral = [
		[1, 2, 20, 41, 47, 49, 50, 62],
		[42, 43, 49, 50, 62, 68],
		[44, 58, 59, 68, 71],
		[1, 2, 7, 41, 47, 57, 58, 60, 61, 66, 69, 70, 72, 74],
		[1, 2, 7, 41, 47, 57, 58, 60, 61, 66, 69, 70, 72, 74],
		[1, 2, 41, 57, 65, 72, 73],
		[10, 12, 13, 14, 46],
		[1, 2, 41, 57, 65, 72, 73],
		[1, 2, 7, 41, 47, 57, 58, 60, 61, 66, 69, 70, 72, 74],
	],
	Acoustic = [
		[3, 22, 25, 26],
		[22, 24, 41, 67, 110],
		[33, 34,35, 36, 67, 68],
		[2, 3, 4, 25, 26, 27, 41, 47, 66, 74, 76, 105, 106, 111],
		[2, 3, 4, 25, 26, 27, 41, 47, 66, 74],
		[2, 3, 4, 25, 26, 27, 41, 47, 65, 66, 73, 74, 75],
		[4, 10, 16, 109, 115],
		[2, 3, 4, 25, 26, 27, 41, 47, 65, 66, 73, 74, 75],
		[2, 3, 4, 25, 26, 27, 41, 47, 65, 66, 73, 74, 75, 76, 106, 111],
	],
	Electric = [
		[5, 6, 17, 18, 19, 28, 30, 31, 51, 52, 63, 64],
		[17, 19, 28, 30, 51, 52, 63, 64],
		[34, 35, 36, 39, 40],
		[5, 6, 17, 18, 19, 27, 28, 30, 31],
		[5, 6, 17, 18, 19, 27, 28, 30, 31],
		[5, 6, 17, 18, 19, 27, 28, 30, 31],
		[29, 37, 38],
		[5, 6, 17, 18, 19, 27, 28, 30, 31],
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
		[81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96],
	],
}


static func choose(from: Array, rng: RandomNumberGenerator):
	return from[rng.randi_range(0, len(from) - 1)]


static func get_octave(track: int):
	return Octaves[min(track, DRUMS)]


# structure is an array of chunks
# a chunk is loop repeated a given number of times
# it is defined by a program, a number of repeats, the bar it starts on,
# a density and the chords
# the repeated loops *do not need to be generated identical*
static func create_structure(style: String, length: int, base_density: float, rng: RandomNumberGenerator) -> Array:
	var programs = []
	if Banks.has(style):
		for track in Banks[style]:
			programs.append(choose(track, rng))
	else:
		for octave in Octaves:
			var section = 32 * min(octave - 3, 3)
			programs.append(rng.randi_range(section+1, section+32))
	return [
		{program = programs, repeats = 1, bar = 1, density = 0.5, chords = [1]},
	]
