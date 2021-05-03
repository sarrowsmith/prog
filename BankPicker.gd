class_name BankPicker
extends PopupMenu

signal program_changed()

var instrument_picker_prototype = preload("res://InstrumentPicker.tscn")
var track


func _ready():
	for bank in Banks.GM_BANKS:
		var instrument_picker = instrument_picker_prototype.instance()
		instrument_picker.connect("index_pressed", self, "on_program_change")
		add_child(instrument_picker, true)
		add_submenu_item(bank, instrument_picker.name)


func set_programs(programs: Array):
	for child in get_children():
		if child is InstrumentPicker:
			child.set_selected(programs[min(track, len(programs) - 1)])


func get_programs() -> Array:
	var value = []
	for child in get_children():
		if child is InstrumentPicker:
			value += child.get_selected()
	return value


func on_program_change(_id):
	emit_signal("program_changed")
