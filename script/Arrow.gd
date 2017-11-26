extends Node2D

var sprite
var shadow

func _ready():
	sprite = get_node("Sprite")
	shadow = get_node("Shadow")
	pass

func rotate(angle):
	sprite.set_rot(angle)
	shadow.set_rot(angle)
	pass
