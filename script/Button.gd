extends TextureButton

export(bool) var Flashing = false

var animation

func _ready():
	animation = get_node("AnimationPlayer")
	set_flashing(Flashing)
	pass

func set_flashing(value):
	Flashing  = value
	if (Flashing == true):
		animation.play("Flashing")
		pass
	else:
		animation.play("Default")
		pass
	pass

func _on_SubmitButton_mouse_enter():
	if (is_pressed()):
		return
		pass
	
	if (Flashing == true):
		animation.play("FlashingHover")
		pass
	else:
		animation.play("Hover")
		pass
	pass # replace with function body


func _on_SubmitButton_mouse_exit():
	if (is_pressed()):
		return
		pass
	
	if (Flashing == true):
		animation.play("Flashing")
		pass
	else:
		animation.play("Default")
		pass
	pass # replace with function body


func _on_SubmitButton_button_down():
	animation.play("Default")
	pass # replace with function body


func _on_SubmitButton_button_up():
	if (Flashing == true):
		animation.play("Flashing")
		pass
	else:
		animation.play("Default")
		pass
	pass # replace with function body
