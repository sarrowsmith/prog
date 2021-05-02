extends PopupMenu


onready var bank = get_index() - 1


func _ready():
	print(bank)
	for i in 8:
		add_check_item(Banks.GM_INSTRUMENTS[bank][i], bank * 16 + i)


func _on_InstrumentPicker_index_pressed(index):
	set_item_checked(index, not is_item_checked(index))
