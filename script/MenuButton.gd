extends TextureButton

var animation

func _ready():
	animation = get_node("AnimationPlayer")
	animation.play("Default")
	connect("mouse_enter", self, "_on_mouse_enter")
	connect("mouse_exit", self, "_on_mouse_exit")
	pass

func _on_mouse_enter():
	animation.play("Hover")
	pass


func _on_mouse_exit():
	animation.play("Default")
	pass
