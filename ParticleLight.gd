class_name ParticleLight
extends Responder


var particles = []
var next = 0


func _ready():
	for child in get_children():
		particles.append(child.find_node("Particles"))


func respond(_visualiser: Visualiser, _note: Array):
	particles[next].restart()
	next = (next + 1) % len(particles)
