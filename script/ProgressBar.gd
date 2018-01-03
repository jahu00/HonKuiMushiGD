extends Sprite

export(float) var MinStep = 0.01
export(float) var UpdateSpeed = 0.1

var progress = 100.0
var temp_progress = 100.0

func _ready():
	set_fixed_process(true)
	pass

func set_progress(value):
	if (value < progress):
		temp_progress = 0
		pass
	progress = value
	
	#make sure that we reset displayed progress for something like progress 0
	if (temp_progress == progress):
		update_progress()
		pass
	pass

func _fixed_process(delta):
	if (temp_progress == progress):
		return
		pass
	
	var step = float(progress - temp_progress) * delta * UpdateSpeed
	if (step < MinStep):
		step = MinStep
		pass
	
	temp_progress += step
	
	if (temp_progress > progress):
		temp_progress = progress
		pass
	
	update_progress()
	pass

func update_progress():
	#print(temp_progress)
	var width = get_texture().get_width()
	set_offset(Vector2(int(width * (temp_progress - 1)), 0))
	pass
