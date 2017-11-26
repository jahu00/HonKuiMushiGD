extends "res://script/FitWidthLabel.gd"

var animation
export(bool)var Shown = true

func _ready():
	animation = get_node("AnimationPlayer")
	animation.play("Default")
	pass

func show_text(text):
	set_text_and_adjust_size(text)
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