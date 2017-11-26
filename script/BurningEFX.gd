extends Node2D

func _ready():
	get_node("AnimationPlayer").play("Blink")
	pass
