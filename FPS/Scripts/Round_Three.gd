extends Spatial


export (String, FILE) var win_scene #I first get a variable that holds the scene that I want to load
onready var globals = get_node("/root/Globals") #I also call the globals script so that I can use the global variables when i need

func _ready():
	$Player/Panel.visible = true #Make it so that we can see the Panel
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) #Set the cursor so that it is visible but bound to the game screen
	globals.process_input = false #set it so that we cannot use the Tab key or WASD

func _process(delta): 
	if globals.score >= 2600: #if the global variable score is higher than or equal to 2600 . . .
		globals.load_new_scene(win_scene) #load the win scene

func _on_Button_pressed(): #if the close button is pressed . . .
	$Player/Panel.visible = false #We can no longer see the Panel
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #We set the mouse back to captured meaning that it is invisible and cannot move
	globals.process_input = true #we make it so that we can press Tab and WASD
