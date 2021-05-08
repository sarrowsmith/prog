class_name CurrentInstruments
extends MenuButton


const Utility = preload("res://addons/midi/Utility.gd")

onready var instrument_list = get_popup()


func add_instrument(track: int, program: int):
	var index = instrument_list.get_item_index(track)
	if program < 0:
		if not index < 0:
			instrument_list.remove_item(index)
		return
	var label = "Track %d, %s: %s" % [track + 1, Structure.track_name(track), Utility.program_names[program]]
	if index < 0:
		instrument_list.add_item(label, track)
	else:
		instrument_list.set_item_text(index, label)
