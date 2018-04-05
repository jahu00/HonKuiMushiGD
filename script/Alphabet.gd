var letters = []
var index = {}
var language
var frequency_sum
var conversions

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
	if (json.has("conversions")):
		conversions = json["conversions"]
		pass
	frequency_sum = 0
	for i in range(0, letters.size()):
		var letter = letters[i]
		index[letter.letter] = i
		frequency_sum += letter.frequency
		pass
	pass

func convert_word(word):
	if (conversions == null):
		return word
		pass
	var result = word
	# TODO:
	# - allow regex
	# - loop while conversions are possible
	for conversion in conversions:
		result = result.replace(conversion.from, conversion.to)
		pass
	return result
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