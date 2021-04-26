class_name Visualiser
extends Spatial


# centi-rotations per bar
export(float) var rate = 3.125

# radians per second per bar
var speed = 0.0
var instruments = {}
var timescale = 1.0

enum {THINGS, CAMERA}
onready var objects = [$Objects, $Boom]
onready var responders = {
	Structure.CHORDS: $Lights,
	Structure.BASS: $BottomLight,
	Structure.MELODY: $Objects/Stellation,
	Structure.DRONE: $Objects/Orbiter,
}


func _ready():
	stop()


func _process(delta):
	objects[THINGS].rotate_y(delta * speed * rate)
	objects[CAMERA].rotate_y(-0.125 * delta * speed * rate)


func stop():
	for k in responders:
		responders[k].scale = Vector3.ZERO
	set_process(false)
	instruments.clear()


func start():
	set_process(true)


func scale_thing(thing: Spatial, to: float, time: float):
	$Scaler.interpolate_property(thing, "scale", null, Vector3.ONE * to, time)
	$Scaler.start()


func set_bar_length(bar_length: float):
	speed = TAU * bar_length * 0.01
	for k in responders:
		responders[k].speed = speed


func _on_MidiPlayer_appeared_instrument_name(_channel_number, name):
	var parts = name.split(":")
	var track = int(parts[0])
	parts.remove(0)
	var instrument = parts[0]
	if instrument:
		if not (instruments.has(track) and instruments[track] == instrument):
			instruments[track] = instrument
			if responders.has(track):
				responders[track].set_instrument(parts)
				scale_thing(responders[track], 1.0, 100 * speed / TAU)
	else:
		if instruments.erase(track):
			if responders.has(track):
				scale_thing(responders[track], 0.0, 100 * speed / TAU)


func _on_MidiPlayer_appeared_cue_point(cue_point):
	var note = cue_point.split_floats(":")
	var track = int(note[0])
	if responders.has(track):
		note.remove(0)
		responders[track].respond(self, note)
