extends Tween


func pulse_thing(thing: Spatial, amount: float, time: float, timescale: float):
# warning-ignore:return_value_discarded
	remove(thing)
# warning-ignore:return_value_discarded
	interpolate_property(thing, "scale", null, Vector3.ONE * amount, timescale)
# warning-ignore:return_value_discarded
	start()
	yield(self, "tween_all_completed")
# warning-ignore:return_value_discarded
	interpolate_property(thing, "scale", null, Vector3.ONE, (time - 2) * timescale, TRANS_LINEAR, EASE_OUT)
# warning-ignore:return_value_discarded
	start()
