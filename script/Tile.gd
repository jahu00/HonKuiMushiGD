extends Area2D

export(int) var MinSpeed = 1000
export(int) var MaxSpeed = 1500
export(int) var RowSpeedIncrease = 50
export(int) var ColSpeedIncrease = 100
export(int) var SpeedSpread = 0# 0.05
export(int) var PointLevels = 3.0
export(int) var Bonus = 0
export(int) var MaxHp = 1
#export(bool) var ShowPonits = true
export(bool) var Flame = false
export(String) var Name = "Tile"
export(Color) var WordColor = Color(255, 255, 255)

#parent column
var column
var game

#tile properties
var letter
var points
var hp
var id

#var speed = MaxSpeed

var ignore = false
var burning = false
var selected = false

var clicked = false

#child nodes
var arrow
var animation

var status
#var adjecency_sensors
#var below_sensor

var replacement

var BurningEFX = preload("res://BurningEFX.tscn")

var tile_size

var starting_animation = "Default"

func _ready():
	tile_size = Globals.get("TileSize")
	hp = MaxHp
	connect("input_event", self, "_on_Tile_input_event")
	animation = get_node("AnimationPlayer")
	animation.connect("finished", self, "_on_AnimationPlayer_finished")
	animation.play(starting_animation)
	set_fixed_process(true)
	pass

func init(_column, _letter, _status, _points, _starting_animation = "Default", _font_data = null):
	column = _column
	if (column != null):
		game = column.game
		pass
	letter = _letter
	var letter_node = get_node("Letter")
	letter_node.set_text(letter.to_upper())
	status = _status
	points = _points
	
	if (_font_data != null):
		letter_node.get("custom_fonts/font").set_font_data(_font_data)
		pass
	
	#speed = MaxSpeed#round(MaxSpeed * (1 + rand_range(-SpeedSpread,SpeedSpread)))
	
#	if (ShowPonits):
#		var point_frame = int(round(points / (10 / PointLevels)))
#		get_node("Points").set_frame(point_frame)
#		pass
#	else:
#		get_node("Points").hide()
#		pass
	
	var point_frame = int(round(points / (10 / PointLevels)))
	get_node("Points").set_frame(point_frame)
	
	arrow = get_node("Arrow")
	#animation = get_node("AnimationPlayer")
	animate(_starting_animation)
	#animation = get_node("AnimationPlayer")
	#animation.play("Default")
	pass

func init_from_tile(_tile, _status, _font_data):
	init(_tile.column, _tile.letter, _status, _tile.points, "Default", _font_data)
	#moved to replace
	#id = _tile.id
	#set_pos(_tile.get_pos())
	pass

func get_speed():
	var speed = MinSpeed + RowSpeedIncrease * id + ColSpeedIncrease * column.id
	if (speed > MaxSpeed):
		speed = MaxSpeed
		pass
	return speed
	pass

func _fixed_process(delta):
#	var tile_size = Globals.get("TileSize")
#	if (status == "moving"):
#		var y = get_pos().y
#		var targetY = floor(tile_size * (id + (0.5 if column.offset == true else 0)))
#		y = y + Speed * delta
#		#print(y)
#		if (y > targetY):
#			y = targetY
#			pass
#		
#		set_pos(Vector2(0,y))
#		
#		if (y == targetY):
#			status = "stopped"
#			column.tile_stopped()
#			pass
#		pass
	
	pass

func show_arrow(from_tile):
	var distance = from_tile.get_global_pos() - get_global_pos()
	arrow.set_pos(distance * 0.5)
	arrow.rotate(distance.angle())
	arrow.show()
	pass

func hide_arrow():
	arrow.hide()
	pass

func get_target_y():
	return floor(tile_size * (id + (0.5 if column.offset == true else 0)))
	pass

func should_move():
	if (get_pos().y < get_target_y()):#tile_size * id):
		return true
		pass
	return false
	pass

func select():
	if (!selected):
		selected = true
		#animation.play("Select")
		animate("Select")
		pass
	pass

func deselect():
	if (selected):
		selected = false
		#animation.play("Deselect")
		animate("Deselect")
		hide_arrow()
		pass
	pass

func destroy():
	ignore = true
	queue_free()
	pass

func burn():
	hp -= 1
	if (hp == 0):
		ignore = true
		#animation.play("Burn")
		animate("Burn")
		return true
		pass
	return false
	pass

func _on_Tile_input_event( viewport, event, shape_idx ):
	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.is_pressed()):
			if (!clicked):
				if (game.can_select()):
					game.try_select_tile(self)
					game.update_word()
					pass
				clicked = true
				pass
			pass
		else:
			clicked = false;
			pass
		pass
	pass

func set_burning(value):
	if (burning == value):
		return
		pass
	if (value):
		var efx = BurningEFX.instance()
		get_node("Effects").add_child(efx)
		pass
	else:
		hp = MaxHp
		get_node("Effects/BurningEFX").queue_free()
		pass
	burning = value
	pass

func replace(_replacement):
	column.replacement_in_process()
	replacement = _replacement
	replacement.id = id
	replacement.set_pos(get_pos())
	replacement.prepare_spin_in()
	spin_out()
	pass

func animate(animation_name):
	if (animation == null):
		starting_animation = animation_name;
		pass
	else:
		animation.play(animation_name)
		pass
	pass

func spin_out():
	#animation.play("SpinOut")
	ignore = true
	animate("SpinOut")
	pass

func prepare_spin_in():
	#animation.play("PreSpinIn")
	hide()
	animate("PreSpinIn")
	pass

func spin_in():
	#animation.play("SpinIn")
	show()
	animate("SpinIn")
	pass

func _on_AnimationPlayer_finished():
	if (animation.get_current_animation() == "Burn"):
		queue_free()
		pass
	if (animation.get_current_animation() == "SpinOut"):
		if (replacement != null):
			column.replace_tile(self, replacement)
			pass
		queue_free()
		pass
	if (animation.get_current_animation() == "SpinIn"):
		column.replace_end()
		pass
	pass # replace with function body

func serialize():
	var result = {}
	result.letter = letter
	result.points = points
	result.hp = hp
	result.name = Name
	return result
	pass