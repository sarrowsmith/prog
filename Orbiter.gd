class_name Orbiter
extends Responder


const forms = ["Rough", "Metal", "Mirror", "Glass"]

export(float) var epiperiod = 1.0

var rng: RandomNumberGenerator
var bodies = []
var next = 0
var inclination = Vector3.DOWN
var form = ""
var track = 0

onready var epicycle = $Epicycle


# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func spawn(track: int, rng: RandomNumberGenerator) -> Responder:
	var clone = duplicate()
	clone.visible = false
	# Populating bodies requires created.epicycle to be available, which it
	# won't be until created enters the scene tree. So we set up the parameters
	# & defer construction to start(). Similarly with initial positions.
	clone.form = forms[rng.randi_range(0, len(forms) - 1)]
	clone.track = track
	clone.period = sqrt(track * track * track)
	clone.epiperiod = abs(rng.randfn(1.0 if track < Structure.OTHER else 256.0 / track))
	clone.rng = rng
	return clone


func _ready():
	start()


func _process(delta):
	epicycle.rotate_y(-delta * speed / epiperiod)
	._process(delta)


func start():
	epicycle.translation = Vector3.BACK * pow(track, 1.25) * (2 * (track % 2) - 1)
	bodies.clear()
	if form:
		var body = epicycle.get_node(form)
		if body:
			body.visible = true
			if track < Structure.DRUMS:
				body.get_node("B").visible = false
				body.get_node("A").scale = Vector3.ONE * track / 4.0
			bodies.append(body)
	visible = true


func respond(visualiser: Visualiser, note: Array):
	if bodies:
		next = (next + 1) % len(bodies)
		thing = bodies[next]
		.respond(visualiser, note)


func set_instrument(instrumentation: Array):
	# instrumentation = [instrument, mode, key] as floats
	for body in bodies:
		for thing in body.get_children():
			if thing.visible:
				match form:
					"Rough":
						pass
					"Metal":
						pass
					_:
						continue
