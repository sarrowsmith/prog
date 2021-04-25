class_name Visualiser
extends Spatial


export(float) var timescale = 130
# rotations per beat
export(float) var rate = 0.5

# functionally a const, this is the conversion from bpm to radians/s
var conversion = TAU * rate * timescale / 60
# Well, that's the theory. In practice, it's much slower, which is why the
# default rate looks high.

var speed = 1.0
var instruments = {}

enum {OBJECTS, LIGHTS, TOPLIGHT, STELLATION}
onready var objects = [$Objects, $Lights, $BottomLight, $Stellation]
onready var responders = {
	Structure.CHORDS: $Lights,
	Structure.DRONE: $BottomLight,
	Structure.MELODY: $Stellation,
}


func _ready():
	for thing in objects:
		thing.scale = Vector3.ZERO


func _process(delta):
	objects[OBJECTS].rotation_degrees.y += delta * speed * conversion
	objects[LIGHTS].rotation_degrees.y -= delta * speed * conversion


func scale_thing(thing: Spatial, to: float, time: float, hide: bool):
	$Scaler.interpolate_property(thing, "scale", thing.scale, Vector3.ONE * to, time)
	$Scaler.start()
	yield($Scaler, "tween_all_completed")
	if hide:
		thing.visible = false


func start(start: bool):
	for thing in objects:
		scale_thing(thing, 1.0 if start else 0.0, 2.5, not start)


func pulse_thing(thing: Spatial, to: float, out: float, back: float):
	$Scaler.interpolate_property(thing, "scale", thing.scale, Vector3.ONE * to, out)
	$Scaler.start()
	yield($Scaler, "tween_all_completed")
	$Scaler.interpolate_property(thing, "scale", thing.scale, Vector3.ONE, out)
	$Scaler.start()


func set_tempo(tempo: int):
	speed = tempo / timescale
	$Stellation.speed = speed * conversion


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
