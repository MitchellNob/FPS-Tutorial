extends Control

var start_menu
var level_select_menu
var options_menu

export (String, FILE) var testing_area_scene
export (String, FILE) var doom_clone

func _ready():
	start_menu = $Start_Menu
	level_select_menu = $Level_Select_Menu
	options_menu = $Options_Menu
	$Start_Menu/Button_Start.connect("pressed", self, "start_menu_button_pressed", ["start"])
	$Start_Menu/Button_Options.connect("pressed", self, "start_menu_button_pressed", ["options"])
	$Start_Menu/Button_Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])
	
	$Level_Select_Menu/Button_Back.connect("pressed", self, "level_select_menu_button_pressed", ["back"])
	$Level_Select_Menu/Button_Level_Testing_Area.connect("pressed", self, "level_select_menu_button_pressed", ["testing_scene"]) #When the testing scene button is selected load the testing_scene script
	$Level_Select_Menu/Button_Level_Doom_Clone.connect("pressed", self, "level_select_menu_button_pressed", ["doom_clone_scene"]) #When the doom clone  button is selected load the doom_clone_scene script

	$Options_Menu/Button_Back.connect("pressed", self, "options_menu_button_pressed", ["back"])
	$Options_Menu/Button_Fullscreen.connect("pressed", self, "options_menu_button_pressed", ["fullscreen"])
	$Options_Menu/Check_Button_VSync.connect("pressed", self, "options_menu_button_pressed", ["vsync"])
	$Options_Menu/Check_Button_Debug.connect("pressed", self, "options_menu_button_pressed", ["debug"])
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var globals = get_node("/root/Globals")
	$Options_Menu/HSlider_Mouse_Sensitivity.value = globals.mouse_sensitivity
	$Options_Menu/HSlider_Joypad_Sensitivity.value = globals.joypad_sensitivity
	
	
func start_menu_button_pressed(button_name):
	if button_name == "start":
		level_select_menu.visible = true
		start_menu.visible = false
	elif button_name == "options":
		options_menu.visible = true
		start_menu.visible = false
	elif button_name == "quit":
		get_tree().quit()


func level_select_menu_button_pressed(button_name):
	if button_name == "back": #if the back button is pressed make the start menu visible and the options menu invisible
		start_menu.visible = true 
		level_select_menu.visible = false
	elif button_name == "testing_scene": #if the testing scene button is pressed than  set the mouse and joypad sensitivity and load the testing area scene
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(testing_area_scene)
	elif button_name == "doom_clone_scene":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(doom_clone)


func options_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		options_menu.visible = false
	elif button_name == "fullscreen":
		OS.window_fullscreen = !OS.window_fullscreen
	elif button_name == "vsync":
		OS.vsync_enabled = $Options_Menu/Check_Button_VSync.pressed
	elif button_name == "debug":
		get_node("/root/Globals").set_debug_display($Options_Menu/Check_Button_Debug.pressed)


func set_mouse_and_joypad_sensitivity():
	var globals = get_node("/root/Globals")
	globals.mouse_sensitivity = $Options_Menu/HSlider_Mouse_Sensitivity.value
	globals.joypad_sensitivity = $Options_Menu/HSlider_Joypad_Sensitivity.value
