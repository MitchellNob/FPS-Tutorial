extends Spatial

var Radial_Menu

func _ready():
	
	$Player/Control/Panel.visible = true

func _process(delta):
	if Input.is_action_pressed("Tab"):
		$Player/Control/Panel.visible = true 
	else:
		$Player/Control/Panel.visible = false
