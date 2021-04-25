extends Tween


func pulse_thing(thing: Spatial, amount: float, time: float, timescale: float):
	remove(thing)
	interpolate_property(thing, "scale", null, Vector3.ONE * amount, timescale)
	start()
	yield(self, "tween_all_completed")
	interpolate_property(thing, "scale", null, Vector3.ONE, (time - 2) * timescale)
	start()
