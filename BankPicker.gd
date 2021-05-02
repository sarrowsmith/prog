extends PopupMenu


var instrument_picker_prototype = preload("res://InstrumentPicker.tscn")


func _ready():
	for bank in Banks.GM_BANKS:
		var instrument_picker = instrument_picker_prototype.instance()
		add_child(instrument_picker, true)
		add_submenu_item(bank, instrument_picker.name)


func set_programs(programs: Array):
	pass


func get_programs() -> Array:
	return Banks.Blank.duplicate()
