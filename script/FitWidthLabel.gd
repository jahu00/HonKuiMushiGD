extends Label

export(int) var BaseFontSize = 48
export(int) var MaxTextLength = 11

func _ready():
	pass

func set_text_and_adjust_size(text):
	set_text(text)
	scale_font(1 if text.length() <= MaxTextLength else float(MaxTextLength) / float(text.length()))
	pass

func scale_font(scale):
	get("custom_fonts/font").set_size(BaseFontSize * scale)
	pass
