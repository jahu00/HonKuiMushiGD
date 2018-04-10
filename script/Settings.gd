extends Node

var languages
var fonts
var settings
var main

var language_list
var tile_font_list
var word_font_list
var language_fonts

func _ready():
	main = Globals.get("Main")
	settings = Globals.get("Settings")
	languages = Globals.get("Languages")
	fonts = Globals.get("Fonts")
	language_list = get_node("LanguageList")
	tile_font_list = get_node("TileFontList")
	word_font_list = get_node("WordFontList")
	populate_fonts()
	tile_font_list.init(funcref(self, "_on_TileFontList_item_selected"))
	word_font_list.init(funcref(self, "_on_WordFontList_item_selected"))
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
		tile_font_list.add_item_object(font.name, font.name)
		word_font_list.add_item_object(font.name, font.name)
		pass
	pass

func _on_LanguageList_item_selected(language):
	language_fonts = main.get_fonts_for_language(language)
	if (language_fonts.has("tile_font") && tile_font_list.has_value(language_fonts.tile_font)):
		tile_font_list.select_value(language_fonts.tile_font)
		pass
	else:
		tile_font_list.select_value(fonts.default_font_1.name)
		pass
	
	if (language_fonts.has("word_font") && word_font_list.has_value(language_fonts.word_font)):
		word_font_list.select_value(language_fonts.word_font)
		pass
	else:
		word_font_list.select_value(fonts.default_font_2.name)
		pass
	pass

func _on_TileFontList_item_selected(font):
	#var language = language_list.get_selected_value()
	#if (!settings.fonts.has(language)):
	#	settings.fonts[language] = {}
	#	pass
	#settings.fonts[language].tile_font = font
	language_fonts.tile_font = font
	save_font_settings()
	pass

func _on_WordFontList_item_selected(font):
	#var language = language_list.get_selected_value()
	#if (!settings.fonts.has(language)):
	#	settings.fonts[language] = {}
	#	pass
	#settings.fonts[language].word_font = font
	language_fonts.word_font = font
	save_font_settings()
	pass

func save_font_settings():
	var language = language_list.get_selected_value()
	main.set_fonts_for_language(language, language_fonts)
	pass

func _on_SaveButton_pressed():
	#main.save_settings()
	main.set_scene_from_path("res://Menu.tscn")
	pass
