extends Node

var UserDir

var main

func _ready():
	UserDir = Globals.get("UserDir")
	main = Globals.get("Main")
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
	main.set_scene_from_path("res://NewGame.tscn")
	pass


func _on_Continue_pressed():
	var game = load("res://Game.tscn").instance()
	game.init(null, null, null, "load_game")
	main.set_scene(game)
	pass


func _on_HighScore_pressed():
	main.set_scene_from_path("res://HighScore.tscn")
	pass


func _on_Settings_pressed():
	main.set_scene_from_path("res://Settings.tscn")
	pass
