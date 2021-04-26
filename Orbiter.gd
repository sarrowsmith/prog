class_name Orbiter
extends Responder


export(float) var epiperiod = 1.0

var bodies = []
var next = 0

onready var epicycle = $Epicycle

var inclination = Vector3.BACK


func _ready():
	axis = Vector3.UP
	start()


func _process(delta):
	epicycle.rotate_object_local(inclination, delta * speed / epiperiod)
	._process(delta)


func start():
	bodies.clear()
	for child in epicycle.get_children():
		if child.visible:
			bodies.append(child)


func respond(visualiser: Visualiser, note: Array):
	next = (next + 1) % len(bodies)
	thing = bodies[next]
	.respond(visualiser, note)


func set_instrument(instrumentation: Array):
	pass
