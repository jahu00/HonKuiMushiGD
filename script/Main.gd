extends Node

var encryption_password = "1111"

var tile_size = 120

var settings = {}

var languages
var fonts
var dictionaries
var alphabets

var user_dir

var Table = preload("res://script/Table.gd")
var Fonts = preload("res://script/Fonts.gd")
var Dictionaries = preload("res://script/Dictionaries.gd")
var Alphabets = preload("res://script/Alphabets.gd")

func _ready():
	randomize()
	
	user_dir = Directory.new()
	user_dir.open("user://")
	
	setup_directories()
	
	fonts = Fonts.new()
	fonts.load_fonts(user_dir)
	
	dictionaries = Dictionaries.new()
	# Load internal dictionaries
	dictionaries.load_dictionaries("res://dictionary/", " (internal)")
	# Load user dictionaries
	dictionaries.load_dictionaries("user://dictionary/")
	
	alphabets = Alphabets.new()
	# Load internal alphabets
	alphabets.load_alphabets("res://alphabet/", " (internal)")
	# Load user alphabets
	alphabets.load_alphabets("user://alphabet/")
	
	Globals.set("Fonts", fonts)
	Globals.set("Dictionaries", dictionaries)
	Globals.set("Alphabets", alphabets)
	Globals.set("UserDir", user_dir)
	Globals.set("Main", self)
	
	
	languages = Table.new()
	languages.init("Languages")
	for language_name in dictionaries.language_index.keys():
		if (
			dictionaries.language_index[language_name].size() > 0 &&
			alphabets.language_index.has(language_name) &&
			alphabets.language_index[language_name].size() > 0
			):
			languages.append({ "name": language_name }, language_name)
			pass
		pass
	
	load_settings()
	
	Globals.set("TileSize", tile_size)
	Globals.set("Languages", languages)
	Globals.set("Settings", settings)
	
	#go to menu
	set_scene_from_path("res://Menu.tscn")
	pass

func set_scene(new_scene):
	for child in get_children():
		child.queue_free()
		pass
	add_child(new_scene)
	pass

func set_scene_from_path(new_scene_path):
	for child in get_children():
		child.queue_free()
		pass
	var new_scene = load(new_scene_path).instance()
	add_child(new_scene)
	pass

func setup_directories():
	
	create_directory_if_doesnt_exist("dictionary")
	create_directory_if_doesnt_exist("alphabet")
	create_directory_if_doesnt_exist("language")
	create_directory_if_doesnt_exist("language_settings")
	create_directory_if_doesnt_exist("font")
	
	pass

func create_directory_if_doesnt_exist(name):
	if (!user_dir.dir_exists(name)):
		user_dir.make_dir(name)
		pass
	pass

func get_fonts_for_language(language):
	var file_name = "user://language_settings/" + language + ".json"
	if (user_dir.file_exists(file_name)):
		var f = File.new()
		var result = {}
		f.open(file_name, File.READ)
		var json_str  = f.get_as_text()
		result.parse_json(json_str)
		f.close()
		if (result.has("fonts")):
			return result.fonts
			pass
		pass
	return {
		"tile_font": fonts.default_font_1.name, "word_font": fonts.default_font_2.name
	}
	pass

func set_fonts_for_language(language, language_fonts):
	var file_name = "user://language_settings/" + language + ".json"
	var language_settings = {
		"fonts": language_fonts
	}
	var f = File.new()
	f.open(file_name, File.WRITE)
	f.store_string(language_settings.to_json())
	f.close()
	pass

func get_font_data(language, font_type):
	var font_data = DynamicFontData.new()
	var path = ""
	var language_fonts = get_fonts_for_language(language)
	if (language_fonts.has(font_type) && fonts.index.has(language_fonts[font_type])):
		path = fonts.index[language_fonts[font_type]].path
		pass
	else:
		if (font_type == "tile_font"):
			path = fonts.default_font_1.path
			pass
		if (font_type == "word_font"):
			path = fonts.default_font_2.path
			pass
		pass
	font_data.set_font_path(path)
	return font_data
	pass

func load_languages():
	pass

func load_settings():
	if (!user_dir.file_exists("settings.json")):
		setup_settings()
		save_settings()
		return
		pass
	
	var f = File.new()
	f.open("user://settings.json", File.READ)
	var json_str  = f.get_as_text()
	settings.parse_json(json_str)
	f.close()
	pass

func setup_settings():
	settings["last_language"] = languages.array[0].name
	settings["last_alphabet"] = alphabets.array[0].name
	settings["last_dictionary"] = dictionaries.array[0].name
	settings["fonts"] = {}
	pass

func save_settings():
	var f = File.new()
	f.open("user://settings.json", File.WRITE)
	f.store_string(settings.to_json())
	f.close()
	pass

func find_dictionaries():
	pass