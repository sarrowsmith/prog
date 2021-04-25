class_name Stellation
extends Responder


var last = -1

onready var cubes = [$CubeY, $CubeX, $CubeZ]


func _ready():
	axis = Vector3.RIGHT


func respond(visualiser: Visualiser, note: Array):
	var pitch = int(note[RandomPlayer.PITCH])
	if last < 0:
		last = pitch
		return
	thing = cubes[int(sign(pitch - last)) + 1]
	.respond(visualiser, note)
