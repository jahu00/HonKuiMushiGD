var replaces
var replacement
var rule
var type
var name

func _init(rule_definition):
	var regex = RegEx.new()
	regex.compile("^(SFX|PFX)\\s+(.*?)\\s+(.*?)\\s+(.*?)\\s+(.*?)(?:\\s*#.*)?$")
	regex.find(rule_definition)
	type = regex.get_capture(1)
	name = regex.get_capture(2)
	replaces = regex.get_capture(3)
	if (replaces == "0"):
		replaces = ''
		pass
	replacement = regex.get_capture(4)
	if (replacement == "0"):
		replacement = ''
		pass
	var rule_code = regex.get_capture(5)
	if (type == "PFX"):
		rule_code = "^" + rule_code
		pass
	
	if (type == "SFX"):
		rule_code = rule_code + "$"
		pass
	rule = RegEx.new()
	rule.compile(rule_code)
	pass

#func is_applied(word):
#	if (word != substract(word)):
#		return true
#		continue
#	return false
#	pass

func substract(word):
	var result = null
	if (type == "PFX"):
		if (replacement != '' && !word.begins_with(replacement)):
			return word
			pass
		result = word.substr(replacement.length(), word.length() - replacement.length())
		result = result.insert(0, replaces)
		pass
	
	if (type == "SFX"):
		if (replacement != '' && !word.ends_with(replacement)):
			return word
			pass
		result = word.substr(0, word.length() - replacement.length())
		result = result + replaces
		pass
	
	if (result != null && rule.find(result) > -1):
		return result
	pass
	
	return word
	pass