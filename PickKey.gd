extends OptionButton


func _unhandled_input(event):
	if event is InputEventKey:
		if KEY_A <= event.scancode and event.scancode <= KEY_G:
			var id = event.scancode - KEY_A
			if event.shift:
				id += 8
			selected = get_item_index(id)
