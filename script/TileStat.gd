extends Node2D

var count = 0
var tile_name = "Tile"
var letter = "A"
#var tile_size

var TileFactory = preload("res://TileFactory.tscn")

func _ready():
	#tile_size = Globals.get("TileSize")
	get_node("CountLabel").set_text(str(count))
	var tile_factory = TileFactory.instance()
	var tile = tile_factory.get_node(tile_name).duplicate()
	tile.init(null, letter, "Stat", 0)
	tile.ignore = true
	#tile.set_pos(Vector2(tile_size * -0.5, tile_size * -0.5))
	tile.set_pos(Vector2(0, 0))
	get_node("TileContainer").add_child(tile)
	pass

func init(_tile_name, _count, _letter = "A"):
	tile_name = _tile_name
	count = _count
	letter = _letter
	pass