extends Control

export (String, FILE) var menu_scene
export (String, FILE) var doom_scene

func _ready():
	$Death_screen/Button_Main_Menu.connect("pressed", self, "lose_menu_pressed", ["menu"])
	$Death_screen/Button_Start_Over.connect("pressed", self, "lose_menu_pressed", ["again"])

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func lose_menu_pressed(button_name):
	if button_name == "menu":
		get_node("/root/Globals").load_new_scene(menu_scene)
	elif button_name == "again":
		get_node("/root/Globals").load_new_scene(doom_scene)
