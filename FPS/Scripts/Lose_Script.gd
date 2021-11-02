extends Control

export (String, FILE) var menu_scene #Get the variable that will house the main menu scene
export (String, FILE) var doom_scene #Get the variable that will house the starting doom tutorial

var stats #variable to keep the stat label text

onready var globals = get_node("/root/Globals") #Get the globals script for global variables

func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) #set the mouse to VISIBLE meaning that it has no restrictions and is visible
	stats = $Death_screen/Stats #set the stats variable to the stats label on the panel
	stats.text = "Score: %s" % globals.score #set the stats text to Score: "Whatever the score global score is"


func _on_Button_Start_Over_pressed(): #if the button is pressed . . .
	globals.score = 0 #set the global score back to 0
	get_node("/root/Globals").load_new_scene(doom_scene) #load the doom tutorial scene


func _on_Button_Main_Menu_pressed(): #if button is pressed . . .
	globals.score = 0 #set the global score to 0
	get_node("/root/Globals").load_new_scene(menu_scene) #load the main menu scene
