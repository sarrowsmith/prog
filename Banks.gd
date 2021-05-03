class_name Banks


const GM_BANKS = [
	"Piano", "Chromatic Percussion", "Organ", "Guitar", "Bass", "Strings", "Ensemble", "Brass",
	"Reed", "Pipe", "Synth Lead", "Synth Pad", "Synth Effects", "Ethnic", "Percussive", "Sound Effects",
]
const GM_INSTRUMENTS = [
	["Acoustic Grand Piano", "Bright Acoustic Piano", "Electric Grand Piano", "Honky-tonk Piano", "Electric Piano 1", "Electric Piano 2", "Harpsichord", "Clavichord"],
	["Celesta", "Glockenspiel", "Music Box", "Vibraphone", "Marimba", "Xylophone", "Tubular Bells", "Dulcimer"],
	["Drawbar Organ", "Percussive Organ", "Rock Organ", "Church Organ", "Reed Organ", "Accordion", "Harmonica", "Tango Accordion"],
	["Acoustic Guitar (nylon)", "Acoustic Guitar (steel)", "Electric Guitar (jazz)", "Electric Guitar (clean)", "Electric Guitar (muted)", "Overdriven Guitar", "Distortion Guitar", "Guitar Harmonics"],
	["Acoustic Bass", "Electric Bass (finger)", "Electric Bass (pick)", "Fretless Bass", "Slap Bass 1", "Slap Bass 2", "Synth Bass 1", "Synth Bass 2"],
	["Violin", "Viola", "Cello", "Contrabass", "Tremolo Strings", "Pizzicato Strings", "Orchestral Harp", "Timpani"],
	["String Ensemble 1", "String Ensemble 2", "Synth Strings 1", "Synth Strings 2", "Choir Aahs", "Voice Oohs", "Synth Voice", "Orchestra Hit"],
	["Trumpet", "Trombone", "Tuba", "Muted Trumpet", "French Horn", "Brass Section", "Synth Brass 1", "Synth Brass 2"],
	["Soprano Sax", "Alto Sax", "Tenor Sax", "Baritone Sax", "Oboe", "English Horn", "Bassoon", "Clarinet"],
	["Piccolo", "Flute", "Recorder", "Pan Flute", "Blown bottle", "Shakuhachi", "Whistle", "Ocarina"],
	["(square)", "(sawtooth)", "(calliope)", "(chiff)", "(charang)", "(voice)", "(fifths)", "(bass + lead)"],
	["(new age)", "(warm)", "(polysynth)", "(choir)", "(bowed)", "(metallic)", "(halo)", "(sweep)"],
	["(rain)", "(soundtrack)", "(crystal)", "(atmosphere)", "(brightness)", "(goblins)", "(echoes)", "(sci-fi)"],
	["Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai"],
	["Tinkle Bell", " Agogô", "Steel Drums", "Woodblock", "Taiko Drum", "Melodic Tom", "Synth Drum", "Reverse Cymbal"],
	["Guitar Fret Noise", "Breath Noise", "Seashore", "Bird Tweet", "Telephone Ring", "Helicopter", "Applause", "Gunshot"],
]
const BLANK = [
	[0], # CHORDS
	[0], # DRONE
	[0], # BASS
	[0], # MELODY
	[0], # HARMONY
	[0], # RHYTHM
	[0], # PERCUSSION
	[0], # COUNTER
	[0], # DESCANT
	[0], # DRUMS
	[0], # OTHER
	[0], # track 12
	[0], # track 13
	[0], # track 14
	[0], # track 15
	[0], # track 16
]
const PRESETS = {
	Orchestral = [
		[1, 2, 20, 41, 47, 49, 50, 62], # CHORDS
		[42, 43, 49, 50, 62], # DRONE
		[44, 58, 59, 71], # BASS
		[1, 2, 7, 41, 47, 57, 58, 60, 61, 69, 70, 72, 74], # MELODY
		[1, 2, 7, 41, 47, 57, 58, 60, 61, 69, 70, 72, 74], # HARMONY
		[1, 2, 20, 41, 47, 49, 50, 62], # RHYTHM
		[10, 12, 13, 14, 15, 46, 47], # PERCUSSION
		[1, 2, 41, 57, 65, 72, 73], # COUNTER
		[1, 2, 41, 57, 65, 72, 73], # DESCANT
		[0], # DRUMS
		[1, 2, 7, 41, 47, 57, 58, 60, 61, 69, 70, 72, 74], # OTHER
	],
	Band = [
		[3, 22, 25, 26], # CHORDS
		[22, 24, 41, 67, 110], # DRONE
		[33, 34,35, 36, 67, 68], # BASS
		[2, 3, 4, 25, 26, 27, 41, 47, 66, 74, 76, 105, 106, 111], # MELODY
		[2, 3, 4, 25, 26, 27, 41, 47, 66, 74], # HARMONY
		[3, 22, 25, 26], # RHYTHM
		[4, 10, 16, 109, 115], # PERCUSSION
		[2, 3, 4, 25, 26, 27, 41, 47, 65, 66, 73, 74, 75], # COUNTER
		[2, 3, 4, 25, 26, 27, 41, 47, 65, 66, 73, 74, 75, 79], # DESCANT
		[0], # DRUMS
		[2, 3, 4, 25, 26, 27, 41, 47, 65, 66, 73, 74, 75, 76, 106, 111], # OTHER
	],
	Electric = [
		[5, 6, 17, 18, 19, 28, 30, 31, 51, 52, 63, 64], # CHORDS
		[17, 19, 28, 30, 51, 52, 63, 64], # DRONE
		[34, 35, 36, 39, 40], # BASS
		[5, 6, 17, 18, 19, 27, 28, 30, 31], # MELODY
		[5, 6, 17, 18, 19, 27, 28, 30, 31], # HARMONY
		[5, 6, 17, 18, 19, 28, 30, 31, 51, 52, 63, 64], # RHYTHM
		[29, 37, 38], # PERCUSSION
		[5, 6, 17, 18, 19, 27, 28, 30, 31], # COUNTER
		[5, 6, 17, 18, 19, 27, 28, 30, 31], # DESCANT
		[0], # DRUMS
		[5, 6, 17, 18, 19, 27, 28, 29, 30, 31], # OTHER
	],
	Electronic = [
		[81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96], # CHORDS
		[89, 90, 91, 92, 93, 94, 95, 96], # DRONE
		[89, 90, 91, 92, 93, 94, 95, 96], # BASS
		[81, 82, 83, 84, 85, 86, 87, 88], # MELODY
		[81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96], # HARMONY
		[81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96], # RHYTHM
		[97, 98, 99, 100, 101, 102, 103, 104], # PERCUSSION
		[81, 82, 83, 84, 85, 86, 87, 88], # COUNTER
		[81, 82, 83, 84, 85, 86, 87, 88], # DESCANT
		[0], # DRUMS
		[81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96], # OTHER
	],
	Strings = [
		[41, 42, 43, 45, 49, 50], # CHORDS
		[43, 45, 49, 50], # DRONE
		[43, 44], # BASS
		[41, 42, 43], # MELODY
		[41, 43], # HARMONY
		[41, 42, 43, 46], # RHYTHM
		[13, 14, 48], # PERCUSSION
		[41], # COUNTER
		[41], # DESCANT
		[0], # DRUMS
		[41, 42, 43, 44, 45, 46, 49, 50], # OTHER
	],
	Acoustic = [
		[2, 22, 25, 26, 41, 42], # CHORDS
		[22, 24, 41, 42], # DRONE
		[33, 43, 44], # BASS
		[2, 4, 25, 26, 41, 74, 76, 111], # MELODY
		[2, 4, 24, 25, 26, 42, 43, 74, 111], # HARMONY
		[4, 12, 13, 14, 16, 25, 26, 116], # RHYTHM
		[9, 12, 13, 14, 16, 109, 116], # PERCUSSION
		[10, 41, 73, 75], # COUNTER
		[10, 41, 73, 75, 79], # DESCANT
		[0], # DRUMS
		[2, 4, 12, 13, 24, 25, 26, 41, 42, 74, 111], # OTHER
	],
	Chamber = [
		[1, 41, 42, 43, 45, 49, 50], # CHORDS
		[41, 42, 43, 45, 49, 50], # DRONE
		[43, 44, 71], # BASS
		[1, 7, 41, 43, 74], # MELODY
		[1, 7, 41, 43, 74], # HARMONY
		[1, 42, 49, 50], # RHYTHM
		[12, 13, 14, 46], # PERCUSSION
		[1, 7, 10, 41, 73], # COUNTER
		[1, 7, 10, 41, 73], # DESCANT
		[0], # DRUMS
		[1, 7, 12, 13, 14, 41, 42, 43, 74], # OTHER
	],
}


