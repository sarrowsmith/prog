class_name Visualiser
extends Spatial


export(float) var timescale = 130
# rotations per beat
export(float) var rate = 0.5

# functionally a const, this is the conversion from bpm to radians/s
var conversion = TAU * rate * timescale / 60
# Well, that's the theory. In practice, it's much slower, which is why the
# default rate looks high.

var instruments = {}
var things = {}
var speed = 1.0

onready var objects = $Objects
onready var lights = $Lights


func _ready():
	objects.scale = Vector3.ZERO


func _process(delta):
	objects.rotation_degrees.y += delta * speed * conversion
	lights.rotation_degrees.y -= delta * speed * conversion


func scale_thing(thing: Spatial, to: float, time: float):
	$Scaler.interpolate_property(thing, "scale", thing.scale, Vector3.ONE * to, time)
	$Scaler.start()
	yield($Scaler, "tween_all_completed")


func start(start: bool):
	scale_thing(objects, 1.0 if start else 0.0, 1.0)


func set_tempo(tempo: int):
	speed = tempo / timescale


func _on_MidiPlayer_appeared_instrument_name(channel_number, name):
	var parts = name.split(":")
	var key = "%d.%s" % [channel_number, parts[0]]
	var instrument = parts[1]
	if instrument:
		if not (instruments.has(key) and instruments[key] == instrument):
			instruments[key] = instrument
			pass #print("%s: %s" % [key, instrument])
	else:
		if instruments.erase(key):
			pass #print(key + " stopped")




func _on_MidiPlayer_appeared_cue_point(cue_point):
	var note = cue_point.split(":")
	var track = note[0]
