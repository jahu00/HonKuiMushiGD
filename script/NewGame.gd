extends Node

var languages
var dictionaries
var alphabets
var settings
var main

var last_language
var last_dictionary
var last_alphabet

var language_list
var dictionary_list
var alphabet_list

var game

func _ready():
	main = Globals.get("Main")
	settings = Globals.get("Settings")
	last_language = settings.last_language
	last_dictionary = settings.last_dictionary
	last_alphabet = settings.last_alphabet
	languages = Globals.get("Languages")
	dictionaries = Globals.get("Dictionaries")
	alphabets = Globals.get("Alphabets")
	language_list = get_node("LanguageList")
	dictionary_list = get_node("DictionaryList")
	alphabet_list = get_node("AlphabetList")
	language_list.init(funcref(self, "_on_LanguageList_item_selected"))
	populate_languages()
	pass

func populate_languages():
	for language in languages.array:
		language_list.add_item_object(language.name, language.name)
		pass
	if (language_list.index_map.has(last_language)):
		language_list.select_value(last_language)
		pass
	else:
		language_list.select_first()
		pass
	pass

func populate_alphabets(language):
	alphabet_list.clear_items()
	for alphabet in alphabets.language_index[language]:
		alphabet_list.add_item_object(alphabet.name, alphabet.id)
		pass
	if (alphabet_list.index_map.has(last_alphabet)):
		alphabet_list.select_value(last_alphabet)
		pass
	else:
		alphabet_list.select_first()
		pass
	last_alphabet = null
	pass

func populate_dictionaries(language):
	dictionary_list.clear_items()
	for dictionary in dictionaries.language_index[language]:
		dictionary_list.add_item_object(dictionary.name, dictionary.id)
		pass
	if (dictionary_list.index_map.has(last_dictionary)):
		dictionary_list.select_value(last_dictionary)
		pass
	else:
		dictionary_list.select_first()
		pass
	last_dictionary = null
	pass

func _on_LanguageList_item_selected(language):
	populate_alphabets(language)
	populate_dictionaries(language)
	pass

func _on_MenuButton_pressed():
	main.set_scene_from_path("res://Menu.tscn")
	pass

func _on_StartButton_pressed():
	var game = load("res://Game.tscn").instance()
	last_language = language_list.get_selected_value()
	last_dictionary = dictionary_list.get_selected_value()
	last_alphabet = alphabet_list.get_selected_value()
	settings.last_language = last_language
	settings.last_dictionary = last_dictionary
	settings.last_alphabet = last_alphabet
	main.save_settings()
	game.init(last_language, last_alphabet, last_dictionary, "new_game")
	main.set_scene(game)
	pass
