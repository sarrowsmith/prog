class_name Responder
extends Spatial


# centi-rotations per bar
export(float) var rate = 3.125
export(float) var pulse = 1.5

var speed = 0
var axis = Vector3.UP
var thing: Spatial


func _process(delta):
	rotate_object_local(axis, delta * speed * rate)


func respond(visualiser: Visualiser, note: Array):
	$Pulser.pulse_thing(thing, pulse, float(note[RandomPlayer.DURATION]), visualiser.timescale)


func set_instrument(instrument: String):
	print(instrument)


func stop():
	pass
