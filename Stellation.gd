class_name Stellation
extends Responder


export(float) var rate = 0.125

var last = -1
var speed = 0
var axis = Vector3.UP

onready var cubes = [$CubeY, $CubeX, $CubeZ]


func _process(delta):
	rotate_object_local(axis, delta * speed * rate)


func respond(visualiser: Visualiser, note: Array):
	var pitch = int(note[RandomPlayer.PITCH])
	if last < 0:
		last = pitch
		return
	var cube = cubes[int(sign(pitch - last)) + 1]
	visualiser.pulse_thing(cube, 1.72, 0.075, int(note[RandomPlayer.DURATION]) - 0.1)
