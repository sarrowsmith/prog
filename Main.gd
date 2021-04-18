extends Node2D


var time_begin
var time_delay
var modes
var styles


func _ready():
	time_begin = OS.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	modes = $Control.find_node("Modes")
	modes.clear()
	for mode in RandomPlayer.Modes:
		modes.add_item(mode)
	styles = $Control.find_node("Styles")
	styles.clear()
	styles.add_item("Random")
	for style in Structure.Banks:
		styles.add_item(style)


func _process(_delta):
	# Obtain from ticks.
	var time = (OS.get_ticks_usec() - time_begin) / 1000000.0
	# Compensate for latency.
	time -= time_delay
	# May be below 0 (did not begin yet).
	time = max(0, time)
	#print("Time is: ", time)


func get_value(name: String) -> int:
	return int($Control.find_node(name).value)


func _on_Play_toggled(button_pressed):
	if button_pressed:
		$RandomPlayer.play($Control.find_node("Seed").text.hash(), modes.selected, styles.get_item_text(styles.selected), get_value("Tracks"), get_value("Length"))
	else:
		$RandomPlayer.stop()
