extends Node

var UserDir

var high_score_path = "user://highscore.json"

var scores_by_language = {
#	"English": {
#		"high_score": [
#			{ "score": 100, "name": "Test"},
#			{ "score": 20, "name": "Test2"},
#			{ "score": 20, "name": "Test2"},
#			{ "score": 20, "name": "Test2"},
#			{ "score": 20, "name": "Test2"}
#		],
#		"best_word": { "word": "test", "points": 100, "name": "Test" },
#		"longest_word": { "word": "test", "name": "Test" }
#	},
#	"Polish": {
#		"high_score": [
#			{ "score": 100, "name": "Test"}
#		],
#		"best_word": { "word": "słowo", "points": 100, "name": "Test" },
#		"longest_word": { "word": "konstantynopolitańczykówna", "name": "Test" }
#	}
}
var score_loaded = false
var language = "English"

var start_action = "show_score"
var score_types_to_save = []
var user_score
var user_stats
var user_language

var popup
var overlay
var keyboard

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
	overlay = get_node("Overlay")
	keyboard = get_node("Keyboard")
	keyboard.init("", funcref(self, "enter_name_callback"))
	scores_by_language = get_scores()
	if (user_language != null):
		language = user_language
		pass
	var languages = scores_by_language.keys()
	get_node("PreviousLanguage").callback = funcref(self, "previous_language")
	get_node("NextLanguage").callback = funcref(self, "next_language")
	get_node("ReturnToMenu").init("Menu", funcref(self, "return_to_menu"), 0.60)
	if (start_action == "show_score"):
		if (!scores_by_language.has(language) && languages.size() > 0):
			language = languages[0]
			pass
		set_language(language)
		pass
	if (start_action == "save_score"):
		overlay.show()
		keyboard.show()
		pass
	pass

func return_to_menu(dummy):
	get_tree().change_scene("res://Menu.tscn")
	pass

func enter_name_callback(name):
	var scores = get_scores()
	var score
	if (scores.has(language)):
		score = scores[language]
		pass
	else:
		score = {
			"high_score": [],
			"best_word": { "word": "", "points": 0, "name": "" },
			"longest_word": { "word": "", "name": "" }
		}
		scores[language] = score;
		pass
	for score_type in score_types_to_save:
		if (score_type.name == "score"):
			score.high_score.insert(score_type.position, {"score": score_type.score, "name": name})
			if (score.high_score.size() > 5):
				score.high_score.remove(5)
				pass
			pass
		if (score_type.name == "best_word"):
			score.best_word.name = name
			score.best_word.word = user_stats.best_word.word
			score.best_word.points = user_stats.best_word.points
			pass
		if (score_type.name == "longest_word"):
			score.longest_word.name = name
			score.longest_word.word = user_stats.longest_word#.word
			pass
		pass
		save_score()
		overlay.hide()
		keyboard.hide()
		set_language(language)
	pass

func change_language(direction = 1):
	var languages = get_scores().keys()
	if (languages.size() == 0):
		return
		pass
	var language_index = languages.find(language) + 1
	language_index = language_index % languages.size()
	if (language_index < 0):
		language_index += languages.size()
		pass
	set_language(languages[language_index])
	pass

func previous_language(dummy):
	change_language(-1)
	pass

func next_language(dummy):
	change_language(1)
	pass

func set_language(_language):
	language = _language
	if (true):#start_action == "show_score"):
		if (popup != null):
			popup.a_hide()
			pass
		var scores = get_scores()
		if (scores.has(language)):
			popup = HighScorePopup.instance()
			popup.init(language, scores[language])
			add_child(popup)
			pass
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
	if (_score == 0):
		return result
		pass
	var scores = get_scores()
	if (!scores.has(_language)):
		result = [{"name": "score", "position": 0, "score": _score}, {"name": "best_word"}, {"name": "longest_word"}]
		return result
		pass
	var score = scores[_language]
	if (!score.has("high_score")):
		result.append({"name": "score", "position": 0, "score": _score})
		pass
	else:
		var score_position = 0
		for high_score in score.high_score:
			if (_score > high_score.score):
				result.append({"name": "score", "position": score_position, "score": _score})
				break
				pass
			pass
			score_position += 1
		pass
	if (_stats.best_word.word != "" && _stats.best_word.points > score.best_word.points):
		result.append({"name": "best_word"})
		pass
	if (_stats.longest_word != "" &&_stats.longest_word.length() > score.longest_word.word.length()):
		result.append({"name": "longest_word"})
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