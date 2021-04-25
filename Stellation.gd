class_name Stellation
extends Responder


var last = -1
var speed = 0

onready var cubes = [$CubeY, $CubeX, $CubeZ]


func _process(delta):
	rotation_degrees.y += delta * speed


func respond(visualiser: Visualiser, note: Array):
	var pitch = int(note[RandomPlayer.PITCH])
	print(pitch)
	if last < 0:
		last = pitch
		return
	var cube = cubes[int(sign(pitch - last)) + 1]
	visualiser.pulse_thing(cube, 1.72, 0.075, int(note[RandomPlayer.DURATION]) - 0.1)
