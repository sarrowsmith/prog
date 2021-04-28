class_name Orbiter
extends Responder


const forms = ["Rough", "Metal", "Mirror", "Glass"]

export(float) var epiperiod = 1.0

var rng: RandomNumberGenerator
var bodies = []
var next = 0
var material: SpatialMaterial
var tint = Color.white
var base_tint = Color.white
var inclination = Vector3.DOWN
var form = ""
var track = 0

onready var epicycle = $Epicycle


# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func spawn(track: int, rng: RandomNumberGenerator) -> Responder:
	self.track = track
	self.rng = rng
	scale = Vector3.ZERO
	# Populating bodies requires created.epicycle to be available, which it
	# won't be until created enters the scene tree. So we set up the parameters
	# & defer construction to start(). Similarly with initial positions.
	form = forms[rng.randi_range(0, len(forms) - 1)]
	period = sqrt(track * track * track)
	epiperiod = abs(rng.randfn(1.0 if track < Structure.OTHER else 256.0 / track))
	return self


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
			var a = body.get_node("A")
			var b = body.get_node("B")
			material = a.get_surface_material(0).duplicate()
			base_tint = material.albedo_color
			a.set_surface_material(0, material)
			if track < Structure.DRUMS:
				b.visible = false
				a.scale = Vector3.ONE * track / 4.0
			else:
				b.set_surface_material(0, material)
			bodies.append(body)
	visible = true


func respond(visualiser: Visualiser, note: Array):
	if bodies:
		next = (next + 1) % len(bodies)
		thing = bodies[next]
		match form:
			"Glass":
				$Pulser.pulse_tint(material, base_tint, tint, note[RandomPlayer.DURATION], visualiser.timescale)
			"Mirror":
				$Pulser.pulse_tint(material, tint, base_tint, note[RandomPlayer.DURATION], visualiser.timescale)
				continue
			_:
				.respond(visualiser, note)


func set_instrument(instrumentation: Array):
	# instrumentation = [instrument, mode, key] as floats
	var instrument = instrumentation[0] / 128
	for body in bodies:
		for thing in body.get_children():
			if thing.visible:
				match form:
					"Rough":
						var intensity = 1 - 0.1 * instrumentation[1]
						tint = Color.from_hsv(fmod(1 + instrumentation[2] / 12 + instrument, 1), 0.5 * (1 + intensity), intensity)
						pulse = 1.5
					"Glass":
						tint = tint.linear_interpolate(Color(0.5, 1, 0.83, 0.5), instrument * instrument)
					_:
						tint = tint.linear_interpolate(Color.orange, instrument * instrument)
				if form != "Glass":
					material.albedo_color = tint
