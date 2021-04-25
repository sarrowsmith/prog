extends Control


var time_begin
var time_delay
var modes
var styles
var parameters = {
	Tracks = 16,
	Style = "Random",
	Mode = 3,
	Key = 7,
	Density = 50,
	Intricacy = 50,
	Tempo = 130,
	Length = 41,
}


func _ready():
	time_begin = OS.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	modes = $Controls.find_node("Mode")
	modes.clear()
	for mode in RandomPlayer.Modes:
		modes.add_item(mode)
	modes.select(parameters.Mode)
	styles = $Controls.find_node("Style")
	styles.clear()
	for style in Structure.styles():
		styles.add_item(style)
	for parameter in parameters:
		var control = $Controls.find_node(parameter + "2")
		if control:
			control.share($Controls.find_node(parameter))
			control.value = parameters[parameter]
	$Controls.find_node("Play").grab_focus()
	$Fader.interpolate_property($HappyKettle/Image, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.9), 1.0)
	$Fader.start()


func fade_image(from: float, to: float, time: float):
	$Fader.interpolate_property($HappyKettle, "modulate", Color(1.0, 1.0, 1.0, from), Color(1.0, 1.0, 1.0, to), time)
	$Fader.start()
	yield($Fader, "tween_all_completed")


func set_active(name: String, on: bool):
	var control = $Controls.find_node(name)
	if control:
		if control is Button:
			control.disabled = not on
		else:
			control.editable = on


func enable_controls(on: bool):
	for parameter in parameters:
		set_active(parameter, on)
		set_active(parameter + "2", on)
	set_active("OpenSoundfont", on)
	set_active("Feed", on)


func get_value(name: String):
	var control = $Controls.find_node(name)
	if not control:
		return null
	match name:
		"Mode", "Key":
			return control.selected
		"Style":
			return control.get_item_text(control.selected)
	return control.value


func _on_Play_toggled(button_pressed):
	if button_pressed:
		for parameter in parameters:
			var value = get_value(parameter)
			if value:
				parameters[parameter] = value
		$RandomPlayer.play($Controls.find_node("Seed").text.hash(), parameters)
		fade_image(1.0, 0, 1.5)
	else:
		$RandomPlayer.stop()
		fade_image(0.0, 1.0, 2.0)
	enable_controls(not button_pressed)
	$Controls.find_node("Play").text = "Stop!" if button_pressed else "Play!"
	$Controls.find_node("Pause").disabled = not button_pressed
	$ViewportContainer/Viewport/Visualiser.start(button_pressed)


func _on_OpenSoundfont_pressed():
	$SoundfontDialog.popup_centered()


func _on_SoundfontDialog_file_selected(path):
	parameters.Soundfont = path


func _on_RandomPlayer_finished():
	$Controls.find_node("Play").pressed = false


func _on_MidiPlayer_changed_tempo(tempo):
	$Controls.find_node("Tempo").value = tempo
	$ViewportContainer/Viewport/Visualiser.set_tempo(tempo)
