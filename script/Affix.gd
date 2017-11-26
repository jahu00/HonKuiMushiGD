var name
var type
var rules = []

var AppliedAffixRule = preload("res://script/AppliedAffixRule.gd")

func _init(affix_definition):
	var regex = RegEx.new()
	regex.compile("^(SFX|PFX)\\s+(.*?)\\s+")
	regex.find(affix_definition)
	type = regex.get_capture(1)
	name = regex.get_capture(2)
	pass

func add_rule(rule):
	rules.append(rule)
	pass

#func get_matching_rules(word):
#	var result = []
#	for rule in rules:
#		if (rule.is_applied(word)):
#			result.append(rule)
#			continue
#			pass
#		pass
#	pass

func get_applied_rules(word):
	var result = []
	for rule in rules:
		var original_word = rule.substract(word)
		if (word != original_word):
			result.append(AppliedAffixRule.new(word, original_word, [rule]))
			continue
			pass
		pass
	return result
	pass