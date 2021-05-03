extends MenuButton


var separator_id = -1
var custom_id = -1
var custom = []
var bank_picker_prototype = preload("res://BankPicker.tscn")

onready var main_menu = get_popup()
onready var sub_menu = $TrackSelector


func _ready():
	main_menu.connect("id_pressed", self, "set_selected_id")
	for track in 16:
		if track == Structure.DRUMS:
			sub_menu.add_separator("Drums")
		else:
			var bank_picker = bank_picker_prototype.instance()
			sub_menu.add_child(bank_picker, true)
			sub_menu.add_submenu_item("Track %d: %s" % [track + 1, Structure.track_name(track)], bank_picker.name)
	remove_child(sub_menu)
	main_menu.add_child(sub_menu)


func set_selected_id(id: int):
	for idx in main_menu.get_item_count():
		if main_menu.is_item_radio_checkable(idx):
			main_menu.set_item_checked(idx, main_menu.get_item_id(idx) == id)
	set_custom()


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


func set_custom():
	var id = get_selected_id()
	if id == custom_id:
		return
	var value = get_selected_value()
	if value is String:
		if not Banks.PRESETS.has(value):
			return
		value = Banks.PRESETS[value]
	var i = 0
	for child in sub_menu.get_children():
		if child is BankPicker:
			child.set_programs(value[i])
			if i + 1 < len(value):
				i += 1


func get_custom() -> Array:
	var value = []
	for child in sub_menu.get_children():
		if child is BankPicker:
			value.append(child.get_programs())
	return value


func get_selected_value():
	var idx = get_selected_index()
	if idx < 0:
		return []
	var id = main_menu.get_item_id(idx)
	if id == custom_id:
		return get_custom()
	var name = main_menu.get_item_text(idx)
	if id < separator_id:
		return name
	# TODO: from file


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
	# TODO: from files
	custom_id = id
	if custom:
		main_menu.add_radio_check_item("(unsaved)", custom_id)
	main_menu.add_submenu_item("new", "TrackSelector")
	set_selected_id(selected)
