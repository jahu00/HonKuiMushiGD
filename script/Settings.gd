extends Node

var languages
var fonts
var settings
var main

var language_list
var font_list

func _ready():
	main = Globals.get("Main")
	settings = Globals.get("Settings")
	languages = Globals.get("Languages")
	fonts = Globals.get("Fonts")
	language_list = get_node("LanguageList")
	font_list = get_node("FontList")
	font_list.init(funcref(self, "_on_FontList_item_selected"))
	populate_fonts()
	language_list.init(funcref(self, "_on_LanguageList_item_selected"))
	populate_languages()
	pass

func populate_languages():
	for language in languages.array:
		language_list.add_item_object(language.name, language.name)
		pass
	language_list.select_first()
	pass

func populate_fonts():
	for font in fonts.array:
		font_list.add_item_object(font.name, font.name)
		pass
	pass

func _on_LanguageList_item_selected(language):
	if (settings.fonts.has(language) && font_list.has_value(settings.fonts[language])):
		font_list.select_value(settings.fonts[language])
		return
		pass
	font_list.select_first()
	pass

func _on_FontList_item_selected(font):
	var language = language_list.get_selected_value()
	settings.fonts[language] = font
	pass

func _on_SaveButton_pressed():
	main.save_settings()
	get_tree().change_scene("res://Menu.tscn")
	pass
