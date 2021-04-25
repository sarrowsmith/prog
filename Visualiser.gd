class_name Visualiser
extends Spatial


# rotations per bar
export(float) var rate = 0.0625

# radians per second per bar
var speed = 0.0
var instruments = {}
var timescale = 1.0

enum {OBJECTS, LIGHTS, TOPLIGHT, STELLATION}
onready var objects = [$Objects, $Lights, $BottomLight, $Stellation]
onready var responders = {
	Structure.CHORDS: $Lights,
	Structure.BASS: $BottomLight,
	Structure.MELODY: $Stellation,
}


func _ready():
	for thing in objects:
		thing.scale = Vector3.ZERO


func _process(delta):
	objects[OBJECTS].rotate_y(delta * speed)
	objects[LIGHTS].rotate_y(-delta * speed)


func scale_thing(thing: Spatial, to: float, time: float):
	$Scaler.interpolate_property(thing, "scale", thing.scale, Vector3.ONE * to, time)
	$Scaler.start()
	yield($Scaler, "tween_all_completed")


func start(start: bool, time: float):
	for thing in objects:
		scale_thing(thing, 1.0 if start else 0.0, time)


func pulse_thing(thing: Spatial, to: float, time: float):
	$Scaler.interpolate_property(thing, "scale", thing.scale, Vector3.ONE * to, timescale)
	$Scaler.start()
	yield($Scaler, "tween_all_completed")
	$Scaler.interpolate_property(thing, "scale", thing.scale, Vector3.ONE, (time - 1) * timescale)
	$Scaler.start()


func set_bar_length(bar_length: float):
	speed = TAU * rate / bar_length
	$Stellation.speed = TAU / bar_length


func _on_MidiPlayer_appeared_instrument_name(_channel_number, name):
	var parts = name.split(":")
	var track = int(parts[0])
	var instrument = parts[1]
	if instrument:
		if not (instruments.has(track) and instruments[track] == instrument):
			instruments[track] = instrument
			if responders.has(track):
				responders[track].set_instrument(instrument)
	else:
		if instruments.erase(track):
			if responders.has(track):
				responders[track].stop()
				responders.erase(track)


func _on_MidiPlayer_appeared_cue_point(cue_point):
	var note = cue_point.split(":")
	var track = int(note[0])
	if responders.has(track):
		note.remove(0)
		responders[track].respond(self, note)
