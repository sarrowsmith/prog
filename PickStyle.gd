extends MenuButton


var separator_id = -1
var custom_id = -1
var custom_program = []
var custom_name = ""
var bank_picker_prototype = preload("res://BankPicker.tscn")

onready var main_menu = get_popup()
onready var sub_menu = $TrackSelector
onready var save_button = get_parent().get_node("SaveInstrumentation")


func _ready():
	main_menu.connect("id_pressed", self, "set_selected_id")
	for track in 16:
		if track == Structure.DRUMS:
			sub_menu.add_separator("Drums")
		else:
			var bank_picker = bank_picker_prototype.instance()
			bank_picker.track = track
			bank_picker.connect("program_changed", self, "on_customised")
			sub_menu.add_child(bank_picker, true)
			sub_menu.add_submenu_item("Track %d: %s" % [track + 1, Structure.track_name(track)], bank_picker.name)
	remove_child(sub_menu)
	main_menu.add_child(sub_menu)


func set_selected_id(id: int):
	for idx in main_menu.get_item_count():
		if main_menu.is_item_radio_checkable(idx):
			main_menu.set_item_checked(idx, main_menu.get_item_id(idx) == id)
	set_custom(id)


func get_selected_index() -> int:
	for idx in main_menu.get_item_count():
		if main_menu.is_item_radio_checkable(idx):
			if main_menu.is_item_checked(idx):
				return idx
	return -1


func get_selected_id() -> int:
	var idx = get_selected_index()
	if idx < 0:
		return 0
	return main_menu.get_item_id(idx)


func set_custom(id):
	if id == custom_id:
		return
	var value = get_value(id)
	if value is String:
		if not Banks.PRESETS.has(value):
			return
		value = Banks.PRESETS[value]
	if not value:
		return
	for child in sub_menu.get_children():
		if child is BankPicker:
			child.set_programs(value)


func get_custom() -> Array:
	var value = Banks.BLANK.duplicate()
	for child in sub_menu.get_children():
		if child is BankPicker:
			var programs = child.get_programs()
			if programs:
				value[min(child.track, len(value) - 1)] = programs
	return value


func get_value(id: int):
	if id == custom_id:
		return get_custom()
	var name = main_menu.get_item_text(main_menu.get_item_index(id))
	if id < separator_id:
		return name
	return load_style(name)


func get_selected_value():
	var idx = get_selected_index()
	if idx < 0:
		return []
	return get_value(main_menu.get_item_id(idx))


func on_customised():
	if not custom_program:
		main_menu.add_radio_check_item("(unsaved)", custom_id)
		save_button.disabled = false
	set_selected_id(custom_id)
	custom_program = get_custom()


func _on_Style_about_to_show():
	var selected = get_selected_id()
	main_menu.clear()
	var id = 0
	for style in Structure.styles():
		main_menu.add_radio_check_item(style, id)
		id += 1
	separator_id = id
	main_menu.add_separator("Custom", separator_id)
	id += 1
	for style in list_styles():
		main_menu.add_radio_check_item(style, id)
		if custom_name == style:
			selected = id
			custom_name = ""
		id += 1
	custom_id = id
	main_menu.add_submenu_item("new", "TrackSelector")
	if custom_program:
		main_menu.add_radio_check_item("(unsaved)", custom_id)
		save_button.disabled = false
	else:
		save_button.disabled = true
	set_selected_id(selected)


func list_styles() -> Array:
	var dir = Directory.new()
	if dir.open("user://"):
		return []
	var styles = []
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension() == "progi":
			styles.append(file_name.get_basename())
		file_name = dir.get_next()
	dir.list_dir_end()
	return styles


func save_name(name: String) -> String:
	return "user://%s.progi" % name


func load_style(name: String) -> Array:
	var save_file = File.new()
	var programs = []
	if save_file.open(save_name(name), File.READ) == OK:
		programs = save_file.get_var()
		save_file.close()
	return programs


func save_style(path: String):
	var save_file = File.new()
	if save_file.open(path, File.WRITE) == OK:
		save_file.store_var(custom_program)
		save_file.close()
		save_button.disabled = true
		main_menu.remove_item(main_menu.get_item_index(custom_id))
		custom_name = path.get_basename().substr(len(path.get_base_dir()))
		custom_program = []

func _on_InstrumentationDialog_file_selected(path):
	save_style(path)

