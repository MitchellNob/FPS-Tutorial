extends Control

onready var globals = get_node("/root/Globals") #Get the globals script for global variables

var stats #variable to keep the stat label text

export (String, FILE) var Main_Menu #Get the variable that will house the main menu scene
export (String, FILE) var Doom_Tutorial #Get the variable that will house the starting doom tutorial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) #set the mouse to VISIBLE meaning that it has no restrictions and is visible
	stats = $Death_screen/stats #set the stats variable to the stats label on the panel
	stats.text = "Score: %s" % globals.score #set the stats text to Score: "Whatever the score global score is"


func _on_Button_Start_Over_pressed(): #if the button is pressed . . .
	globals.score = 0 #set the global score back to 0
	get_node("/root/Globals").load_new_scene(Doom_Tutorial) #load the doom tutorial scene



func _on_Button_Main_Menu_pressed(): #if button is pressed . . .
	globals.score = 0  #set the global score to 0
	get_node("/root/Globals").load_new_scene(Main_Menu) #load the main menu scene

