extends Node2D

var name
var score

func _ready():
	get_node("NameLabel").set_text_and_adjust_size(name)
	get_node("ScoreLabel").set_score(score)
	pass

func init(_name, _score):
	name = _name
	score = _score
	pass