extends OptionButton


func _unhandled_input(event):
	if event is InputEventKey:
		if KEY_1 <= event.scancode and event.scancode <= KEY_7:
			selected = event.scancode - KEY_1


func set_mode(idx: int):
	clear()
	for mode in RandomPlayer.Modes:
		add_item(mode)
	select(idx)
