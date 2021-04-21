class_name RandomPlayer
extends Node


signal finished

var SMF = preload("res://addons/midi/SMF.gd").new()

export(String, FILE, "*.sf2; Soundfont 2") var soundfont
export(int) var key = 0
export(int) var timebase = 48
export(int) var mode = 3
export(int) var signature = 4
export(int) var tempo = 130
export(int) var movement = 30 # minimum length in bars

enum {PITCH, DURATION, VOLUME}

const Intervals = {
	Chromatic = [1,1,1,1,1,1,1,1,1,1,1], # (random, atonal: all twelve notes)
	Major = [2,2,1,2,2,2,1], # (classic, happy)
	HarmonicMinor = [2,1,2,2,1,3,1], # (haunting, creepy)
	MinorPentatonic = [3,2,2,3,2], # (blues, rock)
	Minor = [2,1,2,2,1,2,2], # (scary, epic)
	MelodicMinorUp = [2,1,2,2,2,2,1], # (wistful, mysterious)
	MelodicMinorDown = [2,2,1,2,2,1,2], # (sombre, soulful)
	Dorian = [2,1,2,2,2,1,2], # (cool, jazzy)
	Mixolydian = [2,2,1,2,2,1,2], # (progressive, complex)
	AhavaRaba = [1,3,1,2,1,2,2], # (exotic, unfamiliar)
	MajorPentatonic = [2,2,3,2,3], # (country, gleeful)
	Diatonic = [2,2,2,2,2,2], # (bizarre, symmetrical)
	Lydian = [2,2,2,1,2,2,1], # (bright, cheerful)
	Phrygian = [1,2,2,2,1,2,2],
	Locrian = [1,2,2,1,2,2,2],
}
const Modes = ["Lydian", "Major", "Mixolydian", "Dorian", "Minor", "Phrygian", "Locrian"]
const C = 0
const REST = 0
const DEFAULT = 96
var Scales = {} # const, but it's calculated on ready

var style = "Random"
var programs = []
var movements = 0
var adjustments = [
	{},
	{Length = 3.0},
	{Mode =-1, Length = 6.0, Tempo = 0.8, Density = -1, Intricacy = -1},
	{Mode = +1, Length = 4.0, Tempo = 1.2, Density = +1},
	{Mode = +2, Length = 4.0, Density = +1, Intricacy = +1},
]
var queue = []

onready var rng = RandomNumberGenerator.new()


func _ready():
	$MidiPlayer.soundfont = soundfont
	for k in Modes:
		var intervals = Intervals[k]
		Scales[k] = [0]
		for interval in intervals:
			Scales[k].append(Scales[k][-1] + interval)


func get_note_number(scale: Array, octave: int, note: int) -> int:
	var idx = note - 1
# warning-ignore:integer_division
	var octave_offset = idx / 7
	idx = idx % 7
	if note < 1 and (note - 1) % 7:
		octave_offset -= 1
		idx -= 1
	return key + 12 * (octave + octave_offset) + scale[idx]


func make_note(pitch: int, duration: float, volume: int) -> Array:
	return [pitch, int(float(timebase) * duration), volume]


func generate_chord(root: int) -> Array:
	var chord = []
	var seventh = root / 8
	root = root % 8
	for i in 3:
		chord.append(root + 2 * i)
	if seventh:
		chord.append(root + 7 + seventh)
	var inversion = rng.randi_range(0, 2 + seventh)
	for i in inversion:
		chord[i] += 7
	return chord


func create_drums(chunk: Dictionary, iteration: int) -> Array:
	return []


func create_note(track: int, down_beat: bool, chord: Array, root: int, note_length: int, chunk: Dictionary) -> Array:
	var notes = []
	var volume = DEFAULT
	match track:
		Structure.CHORDS:
			if down_beat or rng.randf() < chunk.density:
				for note in chord:
# warning-ignore:integer_division
					notes.append(make_note(note, note_length, volume / 2))
		Structure.DRONE:
			if down_beat:
				notes.append(make_note(root % 8, signature, volume / 4))
		Structure.DRUMS:
			pass
		Structure.PERCUSSION:
			if rng.randf() < chunk.density:
				volume = 3 * volume / 2
# warning-ignore:integer_division
				notes.append(make_note(chord.front(), note_length, volume))
				if rng.randf() < chunk.density:
					notes.append(make_note(chord.back(), note_length, volume))
		Structure.BASS, Structure.COUNTER_HARMONY, Structure.DESCANT:
			volume = 2 * volume / 3
			continue
		_:
			if rng.randf() < chunk.density:
				notes.append(make_note(Structure.choose(chord, rng), note_length, volume))
	return notes


func create_bar(track: int, chunk: Dictionary, iteration: int, root: int, time: int) -> Array:
	var chord = generate_chord(root)
	# each entry is a [event_time, note] pair, where a 0-duration note is a note off event
	var notes = create_drums(chunk, iteration) if track == Structure.DRUMS else []
	var down_beat = true
	var skip = 0
	for beat in signature if chunk.repeats else 1:
		if skip:
			skip -= 1
			continue
		var note_length = 1.0 if chunk.repeats else signature
		if signature - beat > 1 and rng.randf() > chunk.density:
			note_length = rng.randi_range(2, signature - beat)
			skip = note_length - 1
		for note in create_note(track, down_beat, chord, root, note_length, chunk):
			notes.append([beat, note])
		down_beat = false
	for note in notes:
		note[0] = time + note[0] * timebase
	return notes


func order_events(a, b):
	return a.time < b.time


func create_loop(track: int, chunk: Dictionary, iteration: int) -> Array:
	var notes = []
	var bar_length = timebase * signature
	var time = len(chunk.chords) * bar_length * iteration
	for chord in chunk.chords:
		notes += create_bar(track, chunk, iteration, chord, time)
		time += bar_length
	return notes


