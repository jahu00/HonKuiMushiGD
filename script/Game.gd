extends Node

var playfield
var sidebar
var score_label
var word_block
var level_label
var submit_button
var progress_bar

var tile_factory
var columns = []

var selected_tiles = []
var score = 0
var level = 1
#var next_level = 100
var next_level = 3000
var last_level = 0
var flame_chance = 0.0
var word = ""
var stats = { "word_stats": {}, "tile_count": 0, "tile_stats": {}, "best_word": {"word": "", "points": 0}, "longest_word": "", "letter_stats": {} }
var bonus_tiles_to_insert = []
var bonus_tile_index = {}
var tile_add_index = 0

#var language_key

var alphabet
var dictionary

var width = 7
var height = 8

var can_submit = false
#var animating = false
var game_over = false
var leveling_up = false

var status = "awaiting_move"
var animated_columns = 0

var Column = preload("res://Column.tscn")
var Tile = preload("res://Tile.tscn")
var LevelUp = preload("res://LevelUp.tscn")
var TileFactory = preload("res://TileFactory.tscn")

var init_operation

#var Alphabet = preload("res://script/Alphabet.gd")
#var _Dictionary = preload("res://script/Dictionary.gd")

var tile_size
var languages
var dictionaries
var alphabets
var settings
var fonts

var load_data

func _ready():
	tile_size = Globals.get("TileSize")
	
	fonts = Globals.get("Fonts")
	languages = Globals.get("Languages")
	dictionaries = Globals.get("Dictionaries")
	alphabets = Globals.get("Alphabets")
	
	settings = Globals.get("Settings")
	playfield = get_node("Playfield")
	sidebar = get_node("Sidebar")
	score_label = get_node("SideBar/ScoreLabel")
	#word_label = get_node("SideBar/WordLabel")
	word_block = get_node("SideBar/WordBlock")
	level_label = get_node("SideBar/LevelLabel")
	#points_label = get_node("SideBar/WordLabel/PointsLabel")
	submit_button = get_node("SideBar/SubmitButton")
	progress_bar = get_node("SideBar/ProgressBar")
	progress_bar.set_progress(0.0)
	tile_factory = TileFactory.instance()
	add_columns()
	if (init_operation == "new_game"):
		new_game()
		pass
	if (init_operation == "load"):
		load_game()
		pass
	pass

func add_columns():
	for i in range(0,width):
		var new_column = Column.instance()
		new_column.init(self, i, height - 1 if i % 2 == 0 else height, true if i % 2 == 0 else false)
		new_column.set_pos(Vector2(i * tile_size, 0))
		playfield.add_child(new_column)
		columns.append(new_column)
		pass
	pass

func init(_alphabet, _dictionary, _init_operation, _load_data = null):
	alphabet = _alphabet
	dictionary = _dictionary
	init_operation = _init_operation
	load_data = _load_data
	#alphabet = Alphabet.new(settings.alphabet)
	#dictionary = _Dictionary.new(settings.dictionary)
	
	#new_game()
	
	pass

func fill_playfield(_status):
	for i in range(0,width):
		var column = columns[i]
		column.fill()
		#if (column.should_animate()):
		animated_columns += 1
		column.animate()
		status = _status#"animating_playfield"
#			animating = true
		#	pass
		pass
	status = _status
	pass

func new_game():
	fill_playfield("new_game_fill")
	pass

func get_tile(requesting_column):
	var new_tile
	if (bonus_tile_index.has(tile_add_index)):
		new_tile = tile_factory.get_node(bonus_tile_index[tile_add_index]).duplicate()
		bonus_tile_index.erase(tile_add_index)
		pass
	elif (rand_range(0.0, 1.0) < flame_chance):
		new_tile = tile_factory.get_node("Flame").duplicate()
		pass
	else:
		new_tile = tile_factory.get_node("Tile").duplicate()
		pass
	#Tile.instance()
	var letter = alphabet.get_random_letter()
	new_tile.init(requesting_column, letter.letter, "moving", letter.points)
	tile_add_index += 1
	return new_tile

func column_stopped(column):
	column.update_burning()
	animated_columns -= 1
	if (animated_columns == 0):
		#status = "awaiting_move";
#		animating = false

		if (status == "post_submit_fill"):
			burn()
			pass
		elif (status == "burning_tiles"):
			fill_playfield("post_burn_fill")
			pass
		elif (status == "post_burn_fill" || status == "new_game_fill"):
			if (bonus_tiles_to_insert.size() > 0):
				insert_bonus_tiles()
				pass
			else:
				status = "awaiting_move"
				pass
			pass
		elif (status == "insert_bonus_tiles"):
			status = "awaiting_move"
			pass
		pass
	#print(status + " " + str(animated_columns))
	pass

