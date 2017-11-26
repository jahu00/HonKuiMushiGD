extends "res://script/Table.gd"

#var default_dictionary = { "path": "res://dictionary/English/en_US", "name": "English/en_US (internal)", "language": "English", "no_export": true }
var language_index = {}

#var settings

#var dictionaries_path = "user://dictionary/"

var last_dictionary

var _Dictionary = preload("res://script/Dictionary.gd")

func _init():
	init("dictionaries")
	#settings = Globals.get("Settings")
	pass

func append(item, key):
	item.id = array.size()
	
	if (.append(item, key) == null):
		return
		pass
	
	if (!language_index.has(item.language)):
		language_index[item.language] = []
		pass
	language_index[item.language].append(item)
	pass

func load_dictionaries(dictionaries_path, name_suffix = ""):
	
	# Search user folder for languages
	var dictionary_dir = Directory.new()
	var languages = []
	dictionary_dir.open(dictionaries_path)
	dictionary_dir.list_dir_begin()
	while true:
		var folder = dictionary_dir.get_next()
		if (folder == ""):
			break
			pass
		
		if (!folder.begins_with(".") && dictionary_dir.dir_exists(folder)):
			languages.append(folder)
			pass
		pass
	dictionary_dir.list_dir_end()
	
	for language in languages:
		var language_dir = Directory.new()
		var language_path = dictionaries_path + language + "/"
		language_dir.open(language_path)
		language_dir.list_dir_begin()
		while true:
			var file = language_dir.get_next()
			if (file == ""):
				break
				pass
			
			if (!file.begins_with(".") && file.ends_with(".dic") && language_dir.file_exists(file)):
				var name = file.substr(0, file.length() - 4)
				var path = language_path + name
				name += name_suffix
				var key = language + "/" + name
				append({ "name": name, "language": language, "path": path }, key)
				pass
			pass
		language_dir.list_dir_end()
		pass
	
	pass

func get_dictionary_by_id(id):
	var dictionary_settings = array[id]
	if (last_dictionary == null || last_dictionary.dictionary_settings != dictionary_settings):
		last_dictionary = _Dictionary.new(dictionary_settings)
		pass
	return last_dictionary
	pass