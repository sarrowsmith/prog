extends OptionButton


export(Environment) var environment
export(String, DIR) var directory

var name_to_file = {}


func _ready():
	var dir = Directory.new()
	if dir.open(directory):
		return
	name_to_file = {}
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension() == "png":
			var title = file_name.get_basename()
			var options = title.split("_")
			if len(options) > 1:
				name_to_file[options[0]] = [file_name, Vector3(0, 0, 0)]
				name_to_file[options[1]] = [file_name, Vector3(0, 0, 180)]
			else:
				name_to_file[title] = [file_name, Vector3(0, 0, 180)]
		file_name = dir.get_next()
	dir.list_dir_end()


func _on_Background_item_selected(index):
	var title = get_item_text(index).replace("-", "").replace(" ", "")
	var file_orientation = name_to_file.get(title)
	if not file_orientation:
		return
	var sky = environment.background_sky as PanoramaSky
	if sky:
		sky.panorama = load("%s/%s" % [directory, file_orientation[0]])
	environment.background_sky_rotation_degrees = file_orientation[1]
