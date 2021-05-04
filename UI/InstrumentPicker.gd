class_name InstrumentPicker
extends PopupMenu


onready var bank = get_index() - 1


func _ready():
	for i in 8:
		add_check_item(Banks.GMInstruments[bank][i], bank * 8 + i + 1)


func set_selected(ids: Array):
	for idx in get_item_count():
		set_item_checked(idx, ids.has(get_item_id(idx)))


func get_selected() -> Array:
	var selected = []
	for idx in get_item_count():
		if is_item_checked(idx):
			selected.append(get_item_id(idx))
	return selected


func _on_InstrumentPicker_index_pressed(index):
	set_item_checked(index, not is_item_checked(index))
