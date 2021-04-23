extends Spatial


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


func _process(_delta):
	# Obtain from ticks.
	var time = (OS.get_ticks_usec() - time_begin) / 1000000.0
	# Compensate for latency.
	time -= time_delay
	# May be below 0 (did not begin yet).
	time = max(0, time)
	#print("Time is: ", time)


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
	else:
		$RandomPlayer.stop()
	enable_controls(not button_pressed)


func _on_OpenSoundfont_pressed():
	$SoundfontDialog.popup_centered()


func _on_SoundfontDialog_file_selected(path):
	parameters.Soundfont = path


func _on_RandomPlayer_finished():
	$Controls.find_node("Play").pressed = false


func _on_MidiPlayer_changed_tempo(tempo):
	$Controls.find_node("Tempo").value = tempo