func insert_bonus_tiles():
	status = "insert_bonus_tiles"
	var tile_pool = []
	for column in columns:
		for tile in column.tiles:
			if (tile.Name == "Tile"):
				tile_pool.append(tile)
				pass
			pass
		pass
	if (tile_pool.size() == 0):
		status = "awaiting_move"
		return
		pass
	for bonus_tile_to_insert in bonus_tiles_to_insert:
		if (tile_pool.size() == 0):
			break
			pass
		var tile_index = rand_range(0, tile_pool.size())
		var old_tile = tile_pool[tile_index]
		var new_tile = tile_factory.get_node(bonus_tile_to_insert).duplicate()
		new_tile.init_from_tile(old_tile, "moving")
		tile_pool.remove(tile_index)
		old_tile.replace(new_tile)
		pass
	for column in columns:
		if (column.status == "replacing"):
			animated_columns += 1
			pass
		pass
	pass

func mark_tiles_to_burn():
	for column in columns:
		column.mark_tiles_to_burn()
		pass
	pass

func burn():
	for column in columns:
		column.burn()
		#if (column.burn()):
		animated_columns += 1
		column.animate_burn()
			
#			animating = true
#			pass
		pass
	status = "burning_tiles"
	pass

func can_select():
	#return !animating && !game_over && !leveling_up
	return status == "awaiting_move" && !game_over && !leveling_up
	pass

func compute_points():
	var points = 0
	var bonus = 0
	for tile in selected_tiles:
		points += tile.points;
		bonus += tile.Bonus;
		pass
	points += level;
	return points * 10 * (selected_tiles.size() + bonus);
	pass

#func update_score():
#	var score_str = str(score)
#	var score_length = score_str.length()
#	var comas = floor(score_length/3)
#	for i in range(0, comas - (1 if comas * 3 == score_length else 0)):
#		score_str = score_str.insert(score_length - (i + 1) * 3, ",")
#		pass
#	score_label.set_text_and_adjust_size(score_str)
#	pass

func update_word():
	word = ""
	for tile in selected_tiles:
		word += tile.letter.to_lower()
		pass
	
	var lookup_result = []
	if (word != "" && word.length() > 2):
		var time_before = OS.get_ticks_msec()
		lookup_result = dictionary.lookup(word, true)
		var total_time = OS.get_ticks_msec() - time_before
		print("Time taken: " + str(total_time))
		pass
	
	var points = ""
	var word_found = lookup_result.size() > 0
	if (word_found):
		points = str(compute_points())
		pass
	
	if (word.length() > 0):
		var word_color = Color(255,255,255)
		var best_tile_bonus = 0 
		for tile in selected_tiles:
			if (tile.Flame):
				word_color = tile.WordColor
				break
				pass
			if (tile.Bonus > best_tile_bonus):
				best_tile_bonus = tile.Bonus
				word_color = tile.WordColor
				pass
			pass
		word_block.show_word(word.to_upper(), points, word_color)
		level_label.a_hide()
		pass
	else:
		word_block.a_hide()
		level_label.a_show()
		pass
	submit_button.set_flashing(word_found)
	can_submit = word_found
	pass

func try_select_tile(tile):
	var last_tile_index = selected_tiles.size() - 1
	
	# if no tiles are selected, select this one
	if (last_tile_index == -1):
		tile.select()
		selected_tiles.append(tile)
		#update_word()
		return
		pass
	
	# if it's the last selected tile, deselect it
	var tile_index = selected_tiles.find(tile)
	if (last_tile_index == tile_index):
		if (can_submit):
			submit_word()
			return
			pass
		selected_tiles.remove(last_tile_index);
		tile.deselect()
		#update_word()
		return
		pass
	
	# if it's one of selected tiles, deselect all further selected tiles
	if (tile_index > -1):
		for i in range(last_tile_index, tile_index, -1):
			selected_tiles[i].deselect()
			selected_tiles.remove(i)
			pass
		#update_word()
		return
		pass
	
	# if the tile is adjecent to the last one, select it
	var last_tile = selected_tiles[last_tile_index]
	var distance_from_last_tile = last_tile.get_global_pos() - tile.get_global_pos()
	if (abs(distance_from_last_tile.x) <= tile_size && abs(distance_from_last_tile.y) <= tile_size):
		tile.select()
		tile.show_arrow(last_tile)
		selected_tiles.append(tile)
		#update_word()
		return
		pass
	
	# if the tile is not adjecent to the last one, deselect all tiles and select this one
	for i in range(0, selected_tiles.size()):
		selected_tiles[0].deselect()
		selected_tiles.remove(0)
		#update_word()
		pass
	
	tile.select()
	selected_tiles.append(tile)
	#update_word()
	pass

