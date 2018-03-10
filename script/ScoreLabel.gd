extends "res://script/FitWidthLabel.gd"

export(float) var MinStep = 1
export(float) var UpdateSpeed = 10

var score = 0
var temp_score = 0

func _ready():
	set_text_and_adjust_size("0")
	set_fixed_process(true)
	pass

func set_score(value):
	score = value
	pass

func _fixed_process(delta):
	if (temp_score == score):
		return
		pass
	
	var step = float(score - temp_score) * delta * UpdateSpeed
	if (step < MinStep):
		step = MinStep
		pass
	temp_score += int(step)
	
	if (temp_score > score):
		temp_score = score
		pass
	
	set_text_and_adjust_size(score_to_string())
	
	pass

func score_to_string():
	var score_str = str(temp_score)
	var score_length = score_str.length()
	var comas = floor(score_length/3)
	for i in range(0, comas - (1 if comas * 3 == score_length else 0)):
		score_str = score_str.insert(score_length - (i + 1) * 3, ",")
		pass
	return score_str
	pass