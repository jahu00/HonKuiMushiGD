extends Node

var UserDir

func _ready():
	UserDir = Globals.get("UserDir")
	if (check_save()):
		get_node("Continue").show()
		pass
	pass

func check_save():
	if (UserDir.file_exists("save.json")):
		return true
		pass
	return false
	pass

func _on_Exit_pressed():
	get_tree().quit()
	pass # replace with function body


func _on_NewGame_pressed():
	get_tree().change_scene("res://NewGame.tscn")
	pass # replace with function body
