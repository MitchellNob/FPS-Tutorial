extends Spatial

export (String, FILE) var doom_round_3 #I first get a variable that holds the scene that I want to load
onready var globals = get_node("/root/Globals") #I also call the globals script so that I can use the global variables when i need
onready var Player = get_node("/root/Player")

func _ready():
	$Player/Panel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	globals.process_input = false

func _process(delta):
	if globals.score == 2000:
		globals.load_new_scene(doom_round_3)

func _on_Button_pressed():
	$Player/Panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	globals.process_input = true
