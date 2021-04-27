class_name Visualiser
extends Spatial


var orbiter_prototype = load("res://Orbiter.tscn")

# centi-rotations per bar
export(float) var rate = 3.125

# radians per second per bar
var speed = 0.0
var instruments = {}
var timescale = 1.0
var rng = RandomNumberGenerator.new()

enum {THINGS, CAMERA}
onready var objects = [$Objects, $Boom]
onready var responders = {
	Structure.CHORDS: $Lights,
	Structure.DRONE: $Orbiter,
	Structure.BASS: $BottomLight,
	Structure.MELODY: $Objects/Stellation,
	Structure.DRUMS: $Base,
}


func _ready():
	stop()


func _process(delta):
	pass
	objects[THINGS].rotate_y(delta * speed * rate)
	objects[CAMERA].rotate_y(-0.125 * delta * speed * rate)


func stop():
	for k in responders:
		responders[k].scale = Vector3.ZERO
	set_process(false)
	instruments.clear()


func start(rng_seed: int):
	rng.seed = rng_seed
	for track in 16:
		if not responders.has(track):
			var orbiter = orbiter_prototype.instance().spawn(track, rng)
			responders[track] = orbiter
			$Objects.add_child(orbiter)
	set_process(true)


func scale_thing(thing: Spatial, to: float, time: float):
	$Scaler.interpolate_property(thing, "scale", null, Vector3.ONE * to, time)
	$Scaler.start()


func set_bar_length(bar_length: float):
	speed = TAU * bar_length * 0.01
	for k in responders:
		responders[k].speed = speed


func _on_MidiPlayer_appeared_instrument_name(_channel_number, name):
	var parts = name.split_floats(":")
	var track = int(parts[0])
	parts.remove(0)
	if responders.has(track):
		var target = 0.0
		if parts[0]:
			responders[track].set_instrument(parts)
			target = 1.0
		scale_thing(responders[track], target, 100 * speed / TAU)


func _on_MidiPlayer_appeared_cue_point(cue_point):
	var note = cue_point.split_floats(":")
	var track = int(note[0])
	if responders.has(track):
		note.remove(0)
		responders[track].respond(self, note)
