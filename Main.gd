extends Control


var time_begin
var time_delay
var modes
var parameters = {
	Tracks = 16,
	Style = "Random",
	Mode = 3,
	Key = 7,
	Density = 50,
	Intricacy = 50,
	Tempo = 130,
	Length = 41,
	AutoMovements = false,
}

onready var pick_mode = $Configure.find_node("Mode")
onready var pick_key = $Configure.find_node("Key")
onready var pick_style = $Configure.find_node("Style")


func _ready():
	time_begin = OS.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	pick_mode.set_mode(parameters.Mode)
	for parameter in parameters:
		var control = $Configure.find_node(parameter + "2")
		if control:
			control.share($Configure.find_node(parameter))
			control.value = parameters[parameter]
	$Configure.find_node("AutoSection").pressed = false
	$Controls.find_node("Play").grab_focus()
	$Fader.interpolate_property($ViewportContainer, "modulate", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 2.0)
	fade_image(1.0, 0.5, 1.5)
	$ViewportContainer/Viewport/Visualiser.timescale = $RandomPlayer.timescale()


func fade_image(from: float, to: float, time: float):
	$Fader.interpolate_property($HappyKettle, "modulate", Color(1.0, 1.0, 1.0, from), Color(1.0, 1.0, 1.0, to), time)
	$Fader.start()


func fade(from: float, to: float, time: float):
	$Fader.interpolate_property($Configure, "modulate", Color(1.0, 1.0, 1.0, from), Color(1.0, 1.0, 1.0, to), 0.5 * time)
	fade_image(0.5 * from, 0.5 * to, time)
	if to > 0:
		$Configure.visible = true
	yield($Fader, "tween_all_completed")
	if to == 0:
		$Configure.visible = false


func set_active(name: String, on: bool):
	var control = $Configure.find_node(name)
	if control:
		if control is Button:
			control.disabled = not on
		else:
			control.editable = on


func enable_Configure(on: bool):
	for parameter in parameters:
		set_active(parameter, on)
		set_active(parameter + "2", on)
	set_active("OpenSoundfont", on)
	set_active("Feed", on)


func get_value(name: String):
	var control = $Configure.find_node(name)
	if not control:
		return null
	match name:
		"Mode", "Key":
			return control.selected
		"Style":
			return pick_style.get_selected_value()
	return control.value


func create() -> int:
	for parameter in parameters:
		var value = get_value(parameter)
		if value:
			parameters[parameter] = value
	var rng_seed = $Configure.find_node("Seed").text.hash()
	$RandomPlayer.create(rng_seed, parameters)
	return rng_seed


func _on_Play_toggled(button_pressed):
	var bar_length = $RandomPlayer.bar_time()
	if button_pressed:
		var rng_seed = create();
		$ViewportContainer/Viewport/Visualiser.start(rng_seed)
		$RandomPlayer.play_next()
		fade(1.0, 0.0, 0.5 * bar_length)
	else:
		$RandomPlayer.stop()
		fade(0.0, 1.0, 2 * bar_length)
		$ViewportContainer/Viewport/Visualiser.stop()
		$Controls.find_node("Queue").text = "-/-"
	enable_Configure(not button_pressed)
	$Controls.find_node("Play").text = "Stop" if button_pressed else "Play!"
	$Controls.find_node("Pause").disabled = not button_pressed


func _on_OpenSoundfont_pressed():
	$SoundfontDialog.popup_centered()


func _on_SoundfontDialog_file_selected(path):
	parameters.Soundfont = path


func _on_RandomPlayer_finished():
	$Controls.find_node("Play").pressed = false


func _on_MidiPlayer_changed_tempo(tempo):
	$Configure.find_node("Tempo").value = tempo
	$ViewportContainer/Viewport/Visualiser.set_bar_length($RandomPlayer.bar_time())


func _on_Pause_toggled(button_pressed):
	$RandomPlayer.pause(button_pressed)
	if button_pressed:
		fade(0.0, 1.0, 0.2)
	else:
		fade(1.0, 0.0, 0.6)
	get_tree().paused = button_pressed


func _on_Fullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_Quit_pressed():
	get_tree().quit()


func _on_AutoSection_toggled(button_pressed):
	parameters.AutoMovements = button_pressed
	$Configure.find_node("OpenExport").disabled = button_pressed


func _on_RandomPlayer_new_movement(length, movement, total):
	var progress = $Controls.find_node("Progress")
	$Progress.interpolate_property(progress, "value", progress.min_value, progress.max_value, length)
	$Progress.start()
	$Controls.find_node("Queue").text = "%d/%d" % [movement, total]


func _on_About_pressed():
	$AboutDialog.popup_centered()


func _on_RichTextLabel_meta_clicked(meta):
# warning-ignore:return_value_discarded
	OS.shell_open(meta)


func _on_SaveInstrumentation_pressed():
	$InstrumentationDialog.current_file = ".progi"
	$InstrumentationDialog.popup_centered()


func _on_OpenExport_pressed():
	$ExportDialog.current_dir = "."
	$ExportDialog.current_file = ".mid"
	$ExportDialog.popup_centered()


func _on_ExportDialog_file_selected(path):
	var save_file = File.new()
	if save_file.open(path, File.WRITE) == OK:
# warning-ignore:return_value_discarded
		create()
		save_file.store_buffer($RandomPlayer.write())
		save_file.close()
