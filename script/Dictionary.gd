var dictionary_data
#var affixes = []
var prefixes = []
var suffixes = []
#var index_data = []
var index = {}

var Affix = preload("res://script/Affix.gd")
var AffixRule = preload("res://script/AffixRule.gd")
var AppliedAffixRule = preload("res://script/AppliedAffixRule.gd")

var dictionary_settings

func _init(_dictionary_settings):
	dictionary_settings = _dictionary_settings
	var dictionary_file_name = dictionary_settings.path + ".dic"
	var affix_file_name = dictionary_settings.path + ".aff"
	var index_file_name = dictionary_settings.path + ".idx"
	load_dictionary(dictionary_file_name)
	load_affixes(affix_file_name)
	load_index(index_file_name)
	pass

func load_dictionary(dictionary_file_name):
	#var dictionary_file_name = path + ".dic"
	var dictionary_file = File.new()
	if (!dictionary_file.file_exists(dictionary_file_name)):
		return
		pass
	dictionary_file.open(dictionary_file_name, dictionary_file.READ)
	dictionary_data = dictionary_file.get_as_text()
	dictionary_file.close()
	pass

func load_affixes(affix_file_name):
	#var affix_file_name = path + ".aff"
	var affix_file = File.new()
	if (!affix_file.file_exists(affix_file_name)):
		return
		pass
	affix_file.open(affix_file_name, affix_file.READ)
	var affix_file_data = affix_file.get_as_text()
	var affix_lines = affix_file_data.split("\n")
	var i = 0;
	var last_affix
	for affix_line in affix_lines:
		if (!affix_line.begins_with("SFX") && !affix_line.begins_with("PFX")):
			continue
			pass
		
		var affix = Affix.new(affix_line)
		
		if (last_affix == null || last_affix.name != affix.name):
			#index[affix.name] = affixes.size()
			if (affix.type == "PFX"):
				prefixes.append(affix)
				pass
			if (affix.type == "SFX"):
				suffixes.append(affix)
				pass
			#affixes.append(affix)
			last_affix = affix
			continue
			pass
		
		last_affix.add_rule(AffixRule.new(affix_line))
		pass
	affix_file.close()
	pass

func build_subindex_if_needed(dictionary_data, last_index_entry, index_level, max_level, level_threshold):
	if (last_index_entry != null && last_index_entry.end - last_index_entry.start >= level_threshold && index_level < max_level):
		last_index_entry.index = build_index(dictionary_data.substr(last_index_entry.start, last_index_entry.end - last_index_entry.start), index_level + 1, max_level, level_threshold)
		pass
	pass

func build_index(dictionary_data, index_level, max_level, level_threshold):#, ignore_first_row):
	var last_pos = -1
	var first = true;
	var index = {}
	var last_index_entry
	while(true):
		var pos = dictionary_data.find("\n", last_pos + 1)
		if (pos == -1):
			break
			pass
		
		if (!first):
			var line = dictionary_data.substr(last_pos + 1, pos - last_pos - 1)
			var word = line.substr(0, line.find("/")).to_lower()
			#if (line.length() >= index_level):
			var key = word
			#var key = line.substr(0, index_level).to_lower()
			if (key.length() > index_level):
				key = word.substr(0, index_level)
				pass
			if (last_index_entry == null || last_index_entry.key != key):
				print(key)
				build_subindex_if_needed(dictionary_data, last_index_entry, index_level, max_level, level_threshold)
				if (!index.has(key)):
					index[key] = []
					pass
				last_index_entry = { "key": key, "start": last_pos }
				index[key].append(last_index_entry)
				pass
			#	pass
			
			if (last_index_entry != null):
				last_index_entry.end = pos
				pass
			pass
		
		first = false
		last_pos = pos
		pass
	build_subindex_if_needed(dictionary_data, last_index_entry, index_level, max_level, level_threshold)
	return index
	pass

func load_index(index_file_name):
	var index_file = File.new()
	if (!index_file.file_exists(index_file_name) && index_file_name.begins_with("res://")):
		index_file_name = index_file_name.replace("res://", "user://")
		var language_dir = Directory.new()
		var language_dir_path = "user://Dictionary/" + dictionary_settings.language
		if (!language_dir.dir_exists(language_dir_path)):
			language_dir.make_dir(language_dir_path)
			pass
		pass
	if (!index_file.file_exists(index_file_name)):
		index = build_index(dictionary_data, 1, 4, 1000)
		if (!index_file_name.begins_with("res://")):
			index_file.open(index_file_name, File.WRITE)
			index_file.store_string(index.to_json())
			index_file.close()
			pass
		return
		pass
	index_file.open(index_file_name, File.READ)
	var json_str  = index_file.get_as_text()
	index = {}
	index.parse_json(json_str)
	pass

