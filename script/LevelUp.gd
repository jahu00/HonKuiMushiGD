extends Node2D

var hiding = false
var showing = true

var animation
var levelLabel
var tile_stats

var level
var stats
var game

var tile_size

var TileStat = preload("res://TileStat.tscn")

func _ready():
	tile_size = Globals.get("TileSize")
	animation = get_node("AnimationPlayer")
	animation.play("Default")
	levelLabel = get_node("Popup/LevelLabel")
	levelLabel.set_text("Chapter " + str(level))
	get_node("Popup/BestWordLabel").set_text(stats.best_word.word.to_upper())
	get_node("Popup/BestWordScoreLabel").set_score(stats.best_word.points)
	get_node("Popup/LongestWordLabel").set_text(stats.longest_word.to_upper())
	get_node("Popup/LongestWordScoreLabel").set_text(str(stats.longest_word.length()) + " LETTERS")
	prepare_tile_stats()
	prepare_letter_stats()
	a_show()
	set_fixed_process(true)
	pass

func init(_game, _level, _stats):
	game = _game
	level = _level
	stats = _stats
	pass

func prepare_tile_stats():
	var tile_index = []
	for tile_name in stats.tile_stats:
		if (tile_index.size() == 0):
			tile_index.append(tile_name)
			continue
			pass
		for i in range(0, tile_index.size()):
			if (stats.tile_stats[tile_name] > stats.tile_stats[tile_index[i]]):
				tile_index.insert(i, tile_name)
				break
				pass
			if (i == tile_index.size() - 1):
				tile_index.append(tile_name)
				pass
			pass
		pass
	var i = 0
	for tile_name in tile_index:
		var tile_stat = TileStat.instance()
		tile_stat.init(tile_name, stats.tile_stats[tile_name])
		tile_stat.set_pos(Vector2(i % 3 * tile_size * 0.75, floor(i / 3) * tile_size * 1))
		get_node("Popup/TileStats").add_child(tile_stat)
		i += 1
		pass
	pass

func prepare_letter_stats():
	var letter_index = []
	for letter_name in stats.letter_stats:
		if (letter_index.size() == 0):
			letter_index.append(letter_name)
			continue
			pass
		for i in range(0, letter_index.size()):
			if (stats.letter_stats[letter_name] > stats.letter_stats[letter_index[i]]):
				letter_index.insert(i, letter_name)
				break
				pass
			if (i == letter_index.size() - 1):
				letter_index.append(letter_name)
				pass
			pass
		pass
	var i = 0
	for letter_name in letter_index:
		var tile_stat = TileStat.instance()
		tile_stat.init("Tile", stats.letter_stats[letter_name], letter_name)
		tile_stat.set_pos(Vector2(i % 3 * tile_size * 0.75, floor(i / 3) * tile_size * 1))
		get_node("Popup/LetterStats").add_child(tile_stat)
		i += 1
		if (i >= 15):
			break
			pass
		pass
	pass

func a_hide():
	if (!hiding):
		hiding = true
		animation.play("Hide")
		pass
	pass

func a_show():
	animation.play("Show")
	pass

func _on_AnimationPlayer_finished():
	if (animation.get_current_animation() == "Show"):
		showing = false
		pass
	if (animation.get_current_animation() == "Hide"):
		game.finish_leveling_up()
		queue_free()
		pass
	pass # replace with function body

func _fixed_process(delta):
	#for some reason input_event didn't work
	if (Input.is_action_pressed("ui_click") && !hiding && !showing):
		a_hide()
		pass
	pass

#func _on_LevelUp_input_event( viewport, event, shape_idx ):
#	if (event.type == InputEvent.MOUSE_BUTTON):
#		if (event.is_pressed() && !hiding && !showing):
#			a_hide()
#			pass
#		pass
#	pass # replace with function body
