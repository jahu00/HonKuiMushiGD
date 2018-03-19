extends Node

var UserDir

var save_game_path = "user://save.json"

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

var main
var language
var alphabet
var dictionary

var alphabet_id
var dictionary_id

var width = 7
var height = 8

var can_submit = false
#var animating = false
var game_over = false
var leveling_up = false
#var loading = true

var status = "awaiting_move"
var animated_columns = 0

var Column = preload("res://Column.tscn")
var Tile = preload("res://Tile.tscn")
var LevelUp = preload("res://LevelUp.tscn")
var TileFactory = preload("res://TileFactory.tscn")
var LoadingScreen = preload("res://Loading.tscn")
var HighScoreScreen = preload("res://HighScore.tscn")

var init_operation

#var Alphabet = preload("res://script/Alphabet.gd")
#var _Dictionary = preload("res://script/Dictionary.gd")

var tile_size
var languages
var dictionaries
var alphabets
var settings
var fonts

var tile_font_data
var word_font_data

var load_data

var load_thread

func _ready():
	start_loading();
	UserDir = Globals.get("UserDir")
	tile_size = Globals.get("TileSize")
	main = Globals.get("Main")
	fonts = Globals.get("Fonts")
	languages = Globals.get("Languages")
	dictionaries = Globals.get("Dictionaries")
	alphabets = Globals.get("Alphabets")
	
	settings = Globals.get("Settings")
	playfield = get_node("Playfield")
	sidebar = get_node("SideBar")
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
	#end_loading()
	if (init_operation == "load_game"):
		load_game_data()
		dictionary_id = load_data.dictionary
		alphabet_id = load_data.alphabet
		language = load_data.language
		pass
	
	tile_font_data = main.get_font_data(language, "tile_font")
	word_font_data = main.get_font_data(language, "word_font")
	
	#all tiles share the same font, so I only need to set tile font once
	tile_factory.get_node("Tile/Letter").get("custom_fonts/font").set_font_data(tile_font_data)
	word_block.get_node("WordLabel").get("custom_fonts/font").set_font_data(word_font_data)
	
	load_thread = Thread.new()
	load_thread.start(self, "load_dictionary", 1)
	#load_dictionary()
	pass

func start_loading():
	var loading_screen = LoadingScreen.instance()
	get_node("Overlay").add_child(loading_screen)
	pass

func load_dictionary(dummy):
	dictionary = dictionaries.get_dictionary_by_id(dictionary_id)
	alphabet = alphabets.get_alphabet_by_id(alphabet_id)
	call_deferred("end_loading")
	pass

func end_loading():
	load_thread.wait_to_finish()
	var loading_screen = get_node("Overlay/Loading")
	if (loading_screen != null):
		loading_screen.queue_free()
		pass
	if (init_operation == "new_game"):
		#call_deferred("new_game")
		new_game()
		pass
	if (init_operation == "load_game"):
		resume_game();
		#load_game()
		#call_deferred("load_game")
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

func init(_language, _alphabet_id, _dictionary_id, _init_operation):
	alphabet_id = _alphabet_id
	dictionary_id = _dictionary_id
	init_operation = _init_operation
	language = _language
	#new_game()
	
	pass

func fill_playfield(_status, data = null):
	set_status(_status)
	for i in range(0,width):
		var column = columns[i]
		var column_data = null
		if (data != null):
			column_data = data[i]
			pass
		column.fill(column_data)
		#if (column.should_animate()):
		animated_columns += 1
		column.animate()
		#status = _status#"animating_playfield"
#			animating = true
		#	pass
		pass
	#status = _status
	pass

func new_game():
	fill_playfield("new_game_fill")
	pass

func load_game_data():
	var f = File.new()
	f.open(save_game_path, File.READ)
	var json_str  = f.get_as_text()
	load_data = {}
	load_data.parse_json(json_str)
	f.close()
	pass

func resume_game():
	stats = load_data.stats
	level = load_data.level
	update_level()
	score = load_data.score
	last_level = load_data.last_level
	next_level = load_data.next_level
	update_score()
	update_progress_bar()
#	result.selected_tiles = []
#	for selected_tile in selected_tiles:
#		result.selected_tiles.append({ "row": selected_tile.id, "col": selected_tile.column.id })
#		pass
#	result.columns = []
	fill_playfield("load_game_fill", load_data.columns)
	
	pass

func get_tile(requesting_column, data = null, tile_name = null):
	var new_tile
	var tile_status = "moving"
	if (data != null):
		new_tile = tile_factory.get_node(data.name).duplicate()
		new_tile.init(requesting_column, data.letter, tile_status, data.points)
		return new_tile
		pass
	elif (bonus_tile_index.has(tile_add_index)):
		#new_tile = tile_factory.get_node(bonus_tile_index[tile_add_index]).duplicate()
		tile_name = bonus_tile_index[tile_add_index]
		bonus_tile_index.erase(tile_add_index)
		pass
	elif (tile_name == null && rand_range(0.0, 1.0) < flame_chance):
		tile_name = "Flame"
		pass
	elif (tile_name == null):
		tile_name = "Tile"
		pass
	#Tile.instance()
	new_tile = tile_factory.get_node(tile_name).duplicate()
	var letter = alphabet.get_random_letter()
	new_tile.init(requesting_column, letter.letter, tile_status, letter.points, "Default")#, font_data)
	tile_add_index += 1
	return new_tile

func await_move():
	#status = "awaiting_move"
	set_status("awaiting_move")
	if (game_over):
		show_level_up_popup("The End")
		pass
	pass