func parse_dictionary_line(dictionary_line):
	var result = {}
	var split = dictionary_line.split("/", false)
	result.word = split[0]
	result.affixes = ""
	if (split.size() > 1):
		result.affixes = split[1]#.split("", false)
		pass
	return result
	pass

func find_all(search, dictionary_data):
	var result = []
	var pos = -1
	while(true):
		pos = dictionary_data.findn(search, pos + 1)
		if (pos == -1):
			break
			pass
		var end = dictionary_data.find("\n", pos + 1)
		if (end == -1):
			end = dictionary_data.length
			pass
		result.append(dictionary_data.substr(pos + 1, end - pos - 1))
		pass
	return result
	pass

func simple_lookup(word):
	word = word.to_lower()
	var result = find_all("\n" + word + "/", dictionary_data)
	#append_array(result, find_all("\n" + word + "/"))
	return result
#	var regex = RegEx.new()
#	regex.compile("\n" + word + "(\n|/)")
#	var pos = regex.find(dictionary_data)
#	if (pos == -1):
#		return null
#	var end = dictionary_data.find("\n", pos + 1)
#	if (end == -1):
#		end = dictionary_data.length
#		pass
#	return dictionary_data.substr(pos + 1, end - pos - 1)
	
	pass

func indexed_lookup(word, dictionary_data, index, index_level = 1):
	word = word.to_lower()
	var key = word.substr(0, index_level)
	if (!index.has(key)):
		return []
		pass
	var result = []
	for index_entry in index[key]:
		if (index_entry.has("index")):
			append_array(result, indexed_lookup(word, dictionary_data.substr(index_entry.start, index_entry.end - index_entry.start), index_entry.index, index_level + 1))
			pass
		else:
			append_array(result, find_all("\n" + word + "/", dictionary_data))
			#append_array(result, find_all("\n" + word + "/", dictionary_data))
			pass
		
		pass
	return result
	pass

func combine_arrays(array1, array2):
	var result = []
	for item in array1:
		result.append(item)
		pass
	
	for item in array2:
		result.append(item)
		pass
	
	return result
	pass

func append_array(array1, array2):
	for item in array2:
		array1.append(item)
	return array1
	pass

func lookup(word, fast_search = false):
	var result = []
	
	var words_to_search = [AppliedAffixRule.new(word, word, [])]
	
	for prefix in prefixes:
		append_array(words_to_search, prefix.get_applied_rules(word))
		pass
	
	var applied_suffixes = []
	
	for word_to_search in words_to_search:
		for suffix in suffixes:
			var temp_applied_suffixes = suffix.get_applied_rules(word_to_search.original_word)
			for applied_suffix in temp_applied_suffixes:
				applied_suffix.rules = combine_arrays(word_to_search.rules, applied_suffix.rules)
				pass
			append_array(applied_suffixes, temp_applied_suffixes)
			pass
		pass
	
	append_array(words_to_search, applied_suffixes)
	
#	var affix_rules = []
#	for affix in affixes:
#		merge_array(affix_rules, affix.get_matching_rules(word))
#		pass
#	
#	var dictionary_line
#	
#	if (affix_rules.size() > 0):
#		for rule in affix_rules:
#			if (rule.type == "PFX"):
#				var word_to_search = word
#				word_to_search = {}
#				word_to_search = word_to_search.substr(rule.replaces)
#				pass
#			pass
#		pass
	
#	dictionary_line = simple_lookup(word)
#	if (dictionary_line != null):
#		result.append(parse_dictionary_line(dictionary_line))
#		pass
	print(words_to_search.size())
	for word_to_search in words_to_search:
		var dictionary_lines = indexed_lookup(word_to_search.original_word, dictionary_data, index)#simple_lookup(word_to_search.original_word)
		for dictionary_line in dictionary_lines:
#			if (dictionary_line == null):
#				continue
#				pass
			
			var dictionary_entry = parse_dictionary_line(dictionary_line)
			var matching_affixes = 0
			
			for rule in word_to_search.rules:
				if (dictionary_entry.affixes.find(rule.name) == -1):
					break
					pass
				matching_affixes += 1
				pass
			
			if (matching_affixes < word_to_search.rules.size()):
				continue
				pass
			
			result.append(dictionary_entry)
			if (fast_search == true):
				return result
				pass
			pass
		pass
	
	return result
	
	pass