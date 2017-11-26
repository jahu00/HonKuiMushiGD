var letters = []
var index = {}
var language
var frequency_sum

var alphabet_settings

func _init(_alphabet_settings):
	alphabet_settings = _alphabet_settings
	var file = File.new()
	file.open(alphabet_settings.path, file.READ)
	var json_str = file.get_as_text()
	var json = {}
	json.parse_json(json_str)
	letters = json["letters"]
	language = json["language"]
	frequency_sum = 0
	for i in range(0, letters.size()):
		var letter = letters[i]
		index[letter.letter] = i
		frequency_sum += letter.frequency
		pass
	pass

func get_letter_data(letter):
	return letters[index[letter]]
	pass

func get_random_letter():
	var random = randf() * frequency_sum
	var value = 0
	var letter
	for i in range(0, letters.size()):
		letter = letters[i]
		value += letter.frequency
		if (random <= value):
			return letter
			pass
		pass
	return letter
	pass