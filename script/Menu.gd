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
	pass


func _on_NewGame_pressed():
	get_tree().change_scene("res://NewGame.tscn")
	pass


func _on_Continue_pressed():
	var game = load("res://Game.tscn").instance()
	game.init(null, null, null, "load_game")
	get_tree().get_root().add_child(game)
	get_tree().change_scene_to(game)
	pass


func _on_HighScore_pressed():
	get_tree().change_scene("res://HighScore.tscn")
	pass


func _on_Settings_pressed():
	get_tree().change_scene("res://Settings.tscn")
	pass
