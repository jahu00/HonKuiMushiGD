extends "res://script/Table.gd"

#var default_dictionary = { "path": "res://dictionary/English/en_US", "name": "English/en_US (internal)", "language": "English", "no_export": true }
var language_index = {}

#var dictionaries_path = "user://dictionary/"

func _init():
	init("languages")
	pass

func append(item, key):
	if (.append(item, key) == null):
		return
		pass
	
	if (!language_index.has(item.language)):
		language_index[item.language] = []
		pass
	language_index[item.language].append(item)
	pass

func load_alphabets(languages_path, name_suffix = ""):
	
	# Search user folder for languages
#	var languages_dir = Directory.new()
#	var languages = []
#	languages_dir.open(alphabets_path)
#	languages_dir.list_dir_begin()
#	while true:
#		var file_name = language_dir.get_next()
#		if (file_name == ""):
#			break
#			pass
#		
#		if (!file_name.begins_with(".") && file_name.ends_with(".json") && language_dir.file_exists(file_name)):
#				var f = File.new()
#				f.open("user://settings.json", File.WRITE)
#				f.store_string(settings.to_json())
#				f.close()
#			
#			var path = file_name.substr(0, file.length() - 5)
#			var name = language + "/" + name + name_suffix
#			append({ "name": name, "language": language, "path": language_path + path}, name)
#			pass
#		pass
#	languages_dir.list_dir_end()
	pass