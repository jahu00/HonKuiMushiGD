extends Node2D

var UserDir

var high_score_path = "user://highscore.json"

var scores_by_language = { "English": { "high_score": [{ "score": 100, "name": "Test"}, { "score": 20, "name": "Test2"}], "best_word": { "word": "test", "points": 100, "name": "Test" }, "longest_word": { "word": "test", "name": "Test" } } }
var score_loaded = false
var language = "English"

var start_action = "show_score"
var score_types_to_save = []
var user_score
var user_stats
var user_language

var language_label
var popup

var HighScorePopup = preload("res://HighScorePopup.tscn")

func get_user_dir():
	if (UserDir == null):
		UserDir = Globals.get("UserDir")
		pass
	return UserDir
	pass

func get_scores():
	if (!score_loaded):
		load_score()
		pass
	return scores_by_language
	pass

func _ready():
	language_label = get_node("LanguageLabel")
	scores_by_language = get_scores()
	if (user_language != null):
		language = user_language
		pass
	set_language(language)
	pass

func set_language(_language):
	language = _language
	language_label.set_text(language.to_upper())
	if (start_action == "show_score"):
		if (popup != null):
			#kill popup
			pass
		popup = HighScorePopup.instance()
		popup.init(language, scores_by_language[language])
		add_child(popup)
		pass
	pass

func load_score():
	var user_dir = get_user_dir()
	if (user_dir.file_exists(high_score_path)):
		var f = File.new()
		f.open(high_score_path, File.READ)
		var json_str  = f.get_as_text()
		scores_by_language = {}
		scores_by_language.parse_json(json_str)
		f.close()
		pass
	score_loaded = true
	pass

func save_score():
	var f = File.new()
	f.open(high_score_path, File.WRITE)
	f.store_string(scores_by_language.to_json())
	f.close()
	pass

func is_new_high_score(_language, _score, _stats):
	var result = []
	var scores = get_scores()
	if (!scores.has(_language)):
		result.append("all")
		return result
		pass
	var score = scores[_language]
	if (!score.has("high_scores")):
		result.append("score")
		pass
	else:
		for high_score in score.high_scores:
			if (_score > high_score.score):
				result.append("score")
				break
				pass
			pass
		pass
	if (_stats.best_word.points > score.best_word.points):
		result.append("best_word")
		pass
	if (_stats.longest_word.length() > score.longest_word.length()):
		result.append("longest_word")
		pass
	return result
	pass

func init_from_score(_language, _score, _stats):
	score_types_to_save = is_new_high_score(_language, _score, _stats)
	language = _language
	if (score_types_to_save.size() > 0):
		start_action = "save_score"
		user_score = _score
		user_stats = _stats
		pass
	pass