class_name BankPicker
extends PopupMenu


var instrument_picker_prototype = preload("res://InstrumentPicker.tscn")


func _ready():
	for bank in Banks.GM_BANKS:
		var instrument_picker = instrument_picker_prototype.instance()
		add_child(instrument_picker, true)
		add_submenu_item(bank, instrument_picker.name)


func set_programs(programs: Array):
	for child in get_children():
		if child is InstrumentPicker:
			child.set_selected(programs)


func get_programs() -> Array:
	var value = []
	for child in get_children():
		if child is InstrumentPicker:
			value += child.get_selected()
	return value