func submit_word():
	flame_chance = compute_flame_chance(word)
	if (word.length() > stats.longest_word.length()):
		stats.longest_word = word;
		pass
	#word = ""
	var can_submit = false
	submit_button.set_flashing(false)
	var points_to_add = compute_points()
	if (points_to_add > stats.best_word.points):
		stats.best_word.word = word
		stats.best_word.points = points_to_add
		pass
	score += points_to_add
	if (!stats.word_stats.has(word.length())):
		stats.word_stats[word.length()] = 1
		pass
	else:
		stats.word_stats[word.length()] += 1
		pass
	
	var bonus_tiles_to_add = []
	bonus_tiles_to_insert = []
	bonus_tile_index = {}
	if (word.length() >= 8 || word.length() > 3 && stats.word_stats[word.length()] % (8 - word.length()) == 0):
			bonus_tiles_to_add.append("Green")
			pass
	
	if (word.length() < 7 && word.length() > 4 && stats.word_stats[word.length()] % (8 - word.length()) == 1):
			bonus_tiles_to_insert.append("Gold")
			pass
	
	if (word.length() >= 8 || word.length() > 6 && stats.word_stats[word.length()] % (8 - word.length()) == 1):
			bonus_tiles_to_insert.append("Dimond")
			pass
	
	if (bonus_tiles_to_add.size() > 0):
		var tile_index = []
		for i in range(0, word.length()):
			tile_index.append(i)
			pass
		for bonus_tile_to_add in bonus_tiles_to_add:
			if (tile_index.size() == 0):
				break
				pass
			var selected_index = rand_range(0, tile_index.size())
			#bonus_tiles_to_add.index = tile_index[selected_index]
			bonus_tile_index[tile_index[selected_index]] = bonus_tile_to_add
			tile_index.remove(selected_index)
			pass
		pass
	
	word = ""
	#update_score()
	score_label.set_score(score)
	update_progress_bar()
	
	stats.tile_count += selected_tiles.size()
	
	for tile in selected_tiles:
		if(!stats.tile_stats.has(tile.Name)):
			stats.tile_stats[tile.Name] = 1
			pass
		else:
			stats.tile_stats[tile.Name] += 1
			pass
		if(!stats.letter_stats.has(tile.letter)):
			stats.letter_stats[tile.letter] = 1
			pass
		else:
			stats.letter_stats[tile.letter] += 1
			pass
		tile.destroy()
		pass
	selected_tiles = []
	if (score > next_level):
		level_up()
		pass
	word_block.a_hide()
	level_label.a_show()
	mark_tiles_to_burn()
	tile_add_index = 0
	fill_playfield("post_submit_fill")
	pass

func compute_flame_chance(word):
	var result = (19.0 + level) / pow(10, word.length() - 1)
	if (result > 1):
		result = 1
		pass
	if (result < 0):
		result = 0
		pass
	return result
	pass

func update_progress_bar():
	var progress = (score - last_level) / (next_level - last_level)
	if (progress > 1):
		progress = 1
		pass
	progress_bar.set_progress(progress)
	pass

func level_up():
	leveling_up = true
	level += 1
	last_level = next_level
	level_label.set_text("Level " + str(level))
	next_level = next_level + 3000 + (level - 1) * 1000
	var popup = LevelUp.instance()
	popup.init(self, level, stats)
	add_child(popup)
	pass

func finish_leveling_up():
	leveling_up = false
	update_progress_bar()
	pass

func game_over():
	game_over = true
	print("GAME OVER")
	pass

func _on_SubmitButton_pressed():
	if (can_submit):
		submit_word()
		pass
	pass # replace with function body

func serialize():
	var result = {}
	result.dictionary = dictionary.dictionary_settings.name
	result.alphabet = alphabet.alphabet_settings.name
	result.stats = stats
	result.level = level
	result.score = score
	result.last_level = last_level
	result.next_level = next_level
	result.selected_tiles = []
	for selected_tile in selected_tiles:
		result.selected_tiles.append({ "row": selected_tile.id, "col": selected_tile.column.id })
		pass
	result.columns = []
	for column in columns:
		var serialized_column = []
		for tile in column.tiles:
			serialized_column.append(tile.serialize())
			pass
		result.columns.append(serialized_column)
		pass
	return result
	pass

func save_game():
	var f = File.new()
	f.open("user://save.json", File.WRITE)
	f.store_string(serialize().to_json())
	f.close()
	pass

func _on_MenuButton_pressed():
	save_game()
	get_tree().change_scene("res://Menu.tscn")
	queue_free()
	pass # replace with function body
