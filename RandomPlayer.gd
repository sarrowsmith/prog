class_name RandomPlayer
extends Node


var SMF = preload("res://addons/midi/SMF.gd").new()

export(String, FILE, "*.sf2; Soundfont 2") var soundfont
export(int) var key = 0
export(int) var timebase = 48
export(int) var nbars = 1
export(int) var ntracks = 1
export(int) var mode = 3
export(int) var signature = 4

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
const DEFAULT = 128
var Scales = {} # const, but it's calculated on ready

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


func create_note(pitch: int, duration: float, volume: int) -> Array:
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


func create_bar(track: int, chunk: Dictionary, iteration: int, root: int, time: int) -> Array:
	var chord = generate_chord(root)
	# each entry is a [event_time, note] pair, where a 0-duration note is a note off event
	var notes = create_drums(chunk, iteration) if track == Structure.DRUMS else []
	var down_beat = true
	for beat in signature:
		match track:
			Structure.CHORDS:
				if down_beat or rng.randf() <= chunk.density:
					for note in chord:
# warning-ignore:integer_division
						notes.append([beat, create_note(note, 1.0, DEFAULT / 4)])
			Structure.DRONE:
				if down_beat:
					notes.append([beat, create_note(root % 8, signature, DEFAULT)])
			Structure.DRUMS:
				pass
			_:
				if track < Structure.DRUMS or rng.randf() <= chunk.density:
					notes.append([beat, create_note(Structure.choose(chord, rng), 1.0, DEFAULT)])
		down_beat = false
	for note in notes:
		note[0] = time + note[0] * timebase
	return notes


func order_events(a, b):
	return a.time < b.time


func create_loop(track: int, chunk: Dictionary, time: int, iteration: int) -> Array:
	var notes = []
	var bar_length = timebase * signature
	for chord in chunk.chords:
		for note in create_bar(track, chunk, iteration, chord, time):
			notes.append(note)
		time += bar_length
	return notes


func create_chunk(track: int, chunk: Dictionary) -> Array:
	var events  = []
	var time = chunk.bar
	var chunk_length = len(chunk.chords) * timebase * signature
	if track != Structure.DRUMS:
		var program = chunk.program[min(track, Structure.OTHER)]
		events.append(SMF.MIDIEventChunk.new(time - 1, track, SMF.MIDIEventProgramChange.new(program)))
	var notes = []
	for i in chunk.repeats:
		for note in create_loop(track, chunk, time, i):
			notes.append(note)
		time += chunk_length
	if track > Structure.DRONE and track != Structure.DRUMS:
		var iterations = int(clamp(chunk.density * track, 0, 4))
		for i in iterations:
			for n in len(notes):
				if rng.randf() <= chunk.density:
					pass #insert
	var octave = Structure.get_octave(track)
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
	var offset = timebase * (signature - 1)
	for chunk in structure:
		for event in create_chunk(track, chunk):
			event.time -= offset
			events.append(event)
	if events:
		endtime = events.back().time + timebase
		var eot = SMF.MIDIEventSystemEvent.new({"type": SMF.MIDISystemEventType.end_of_track})
		events.append(SMF.MIDIEventChunk.new(endtime, track, eot))
	return events


func create_smf(style: String, length: int) -> Dictionary:
	var tracks = []
	var track = len(tracks)
	var structure = Structure.create_structure(style, length, 0.5, rng)
	while track < ntracks:
		tracks.append(SMF.MIDITrack.new(track, create_track(track, structure)))
		track += 1
	return SMF.SMFData.new(0, ntracks, timebase, tracks)


func play(rng_seed: int, valence: int, style: String, tracks: int, length: int):
	rng.seed = rng_seed
	mode = valence
	ntracks = tracks
	$MidiPlayer.smf_data = create_smf(style, length)
	$MidiPlayer.play()


func stop():
	$MidiPlayer.stop()
