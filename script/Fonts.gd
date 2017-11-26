extends "res://script/Table.gd"

var default_font_1 = { "path": "res://font/montserrat/Montserrat-Regular.ttf", "name": "Montserrat.ttf (internal)", "scale": 1.0, "no_export": true }
var default_font_2 = { "path": "res://font/montserrat/Montserrat-Bold.ttf", "name": "Montserrat-Bold.ttf (internal)", "scale": 1.0, "no_export": true }

var fonts_path = "user://font/"

func _init():
	init("fonts")
	pass

func load_fonts(user_dir):
	# Add default fonts
	append(default_font_1, default_font_1.name)
	append(default_font_2, default_font_2.name)
	
	# Load font settings if they exist
	var font_settings_exist = user_dir.file_exists("font.json")
	if (font_settings_exist):
		_import("user://font.json")
		pass
	
	# Search user folder for fonts
	var font_dir = Directory.new()
	var fonts_found = []
	font_dir.open(fonts_path)
	font_dir.list_dir_begin()
	while true:
		var file = font_dir.get_next()
		if (file == ""):
			break
			pass
		
		if (!file.begins_with(".") && (file.ends_with(".ttf") || file.ends_with(".otf")) && font_dir.file_exists(file)):
			fonts_found.append(file)
			pass
		pass
	font_dir.list_dir_end()
	
	# Remove fonts that don't exist in user directory
	for font in array:
		if (font != default_font_1 && font != default_font_2 && fonts_found.find(font.name) == -1):
			remove(font.key)
			pass
		pass
	
	# Add new fonts
	for name in fonts_found:
		#var name = font_path.replace("user://font/", "")
		if (!index.has(name)):
			append({ "name": name, "path": fonts_path + name, "scale": 1.0 }, name)
			pass
		pass
	
	_export("user://font.json")
	
	pass
