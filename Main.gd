extends Control


const DefaultParameters = {
	Tracks = 16,
	Seed = "",
	Style = "Random",
	Mode = 3,
	Key = 7,
	Density = 50,
	Intricacy = 2,
	Tempo = 130,
	Length = 128,
	IntroTracks = Structure.HARMONY,
	IntroRate = 2.0,
	IntroStart = 2,
	IntroOutro = Structure.PERCUSSION,
}

var parameters = DefaultParameters.duplicate()
var modes
var capture
var visualiser

onready var pick_mode = $Configure.find_node("Mode")
onready var pick_key = $Configure.find_node("Key")
onready var pick_style = $Configure.find_node("Style")
onready var recorder = AudioServer.get_bus_effect(AudioServer.get_bus_index("Recorder"), 0)
onready var instrument_list = $Controls.find_node("CurrentInstruments")


func _ready():
	pick_mode.set_mode(parameters.Mode)
	for parameter in parameters:
		if parameter.begins_with("Intro"):
			var control = $Configure.find_node(parameter)
			control.min_value = RandomPlayer.Randomizable[parameter][0]
			control.max_value = RandomPlayer.Randomizable[parameter][1]
			control.value = parameters[parameter]
			continue
		var control = $Configure.find_node(parameter + "2")
		if control:
			control.share($Configure.find_node(parameter))
			control.value = parameters[parameter]
	$Controls.find_node("Play").grab_focus()
	$Fader.interpolate_property($ViewportContainer, "modulate", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 2.0)
	fade_image(1.0, 0.5, 1.5)
	$RandomPlayer.midi_player.connect("changed_tempo", self, "_on_MidiPlayer_changed_tempo")
	$RandomPlayer.midi_player.connect("appeared_instrument_name", self, "_on_MidiPlayer_appeared_instrument_name")
	recorder.set_recording_active(false)
	capture = false


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
	for button in ["Randomize", "Sections", "OpenSoundfont", "Load", "Capture", "OpenExport"]:
		set_active(button, on)
	if on:
		_on_Sections_item_selected($Configure.find_node("Sections").selected)


func set_value(name: String, value=null):
	var control = $Configure.find_node(name)
	if not control:
		return
	if value == null:
		value = parameters[name]
	match name:
		"Mode", "Key":
			control.selected = value
		"Style":
			control.set_selected_style(value)
		"Seed":
			control.text = String(value)
		_:
			control.value = value


func get_value(name: String):
	var control = $Configure.find_node(name)
	if not control:
		return null
	match name:
		"Mode", "Key":
			return control.selected
		"Style":
			return pick_style.get_selected_value()
		"Seed":
			return control.text
	return control.value


func get_seed() -> int:
	return parameters.Seed.hash()


func save_parameters(path: String):
	var save_file = File.new()
	if save_file.open(path, File.WRITE) == OK:
		get_parameters()
		save_file.store_var(parameters)
		save_file.close()


func load_parameters(path: String):
	var save_file = File.new()
	if save_file.open(path, File.READ) == OK:
		parameters = save_file.get_var()
		save_file.close()
		set_parameters()


func set_parameters():
	for parameter in DefaultParameters:
		if not parameters.has(parameter):
			parameters[parameter] = DefaultParameters[parameter]
		set_value(parameter)


func get_parameters():
	for parameter in parameters:
		var value = get_value(parameter)
		if value != null:
			parameters[parameter] = value


func create():
	get_parameters()
	var rng_seed = get_seed()
	$RandomPlayer.create(rng_seed, parameters, $Configure.find_node("Sections").selected)


