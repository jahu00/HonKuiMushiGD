extends Node2D

var animation
export(bool)var Shown = true

var word_label
var points_label

func _ready():
	animation = get_node("AnimationPlayer")
	animation.play("Default")
	word_label = get_node("WordLabel")
	points_label = get_node("PointsLabel")
	pass

func show_word(text, points, color):
	word_label.set_text_and_adjust_size(text)
	points_label.set_text(points)
	word_label.set("custom_colors/font_color", color)
	points_label.set("custom_colors/font_color", color)
	a_show()
	pass

func a_show():
	if (!Shown):
		animation.play("Show")
		Shown = true
		pass
	pass

func a_hide():
	if (Shown):
		animation.play("Hide")
		Shown = false
		pass
	pass