static func instrument_name(program: int) -> String:
	if program:
		program -= 1
# warning-ignore:integer_division
		var bank = program / 8
		return "%s: %s" % [GM_BANKS[bank], GM_INSTRUMENTS[bank][program % 8]]
	return ""


static func choose(from: Array, rng: RandomNumberGenerator):
	return from[rng.randi_range(0, len(from) - 1)]


static func pick_programs(bank: Array, rng: RandomNumberGenerator) -> Array:
	var programs = []
	for track in bank:
		programs.append(choose(track, rng))
	var track = bank.back()
	while len(programs) < 16:
		programs.append(choose(track, rng))
	return programs


static func create_programs(parameters: Dictionary, rng: RandomNumberGenerator) -> Array:
	var style = parameters.Style
	if style is Array:
		return pick_programs(style, rng)
	if PRESETS.has(style):
		return pick_programs(PRESETS[style], rng)
	var programs = []
	for track in 16:
		match style:
			"Random":
				programs.append(rng.randi_range(track * 8 + 1, track * 8 + 8))
			"Mixed":
				var bank = PRESETS[choose(PRESETS.keys(), rng)]
				programs.append(choose(bank[min(track, len(bank) - 1)], rng))
			_:
				programs.append(rng.randi_range(1, 128))
	return programs