func _on_Play_toggled(button_pressed):
	if button_pressed:
		create();
		if recorder.is_recording_active():
			recorder.set_recording_active(false)
		recorder.set_recording_active(capture)
		$RandomPlayer.play_next()
		fade(1.0, 0.0, 0.5 * $RandomPlayer.bar_time())
	else:
		var bar_length = $RandomPlayer.bar_time()
		$RandomPlayer.stop()
		yield(get_tree().create_timer(0.5 * bar_length), "timeout")
		if capture:
			recorder.set_recording_active(false)
			$SaveCaptureDialog.current_dir = "."
			$SaveCaptureDialog.current_file = ".wav"
			$SaveCaptureDialog.popup_centered()
		fade(0.0, 1.0, 0.5 * bar_length)
		$Controls.find_node("Queue").text = "-/-"
		$Progress.stop_all()
	enable_Configure(not button_pressed)
	$Controls.find_node("Play").text = "Stop" if button_pressed else "Play!"
	$Controls.find_node("Pause").disabled = not button_pressed
	var last = $Controls.find_node("Last")
	if last.visible:
		last.disabled = not button_pressed
		$Controls.find_node("Next").disabled = last.disabled


func _on_OpenSoundfont_pressed():
	$SoundfontDialog.popup_centered()


func _on_SoundfontDialog_file_selected(path):
	parameters.Soundfont = path


func _on_RandomPlayer_finished():
	$Controls.find_node("Play").pressed = false


func _on_MidiPlayer_changed_tempo(tempo):
	$Configure.find_node("Tempo").value = tempo
	if visualiser != null:
		visualiser.set_bar_length($RandomPlayer.bar_time())


func _on_Pause_toggled(button_pressed):
	$RandomPlayer.pause(button_pressed)
	if button_pressed:
		fade(0.0, 1.0, 0.2)
	else:
		fade(1.0, 0.0, 0.6)
	$Progress.set_active(not button_pressed)
	get_tree().paused = button_pressed


func _on_Fullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_Quit_pressed():
	get_tree().quit()


func _on_RandomPlayer_new_movement(length, movement, total):
	var progress = $Controls.find_node("Progress")
	$Progress.interpolate_property(progress, "value", progress.min_value, progress.max_value, length)
	$Progress.start()
	$Controls.find_node("Queue").text = "%d/%d" % [movement, total]
	if not total: # endless or loop
		var new = $RandomPlayer.get_current_parameters()
		for parameter in new:
			parameters[parameter] = new[parameter]
		set_parameters()
	var next = $Controls.find_node("Next")
	if next.visible:
		next.disabled = $Controls.find_node("Last").disabled


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


func _on_Randomise_pressed():
	$RandomPlayer.random_parameters(parameters)
	set_parameters()


func _on_LoadSaveDialog_file_selected(path):
	if $LoadSaveDialog.mode == FileDialog.MODE_SAVE_FILE:
		save_parameters(path)
	else:
		load_parameters(path)


func open_load_save(how):
	$LoadSaveDialog.mode = how
	$LoadSaveDialog.current_file = ".progp"
	$LoadSaveDialog.popup_centered()


func _on_Load_pressed():
	open_load_save(FileDialog.MODE_OPEN_FILE)


func _on_Save_pressed():
	open_load_save(FileDialog.MODE_SAVE_FILE)


func _on_Capture_toggled(button_pressed):
	capture = button_pressed


func _on_SaveCaptureDialog_file_selected(path):
	recorder.get_recording().save_to_wav(path)


func _on_Sections_item_selected(index):
	$Configure.find_node("OpenExport").disabled = index != RandomPlayer.SINGLE
	var loop = index == RandomPlayer.LOOP
	$Controls.find_node("Queue").visible = not loop
	var next = $Controls.find_node("Next")
	next.visible = loop
	var last = $Controls.find_node("Last")
	last.visible = index >= RandomPlayer.ENDLESS


func _on_MidiPlayer_appeared_instrument_name(_channel_number, name):
	var parts = name.split_floats(":")
	instrument_list.add_instrument(int(parts[0]), int(parts[1] - 1))


func _on_Next_pressed():
	$RandomPlayer.random_next()
	$Controls.find_node("Next").disabled = true


func _on_Last_pressed():
	$RandomPlayer.end_next()
	$Controls.find_node("Last").disabled = true
	$Controls.find_node("Next").disabled = true
