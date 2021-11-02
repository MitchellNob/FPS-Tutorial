extends Spatial

export (String, FILE) var doom_round_3 #I first get a variable that holds the scene that I want to load
onready var globals = get_node("/root/Globals") #I also call the globals script so that I can use the global variables when i need

func _ready():
	$Player/Panel.visible = true #Make it so that we can see the Panel
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) #Set the cursor so that it is visible but bound to the game screen
	globals.process_input = false #set it so that we cannot use the Tab key or WASD

func _process(delta):
	if globals.score > 1300: #if the global variable score is above 1300 . . .
		globals.load_new_scene(doom_round_3) #load the doom round 3 scene

func _on_Button_pressed(): #if the close button is pressed . . .
	$Player/Panel.visible = false #We can no longer see the Panel
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #We set the mouse back to captured meaning that it is invisible and cannot move
	globals.process_input = true #we make it so that we can press Tab and WASD
