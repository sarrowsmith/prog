class_name Responder
extends Spatial


export(float) var period = 1
export(float) var pulse = 1.25

var speed = 0
var axis = Vector3.UP
var thing: Spatial = null


func _process(delta):
	rotate_object_local(axis, delta * speed / period)


func respond(visualiser: Visualiser, note: Array):
	$Pulser.pulse_thing(thing, pulse, note[RandomPlayer.DURATION], visualiser.timescale)


func set_instrument(_instrumentation: Array):
	pass
