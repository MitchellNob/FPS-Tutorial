extends Spatial
#I reused a lot of stuff from the original game to get this to work
export (String, FILE) var doom_round_1 #I first get a variable that holds the scene that I want to load
onready var globals = get_node("/root/Globals") #I also call the globals script so that I can use the global variables when i need
onready var Player = get_node("/root/Player")

func _ready():
	$Player/Tutorial/Panel2.visible = true
	if $Player/Tutorial/Panel2.visible == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		globals.process_input = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		globals.process_input = true

func _process(delta):
	if globals.score == 100: #if the globals variable score is equal to 100 . . .
		globals.load_new_scene(doom_round_1) #call upon the global function load new scene to load doom round 1


func _on_first_button_pressed():
	$Player/Tutorial/Panel2.visible = false
	$Player/Tutorial/Panel3.visible = true


func _on_second_button_pressed():
	$Player/Tutorial/Panel3.visible = false
	$Player/Tutorial/Panel4.visible = true


func _on_third_button_pressed():
	$Player/Tutorial/Panel4.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	globals.process_input = true

