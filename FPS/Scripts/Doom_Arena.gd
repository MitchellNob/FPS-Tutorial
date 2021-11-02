extends Spatial
#I reused a lot of stuff from the original game to get this to work
export (String, FILE) var doom_round_1 #I first get a variable that holds the scene that I want to load
onready var globals = get_node("/root/Globals") #I also call the globals script so that I can use the global variables when i need

func _ready():
	$Player/Panel.visible = true #set the first panels visibilty on
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) #set the mouse to confined meaning that it is visible, but can only move around inside the game window
	globals.process_input = false #make it so that we can't press Tab or WASD

func _process(delta):
	if globals.score > 1: #if the globals variable score is equal to 100 . . .
		globals.load_new_scene(doom_round_1) #call upon the global function load new scene to load doom round 1


func _on_first_button_pressed(): #if the first button is pressed . . .
	$Player/Panel.visible = false #set the first panels visibility off
	$Player/Panel2.visible = true #set the second panels visibility on


func _on_second_button_pressed(): #if the second button is pressed . . .
	$Player/Panel2.visible = false #set the second panels visibility off
	$Player/Panel3.visible = true #set the first panels visibilty on


func _on_third_button_pressed(): #if the third button is pressed . . .
	$Player/Panel3.visible = false #set the third panels visibilty off
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #set the mouse to captured meaning that it becomes invisible and cannot move
	globals.process_input = true #make it so that we can press Tab and WASD again
