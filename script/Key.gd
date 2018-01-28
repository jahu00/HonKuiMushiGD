extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (String) var Text = 'A'

var animation
var clicked = false
var callback = null

func _ready():
	get_node("Label").set_text(Text)
	animation = get_node("AnimationPlayer")
	animation.play("Default")
	connect("input_event", self, "_on_Key_input_event")
	connect("mouse_exit", self, "_on_Key_mouse_exit")
	pass

func init(_text, _callback = null, _font_scale = 1):
	Text = _text
	callback = _callback
	if (_font_scale != 1):
		var font_size = get_node("Label").get("custom_fonts/font").get_size()
		get_node("Label").get("custom_fonts/font").set_size(font_size * _font_scale)
		pass
	pass

func _on_Key_input_event( viewport, event, shape_idx ):
	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.is_pressed()):
			if (!clicked):
				animation.play("KeyDown")
				clicked = true
				if (callback != null):
					callback.call_func(Text)
					pass
				pass
			pass
		elif(clicked):
			animation.play("KeyUp")
			clicked = false;
			pass
		pass
	pass

func _on_Key_mouse_exit():
	if (clicked):
		animation.play("KeyUp")
		clicked = false;
		pass
	pass # replace with function body
