extends Node2D

var hiding = false
var showing = true

var animation
var best_word_label
var longest_word_label
var high_score_container

var title
var stats
var language

var main

var font
var font_data

var HighScoreRow = preload("res://HighScoreRow.tscn")

func _ready():
	main = Globals.get("Main")
	animation = get_node("AnimationPlayer")
	animation.play("Default")
	high_score_container = get_node("Popup/HighScoreContainer")
	font_data = main.get_font_data(language, "word_font")
	font = DynamicFont.new()
	font.set_size(32)
	font.set_use_filter(true)
	font.set_font_data(font_data)
	get_node("Popup/TitleLabel").set_text_and_adjust_size(title.to_upper())
	best_word_label = get_node("Popup/BestWordLabel")
	best_word_label.set("custom_fonts/font", font)
	best_word_label.set_text_and_adjust_size(stats.best_word.word.to_upper())
	get_node("Popup/BestWordScoreLabel").set_score(stats.best_word.points)
	get_node("Popup/BestWordNameLabel").set_text_and_adjust_size(stats.best_word.name)
	longest_word_label = get_node("Popup/LongestWordLabel")
	longest_word_label.set("custom_fonts/font", font)
	longest_word_label.set_text_and_adjust_size(stats.longest_word.word.to_upper())
	get_node("Popup/LongestWordScoreLabel").set_text_and_adjust_size(str(stats.longest_word.word.length()) + " LETTERS")
	get_node("Popup/LongestWordNameLabel").set_text_and_adjust_size(stats.longest_word.name)
	populate_high_score()
	a_show()
	#set_fixed_process(true)
	pass

func populate_high_score():
	var i = 0
	for score in stats.high_score:
		var new_row = HighScoreRow.instance()
		new_row.init(score.name, score.score)
		new_row.set_pos(Vector2(0, i * 80))
		high_score_container.add_child(new_row)
		i += 1
		pass
	pass


#func init(_game, _level, _stats):
func init(_title, _stats, _language):
	#game = _game
	#level = _level
	title = _title
	stats = _stats
	language = _language
	pass

func a_hide():
	if (!hiding):
		hiding = true
		animation.play("Hide")
		pass
	pass

func a_show():
	animation.play("Show")
	pass

func _on_AnimationPlayer_finished():
	if (animation.get_current_animation() == "Show"):
		showing = false
		pass
	if (animation.get_current_animation() == "Hide"):
		queue_free()
		pass
	pass # replace with function body

func _fixed_process(delta):
	pass
