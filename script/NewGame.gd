extends Node

var languages
var dictionaries
var alphabets

var language_drop_down
var alphabet_drop_down
var dictionary_drop_down

var game

func _ready():
	languages = Globals.get("Languages")
	dictionaries = Globals.get("Dictionaries")
	alphabets = Globals.get("Alphabets")
	language_drop_down = get_node("LanguageOptionButton")
	alphabet_drop_down = get_node("AlphabetOptionButton")
	dictionary_drop_down = get_node("DictionaryOptionButton")
	populate_languages()
	#language_drop_down#.select(0)
	_on_LanguageOptionButton_item_selected(0)
	pass

func populate_languages():
	for language in languages.array:
		language_drop_down.add_item(language.name)
		pass
	pass

func populate_alphabets(language):
	alphabet_drop_down.clear()
	for alphabet in alphabets.language_index[language]:
		alphabet_drop_down.add_item(alphabet.name, alphabet.id)
		pass
	pass


func populate_dictionaries(language):
	dictionary_drop_down.clear()
	for dictionary in dictionaries.language_index[language]:
		dictionary_drop_down.add_item(dictionary.name, dictionary.id)
		pass
	pass



func _on_LanguageOptionButton_item_selected( ID ):
	var language = language_drop_down.get_item_text(ID)
	populate_alphabets(language)
	populate_dictionaries(language)
	pass



func _on_BackButton_pressed():
	get_tree().change_scene("res://Menu.tscn")
	pass


func _on_ConfirmButton_pressed():
	var dictionary = dictionaries.get_dictionary_by_id(dictionary_drop_down.get_selected_ID())
	var alphabet = alphabets.get_alphabet_by_id(alphabet_drop_down.get_selected_ID())
	var game = load("res://Game.tscn").instance()
	game.init(alphabet, dictionary, "new_game")
	get_tree().get_root().add_child(game)
	get_tree().change_scene_to(game)
	pass