func set_status(_status):
	status = _status
	#print(status)
	pass

func column_stopped(column):
	if (status == "shuffle"):
		column.index_tiles()
		column.mark_tiles_to_burn()
		pass
	column.update_burning()
	animated_columns -= 1
	#print(str(animated_columns))
	if (animated_columns == 0):
		#status = "awaiting_move";
#		animating = false

		if (status == "post_submit_fill"):
			burn()
			pass
		elif (status == "shuffle"):
			burn()
			#fill_playfield("post_submit_fill")
			pass
		elif (status == "burning_tiles"):
			fill_playfield("post_burn_fill")
			pass
		elif (status == "new_game_fill"):
			await_move()
			pass
		elif (status == "post_burn_fill"):
			if (bonus_tiles_to_insert.size() > 0):
				insert_bonus_tiles()
				pass
			else:
				await_move()
				pass
			pass
		elif (status == "load_game_fill"):
			for selected_tile in load_data.selected_tiles:
				try_select_tile(columns[selected_tile.col].tiles[selected_tile.row])
				pass
			update_word()
			await_move()
		elif (status == "insert_bonus_tiles"):
			await_move()
			pass
		pass
	#print(status + " " + str(animated_columns))
	pass

func insert_bonus_tiles():
	#status = "insert_bonus_tiles"
	set_status("insert_bonus_tiles")
	var tile_pool = []
	for column in columns:
		for tile in column.tiles:
			if (tile.Name == "Tile"):
				tile_pool.append(tile)
				pass
			pass
		pass
	if (tile_pool.size() == 0):
		#status = "awaiting_move"
		await_move()
		return
		pass
	for bonus_tile_to_insert in bonus_tiles_to_insert:
		if (tile_pool.size() == 0):
			break
			pass
		var tile_index = rand_range(0, tile_pool.size())
		var old_tile = tile_pool[tile_index]
		var new_tile = tile_factory.get_node(bonus_tile_to_insert).duplicate()
		new_tile.init_from_tile(old_tile, "moving")#, font_data)
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
	set_status("burning_tiles")
	for column in columns:
		column.burn()
		#if (column.burn()):
		animated_columns += 1
		column.animate_burn()
			
#			animating = true
#			pass
		pass
	#status = "burning_tiles"
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

func clear_bonus_tiles():
	bonus_tiles_to_insert = []
	bonus_tile_index = {}
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
	clear_bonus_tiles()
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
	update_score()
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

func update_score():
	score_label.set_score(score)
	pass

func update_progress_bar():
	var progress = (score - last_level) / (next_level - last_level)
	if (progress > 1):
		progress = 1
		pass
	progress_bar.set_progress(progress)
	pass

func update_level():
	level_label.set_text("Level " + str(level))
	pass

func show_level_up_popup(text):
	var popup = LevelUp.instance()
	popup.init(self, text, stats, language)
	add_child(popup)
	pass

func level_up():
	level += 1
	last_level = next_level
	update_level()
	next_level = next_level + 3000 + (level - 1) * 1000
	if (!game_over):
		leveling_up = true
		show_level_up_popup("Chapter " + str(level))
		pass
	pass

func go_to_highscore():
	var highScore = HighScoreScreen.instance()
	highScore.init_from_score(language, score, stats)
	main.set_scene(highScore)
	pass

func finish_leveling_up():
	leveling_up = false
	if (game_over):
		end_game()
		#go_to_menu()
		go_to_highscore()
		pass
	else:
		update_progress_bar()
		pass
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
	result.dictionary = dictionary.dictionary_settings.id#name
	result.alphabet = alphabet.alphabet_settings.id#name
	result.language = language
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
	f.open(save_game_path, File.WRITE)
	f.store_string(serialize().to_json())
	f.close()
	pass

func end_game():
	if (UserDir.file_exists("save.json")):
		UserDir.remove(save_game_path)
		pass
	pass


func _on_MenuButton_pressed():
	if (can_select()):
		save_game()
		main.set_scene_from_path("res://Menu.tscn")
		pass
	pass

func shuffle():
	tile_add_index = 0
	clear_bonus_tiles()
	var flame_tile_column = -1
	var flame_column_index = []
	for column in columns:
		if (!column.tiles[0].Flame):
			flame_column_index.append(column.id)
			pass
		pass
	
	if (flame_column_index.size() > 0):
		flame_tile_column = flame_column_index[rand_range(0, flame_column_index.size())]
		pass
	
	for column in columns:
		for tile in column.tiles:
			if (tile.ignore || tile.Flame):
				continue
				pass
			var new_tile
			var tile_name = "Tile"
			if (tile.id == 0 && (rand_range(0, 14) <= 1 || column.id == flame_tile_column)):
				tile_name = "Flame"
				new_tile = tile_factory.get_node(tile_name).duplicate()
				new_tile.init_from_tile(tile, "moving")
				pass
			else:
				new_tile = get_tile(column, null, tile_name)
				pass
			if (!new_tile.Flame && tile.burning):
				#new_tile.burning = true
				new_tile.set_burning(true)
				pass
			tile.replace(new_tile)
			pass
		pass
		if (column.status == "replacing"):
			animated_columns += 1
			pass
		pass
	
	if (animated_columns > 0):
		#status = "shuffle"
		set_status("shuffle")
		pass
	else:
		burn()
		pass
	pass

func _on_ShuffleButton_pressed():
	if (can_select()):
		shuffle()
		pass
	pass # replace with function body
