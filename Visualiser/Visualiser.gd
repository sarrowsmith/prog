class_name Visualiser
extends Spatial


# Can't preload as const because it creates cyclic references in Orbiter
var OrbiterPrototype = load("res://Visualiser/Orbiter.tscn")

export(float) var speed = 2

# tempo-adjusted radians per second
var rate = 0.0
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
			var orbiter = OrbiterPrototype.instance().spawn(track, rng)
			responders[track] = orbiter
			$Objects.add_child(orbiter)
	set_process(true)


func scale_thing(thing: Spatial, to: float, time: float):
	$Scaler.interpolate_property(thing, "scale", null, Vector3.ONE * to, time)
	$Scaler.start()


func set_bar_length(bar_length: float):
	rate = TAU / (bar_length * 16.0)
	for k in responders:
		responders[k].rate = rate


func _on_MidiPlayer_appeared_instrument_name(_channel_number, name):
	var parts = name.split_floats(":")
	var track = int(parts[0])
	parts.remove(0)
	if responders.has(track):
		var target = 0.0
		if parts[0]:
			responders[track].set_instrument(parts)
			target = 1.0
		scale_thing(responders[track], target, TAU / (rate * 16.0))


func _on_MidiPlayer_appeared_cue_point(cue_point):
	var note = cue_point.split_floats(":")
	var track = int(note[0])
	if responders.has(track):
		note.remove(0)
		responders[track].respond(self, note)
