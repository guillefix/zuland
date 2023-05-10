extends CanvasLayer

#export(String, FILE, "*.json") var d_file

var dialogue = []

var d_active = false


func _ready():
	$NinePatchRect.visible = false

func start(name :String):
	if d_active:
		return
	d_active = true
	$NinePatchRect.visible = true
	#dialogue = load_dialogue()
	$NinePatchRect/Name.text = name
	$NinePatchRect/Chat.text = "Thinking..."

func change(name: String, text: String):
	if not d_active:
		return
	$NinePatchRect/Name.text = name
	$NinePatchRect/Chat.text = text

func hide_box():
	d_active = false
	$NinePatchRect.visible = false
