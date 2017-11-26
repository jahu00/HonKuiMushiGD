extends "res://script/Table.gd"

#var default_dictionary = { "path": "res://dictionary/English/en_US", "name": "English/en_US (internal)", "language": "English", "no_export": true }
var language_index = {}

#var dictionaries_path = "user://dictionary/"

var last_alphabet

var Alphabet = preload("res://script/Alphabet.gd")

func _init():
	init("alphabets")
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

func load_alphabets(alphabets_path, name_suffix = ""):
	
	# Search user folder for languages
	var alphabets_dir = Directory.new()
	var languages = []
	alphabets_dir.open(alphabets_path)
	alphabets_dir.list_dir_begin()
	while true:
		var folder = alphabets_dir.get_next()
		if (folder == ""):
			break
			pass
		
		if (!folder.begins_with(".") && alphabets_dir.dir_exists(folder)):
			languages.append(folder)
			pass
		pass
	alphabets_dir.list_dir_end()
	
	for language in languages:
		var language_dir = Directory.new()
		var language_path = alphabets_path + language + "/"
		language_dir.open(language_path)
		language_dir.list_dir_begin()
		while true:
			var file = language_dir.get_next()
			if (file == ""):
				break
				pass
			
			if (!file.begins_with(".") && file.ends_with(".json") && language_dir.file_exists(file)):
				var name = file.substr(0, file.length() - 5) + name_suffix
				var key = language + "/" + name
				append({ "name": name, "language": language, "path": language_path + file}, key)
				pass
			pass
		language_dir.list_dir_end()
		pass
	
	pass

func get_alphabet_by_id(id):
	var alphabet_settings = array[id]
	if (last_alphabet == null || last_alphabet.alphabet_settings != alphabet_settings):
		last_alphabet = Alphabet.new(alphabet_settings)
		pass
	return last_alphabet
	pass