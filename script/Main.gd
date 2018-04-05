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
	user_dir.open("user://")
	if (!user_dir.dir_exists("dictionary")):
		user_dir.make_dir("dictionary")
		pass
	
	if (!user_dir.dir_exists("alphabet")):
		user_dir.make_dir("alphabet")
		pass
	
	if (!user_dir.dir_exists("language")):
		user_dir.make_dir("language")
		pass
	
	if (!user_dir.dir_exists("font")):
		user_dir.make_dir("font")
		pass
	
	pass

func get_font_data(language, font_type):
	var font_data = DynamicFontData.new()
	var path = ""
	if (settings.fonts.has(language) && settings.fonts[language].has(font_type) && fonts.index.has(settings.fonts[language][font_type])):
		path = fonts.index[settings.fonts[language][font_type]].path
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