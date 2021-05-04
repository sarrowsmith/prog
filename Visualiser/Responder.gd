class_name Responder
extends Spatial


export(float) var speed = 1
export(float) var pulse = 1.25

var rate = 0
var axis = Vector3.UP
var thing: Spatial = null


func _process(delta):
	rotate_object_local(axis, delta * speed * rate)


func respond(visualiser: Visualiser, note: Array):
	$Pulser.pulse_thing(thing, pulse, note[RandomPlayer.DURATION], visualiser.timescale)


func set_instrument(_instrumentation: Array):
	pass
