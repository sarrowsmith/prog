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


func pulse_tint(mat: SpatialMaterial, base: Color, target: Color, time: float, timescale: float):
# warning-ignore:return_value_discarded
	remove(mat)
# warning-ignore:return_value_discarded
	interpolate_property(mat, "albedo_color", null, target, timescale)
# warning-ignore:return_value_discarded
	start()
	yield(self, "tween_all_completed")
# warning-ignore:return_value_discarded
	interpolate_property(mat, "albedo_color", null, base, (time - 2) * timescale, TRANS_LINEAR, EASE_OUT)
# warning-ignore:return_value_discarded
	start()
