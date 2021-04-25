class_name Orbiter
extends Responder


export(float) var period = 1.0

onready var epicycle = $Epicycle

var inclination = Vector3.BACK


func _ready():
	axis = Vector3.UP
	start(false)


func _process(delta):
	epicycle.rotate_object_local(inclination, delta * speed * period)
	._process(delta)


func start(metal: bool):
	thing = epicycle.get_node("Metal" if metal else "Rough")
	thing.visible = true