func create_insertion(notes: Array, n: int, iteration: int, chunk: Dictionary) -> Array:
	var note_length = timebase / (2 * iteration)
	var before = notes[n]
	n += 1
	var after = notes[n]
	if after[0] - before[0] != 2 * note_length or rng.randf() < chunk.density / iteration:
		return []
	var note = [before[0] + note_length, before[1].duplicate()]
	var pitch = 0
	match rng.randi_range(0, 2):
		0:
			pass
		1:
			pitch = rng.randi_range(-2,+2) * 2
		_:
			var gap = after[1][PITCH] - before[1][PITCH]
			var change = int(abs(gap))
			match change:
				0:
					pitch = rng.randi_range(-1,+1)
				1:
					pass
				_:
					pitch = rng.randi_range(-2,+2) * 2 if change % 2 else gap / 2
	note[1][PITCH] += pitch
	before[1][DURATION] = note_length
	return [note]


func create_chunk(track: int, chunk: Dictionary) -> Array:
	var events  = []
	var bar_length = timebase * signature
	var time = (chunk.bar - 1) * bar_length + 1
	var chunk_length = len(chunk.chords) * bar_length
	if track != Structure.DRUMS:
		var program = chunk.program[track]
		if not program:
			return events
		events.append(SMF.MIDIEventChunk.new(time - 1, track, SMF.MIDIEventProgramChange.new(program)))
	var notes = []
	var reseed = rng.randi()
	for i in max(chunk.repeats, 1):
		rng.seed = reseed
		notes += create_loop(track, chunk, i)
	if chunk.repeats:
		var iterations = 0
		match track:
			Structure.DRONE, Structure.DRUMS:
				pass
			Structure.MELODY, Structure.PERCUSSION, Structure.DESCANT:
				iterations = chunk.intricacy
			Structure.CHORDS, Structure.BASS:
				iterations -= 1
				continue
			_:
				iterations -= 1
		for i in max(0, iterations):
			var n = 0
			while n < len(notes) - 1:
				var note = create_insertion(notes, n, i + 1, chunk)
				if note:
					notes = notes.slice(0, n) + note + notes.slice(n + 1, len(notes) - 1)
				n += len(note) + 1
	var octave = Structure.get_octave(style, track)
	var scale = Scales[Modes[mode]]
	for event in notes:
		var note = event[1]
		var note_number = get_note_number(scale, octave, note[PITCH])
		# note (or rest if note[VOLUME] == 0) on
		events.append(SMF.MIDIEventChunk.new(time + event[0], track, SMF.MIDIEventNoteOn.new(note_number, note[VOLUME])))
		# note off ("note on with velocity 0 as note off" not supported in Godot MIDI Player.)
		events.append(SMF.MIDIEventChunk.new(time + event[0] + note[DURATION], track, SMF.MIDIEventNoteOff.new(note_number, 0)))
	events.sort_custom(self, "order_events")
	return events


func create_track(track: int, structure: Array) -> Array:
	var events = []
	var endtime = timebase
	for chunk in structure:
		events += create_chunk(track, chunk)
	if events:
		endtime = events.back().time + 1
		var eot = SMF.MIDIEventSystemEvent.new({"type": SMF.MIDISystemEventType.end_of_track})
		events.append(SMF.MIDIEventChunk.new(endtime, track, eot))
	return events


func create_smf(parameters: Dictionary, final: bool) -> Dictionary:
	var tracks = []
	var track = len(tracks)
	var structure = Structure.create_structure(programs, parameters.Length, 0.01 * parameters.Density, parameters.Intricacy, final, rng)
	while track < parameters.Tracks:
		tracks.append(SMF.MIDITrack.new(track, create_track(track, structure)))
		track += 1
	return SMF.SMFData.new(0, parameters.Tracks, timebase, tracks)


func play(rng_seed: int, parameters: Dictionary):
	rng.seed = rng_seed
	programs = Structure.create_programs(parameters.Style, rng)
	movements = min(int(parameters.Length / movement), 4)
	adjustments[0] = parameters
	if parameters.has("Soundfont") and parameters.Soundfont != soundfont:
		soundfont = parameters.Soundfont
		$MidiPlayer.soundfont = soundfont
	queue.clear()
	if parameters.has("Key"):
		key = parameters.Key
	if parameters.has("Mode"):
		mode = parameters.Mode
	if parameters.has("Signature"):
		signature = parameters.Signature
	if parameters.has("Tempo"):
		tempo = parameters.Tempo
	else:
		parameters.Tempo = tempo
	if movements:
		adjustments[0] = parameters.duplicate()
		for i in movements:
			if i:
				parameters = adjustments[0].duplicate()
			var adjustment = adjustments[i+1]
			for parameter in adjustment:
				match parameter:
					"Mode", "Intricacy":
						parameters.Mode = max(0, min(parameters[parameter] + adjustment[parameter], 6))
					"Length":
						parameters.Length = int((4 * parameters.Length) / (movements * adjustment.Length))
					_:
						parameters[parameter] *= adjustment[parameter]
			queue.push_back([create_smf(parameters, i + 1 == movements), parameters.Tempo])
	else:
		queue.push_back([create_smf(parameters, true), parameters.Tempo])
# warning-ignore:return_value_discarded
	play_next()


func play_next() -> bool:
	var entry = queue.pop_front()
	if entry:
		$MidiPlayer.smf_data = entry[0]
		$MidiPlayer.tempo = entry[1]
		$MidiPlayer.play()
		return true
	return false


func stop():
	$MidiPlayer.stop()


func _on_MidiPlayer_finished():
	if not play_next():
		$MidiPlayer.tempo = tempo
		emit_signal("finished")
