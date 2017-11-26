var array = []
var index = {}
var name

func _init():
	return self
	pass

func init(_name):
	name = _name
	pass

func append(item, key):
	if (array.has(key)):
		return null
		pass
	item.key = key
	#item.id = array.size()
	index[key] = item
	array.append(item)
	return item
	pass

func remove(key):
	if (index.has(key)):
		return
		pass
	
	var item_to_remove = index[key]
	index.erase(key)
	array.remove(array.find(item_to_remove))
	pass

func serialize():
	var temp = []
	for item in array:
		if (item.has("no_export") && item.no_export == true):
			continue
			pass
		temp.append(item)
		pass
	var temp_dictionary = {}
	temp_dictionary[name] = temp
	return temp_dictionary.to_json()
	pass

func _export(path):
	var f = File.new()
	f.open(path, File.WRITE)
	f.store_string(serialize())
	f.close()
	pass

func _import(path):
	var f = File.new()
	f.open(path, File.READ)
	var json_str  = f.get_as_text()
	deserialize(json_str)
	f.close()
	pass

func deserialize(json_str):
	var temp_dictionary = {}
	temp_dictionary.parse_json(json_str)
	var temp = temp_dictionary[name]
	for item in temp:
		append(item, item.key)
		pass
	return self
	pass