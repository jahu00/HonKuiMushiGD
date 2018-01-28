extends Node2D

var hiding = false
var showing = true

var animation
var high_score_container

#var level
var title
var stats
#var game

var tile_size

var HighScoreRow = preload("res://HighScoreRow.tscn")

func _ready():
	animation = get_node("AnimationPlayer")
	animation.play("Default")
	high_score_container = get_node("Popup/HighScoreContainer")
	
	get_node("Popup/TitleLabel").set_text_and_adjust_size(title.to_upper())
	get_node("Popup/BestWordLabel").set_text_and_adjust_size(stats.best_word.word.to_upper())
	get_node("Popup/BestWordScoreLabel").set_score(stats.best_word.points)
	get_node("Popup/BestWordNameLabel").set_text_and_adjust_size(stats.best_word.name)
	get_node("Popup/LongestWordLabel").set_text_and_adjust_size(stats.longest_word.word.to_upper())
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
func init(_title, _stats):
	#game = _game
	#level = _level
	title = _title
	stats = _stats
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
