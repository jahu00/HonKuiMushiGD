extends Node

var tile_size = 120

var settings = {}
var dictionary_list = {
	"res://dictionary/en_US": "EN-US (Internal)"
}
var alphabet_list = {
	"res://alphabet/en.json": "EN (Internal)"
}

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
	#languages = Languages().new()
	# Load internal alphabets
	#languages.load_languages("res://language/", " (internal)")
	#languages.load_languages("user://language/")
	
	#var test = load("res://script/Dictionary.gd").new("user://dictionary/Polish/pl_PL")
	
	load_settings()
	
	Globals.set("TileSize", tile_size)
	Globals.set("Languages", languages)
	Globals.set("Settings", settings)
	
	#get_tree().change_scene("res://Game.tscn")
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

#func load_assets():
#	fonts = Table.new();
#	languages = Table.new();
#	
#	pass

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
	settings["alphabet"] = alphabet_list.keys()[0]
	settings["dictionary"] = dictionary_list.keys()[0]
	pass

func save_settings():
	var f = File.new()
	f.open("user://settings.json", File.WRITE)
	f.store_string(settings.to_json())
	f.close()
	pass

func find_dictionaries():
	pass