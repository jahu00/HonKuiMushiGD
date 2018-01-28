extends Node2D

var label
var keys_container

var text = ""
var alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

var callback = null

var Key = preload("res://Key.tscn")

func _ready():
	label = get_node("Label")
	keys_container = get_node("KeysContainer")
	var x = 0
	var y = 0
	var key_size = 120
	for letter in alphabet:
		var new_key = Key.instance()
		new_key.init(letter, funcref(self, "add_letter"))
		new_key.set_pos(Vector2(x * key_size + key_size * 0.5, y * key_size + key_size * 0.5))
		keys_container.add_child(new_key)
		x += 1
		if (x % 7 == 0):
			x = 0
			y += 1
			pass
		pass
	var new_key = Key.instance()
	new_key.init("←", funcref(self, "remove_letter"))
	new_key.set_pos(Vector2(x * key_size + key_size * 0.5, y * key_size + key_size * 0.5))
	keys_container.add_child(new_key)
	x += 1
	var new_key = Key.instance()
	new_key.init("end", null, 0.75)#funcref(self, "remove_letter"))
	new_key.set_pos(Vector2(x * key_size + key_size * 0.5, y * key_size + key_size * 0.5))
	keys_container.add_child(new_key)
	update_text()
	pass

func init(_text, _callback = null):
	text = _text
	callback = _callback
	pass

func update_text():
	#label.set_text(text)
	label.set_text_and_adjust_size(text)
	pass

func add_letter(letter):
	text += letter
	update_text()
	pass

func remove_letter(letter):
	if (text.length() > 0):
		text = text.substr(0, text.length() - 1)
		update_text()
		pass
	pass

func end_pressed(letter):
	if (callback != null):
		callback.call_func(text)
		pass
	pass