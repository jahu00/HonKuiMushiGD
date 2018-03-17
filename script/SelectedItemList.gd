extends ItemList

var clicked
var selected_id = null
var init = true
var items = []
var index_map = {}
var selected_callback = null

func _ready():
	connect("input_event", self, "_on_input_event")
	connect("item_selected", self, "_on_item_selected")
	set_fixed_process(true)
	pass

func init(_select_callback):
	selected_callback = _select_callback
	pass

func clear_items():
	selected_id = null
	clear()
	items = []
	index_map = {}
	pass

func select_first():
	select(0)
	_on_item_selected(0)
	pass

func select_value(var value):
	if (!index_map.has(value)):
		return
		pass
	var id = index_map[value]
	select(id)
	_on_item_selected(id)
	pass

func get_selected_value():
	for key in index_map.keys():
		if (index_map[key] == selected_id):
			return key
			pass
		pass
	return null
	pass

func add_item_object(var text, var value):
	items.append({"text": text, "value": value})
	index_map[value] = items.size() - 1
	add_item(text)
	pass

func _fixed_process(delta):
	if (!init):
		set_fixed_process(false)
		return
		pass
	if (selected_id  != null):
		select(selected_id )
		pass
	init = false
	pass

func _on_input_event( event ):
	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.is_pressed()):
			if (!clicked):
				if (get_selected_items().size() == 0):
					select(selected_id)
					pass
				clicked = true
			pass
		else:
			clicked = false;
			pass
		pass
	pass

func _on_item_selected( index ):
	selected_id = index
	if (selected_callback != null):
		selected_callback.call_func(get_selected_value())
		pass
	pass
