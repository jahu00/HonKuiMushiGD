extends Node

func _ready():
	pass



func _on_Exit_pressed():
	get_tree().quit()
	pass # replace with function body


func _on_NewGame_pressed():
	get_tree().change_scene("res://NewGame.tscn")
	pass # replace with function body
