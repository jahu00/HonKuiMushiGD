extends Node2D

var id
var max_tiles
var game
var offset

var status = "idle"
var tiles = []
var tiles_to_burn = []
var tiles_that_burn = []

var moving_tiles

var tile_size

func _ready():
	tile_size = Globals.get("TileSize")
	moving_tiles = 0
	set_fixed_process(true)
	pass

func init(_game, _id, _max_tiles, _offset):
	max_tiles = _max_tiles
	game = _game
	id = _id
	offset = _offset
	pass

func fill():
	var child_count = 0
	for child in get_children():
		if child.ignore == true:
			continue
			pass
		child_count += 1
		pass
	
	if (child_count < max_tiles):
		for i in range(0, max_tiles - child_count):
			var new_tile = game.get_tile(self)
			new_tile.set_pos(Vector2(0, tile_size * (i + 2) * -1))
			add_child(new_tile)
			move_child(new_tile, 0)
			pass
		
		index_tiles()
	pass

func _fixed_process(delta):
	if (status == "moving" || status == "burning"):
		
		var previous_tile = null
		var temp_moving_tiles = 0
		for i in range(0, tiles.size()):
			var tile = tiles[tiles.size() - i - 1]
			if (tile.should_move()):
				temp_moving_tiles += 1
				
				var start_y = tile.get_pos().y
				var y = start_y
				var targetY = tile.get_target_y()#floor(tile_size * (tile.id + (0.5 if offset == true else 0.0)))
				
				var speed = tile.get_speed()# * (0.1 if tile.Flame && status == "burning" else 1)
				var tile_that_burns = null
				if (status == "burning"):
					for temp_tile_that_burns in tiles_that_burn:
						if (tile == temp_tile_that_burns.tile):
							tile_that_burns = temp_tile_that_burns
							speed = speed * 0.5
							break;
							pass
						pass
					pass
				
				y = y + speed * delta
				if (y > targetY):
					y = targetY
					pass
				
				if (previous_tile != null && y > previous_tile.get_pos().y - tile_size):
					y = previous_tile.get_pos().y - tile_size
					pass
				
				tile.set_pos(Vector2(0,y))
				
				if (tile_that_burns != null):
					tile_that_burns.burn_length -= y - start_y
					if (tile_that_burns.burn_length <= 0):
						tiles_that_burn.remove(tiles_that_burn.find(tile_that_burns))
						pass
					pass
				
				if (y == targetY):
					temp_moving_tiles -= 1
					pass
				
				pass
			previous_tile = tile
			pass
		moving_tiles = temp_moving_tiles
		if (moving_tiles == 0):
			status = "idle"
			game.column_stopped(self)
			pass
		pass
	
	pass

func mark_tiles_to_burn():
	tiles_to_burn = []
	tiles_that_burn = []
	var previous_tile = null
	for tile in tiles:
		if (tile != null && tile.ignore):
			tile = null
			pass
		
#		if (tile != null && tile.Flame):
#			print("Flame")
#			pass
		
		if (previous_tile != null && tile != null && previous_tile.Flame && !tile.Flame && tile.burning):
			tiles_to_burn.append(tile)
			tiles_that_burn.append({"tile": previous_tile, "burn_length": float(tile_size)})
			pass
		
		if (tile != null && tile.Flame && tile.id == max_tiles - 1):
			game.game_over()
			pass
		
		previous_tile = tile
		pass
	pass

func index_tiles():
	var children = []
	for child in get_children():
		if child.ignore == true:
			continue
			pass
		children.append(child)
		pass
	
	var temp_index = 0
	for i in range(max_tiles - children.size(), max_tiles):
		children[temp_index].id = i;
		temp_index+= 1
		pass
	
	tiles = children
	
	pass

func animate():
	status = "moving"
	pass

func should_animate():
#	var children = get_children()
#	for i in range(0, max_tiles):
#		var child = children[i];
#		if (child.should_move()):
#			child.status = "moving"
#			moving_tiles += 1
#			pass
#		pass
	for tile in tiles:
#		if child.ignore == true:
#			continue
#			pass
		
		if (tile.should_move()):
			#tile.status = "moving"
			#moving_tiles += 1
			return true
			pass
		pass
	#return moving_tiles > 0;
	return false
	pass

func burn():
	var tiles_burnt = false
	for tile in tiles_to_burn:
		if (tile.burn()):
			tiles_burnt = true
			pass
		pass
	if (tiles_burnt):
		index_tiles()
		#tiles_to_burn = []
		pass
	return tiles_burnt
	pass

func animate_burn():
	status = "burning"
	pass

func update_burning():
	var previous_tile = null
	for tile in tiles:#get_children():
#		if (child.ignore == true):
#			continue
#			pass
#		
#		if (previous_tile != null && previous_tile.Flame):
#			print("Flame " + str(child.Flame))
#			print("burning " + str(child.burning))
#			print("should burn " + str(previous_tile.Flame))
#			pass
		
		if (previous_tile != null && !tile.Flame && tile.burning != previous_tile.Flame):
			tile.set_burning(previous_tile.Flame)
			pass
		previous_tile = tile
		pass
	pass

#func tile_stopped():
#	moving_tiles -= 1
#	if (moving_tiles == 0):
#		game.column_stopped(self)
#		pass
#	pass

func replacement_in_process():
	moving_tiles += 1
	status = "replacing"
	pass

func replace_tile(_tile, _replacement):
	var id = tiles.find(_tile)
	var child_id = get_children().find(_tile)
	tiles[id] = _replacement
	add_child(_replacement)
	move_child(_replacement, child_id)
	_replacement.spin_in()
	moving_tiles -= 1
	if (moving_tiles == 0):
		game.column_stopped(self)
		pass
	pass