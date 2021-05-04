class_name Orbiter
extends Responder


const Forms = ["Rough", "Metal", "Mirror", "Glass"]

export(float) var epispeed = 1.0

var rng: RandomNumberGenerator
var bodies = []
var next = 0
var material: SpatialMaterial
var tint = Color.white
var base_tint = Color.white
var inclination = Vector3.UP
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
	form = Banks.choose(Forms, rng)
	var inverse_track = Structure.DRUMS / float(track)
	speed = 0.25 * sqrt(inverse_track * inverse_track * inverse_track)
	return self


func _ready():
	start()


func _process(delta):
	epicycle.rotate_object_local(inclination, delta * rate * epispeed)
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
			match track:
				Structure.PERCUSSION, Structure.COUNTER, Structure.DESCANT:
					epicycle.scale = Vector3.ONE * 0.5
					b.set_surface_material(0, material)
					epispeed = -abs(rng.randfn(track))
					inclination = (Vector3.UP + Vector3.LEFT * rng.randfn() / sqrt(3.0) + Vector3.BACK * rng.randfn() / sqrt(3.0)).normalized()
				_:
					b.visible = false
					var x = (track - Structure.DRUMS) * 0.5
					var y = 0.25 * (1 + (Structure.DRUMS - x * x))
					epicycle.scale = Vector3.ONE * y
					a.translation *= 1 / (y * y)
					epispeed = rng.randfn(4.0 / track)
			bodies.append(body)
	visible = true


func respond(visualiser: Visualiser, note: Array):
	if bodies:
		next = (next + 1) % len(bodies)
		match form:
			"Glass":
				$Pulser.pulse_tint(material, base_tint, tint, note[RandomPlayer.DURATION], visualiser.timescale)
			"Mirror":
				$Pulser.pulse_tint(material, tint, base_tint, note[RandomPlayer.DURATION], visualiser.timescale)
				continue
			_:
				for child in bodies[next].get_children():
					if child.visible:
						thing = child
						.respond(visualiser, note)


func set_instrument(instrumentation: Array):
	# instrumentation = [instrument, mode, key] as floats
	var intensity = 1 - 0.1 * instrumentation[1]
	if rng:
		axis = (Vector3.UP + rng.randf_range(0.0, (1 - intensity)/sqrt(3.0)) * Vector3.LEFT + rng.randf_range(0.0, (1 - intensity)/sqrt(3.0)) * Vector3.BACK).normalized()
	var instrument = instrumentation[0] / 128
	for body in bodies:
		for thing in body.get_children():
			if thing.visible:
				match form:
					"Rough":
						tint = Color.from_hsv(fmod(1 + instrumentation[2] / 12 + instrument, 1), 0.5 * (1 + intensity), intensity)
						pulse = 1.5
					"Glass":
						tint = tint.linear_interpolate(Color(0.5, 1, 0.83, 0.5), instrument * instrument)
					_:
						tint = tint.linear_interpolate(Color.orange, instrument * instrument)
				if form != "Glass":
					material.albedo_color = tint

