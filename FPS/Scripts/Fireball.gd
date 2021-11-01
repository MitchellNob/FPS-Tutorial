extends Spatial

var speed = -70
var damage = 15

onready var globals = get_node("/root/Globals")

func _ready():
	pass

func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * speed * delta)
	

func _on_Spatial_body_entered(body):
	if body.is_in_group("Player"):
		globals.health -= 20
		print ("hit")


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		globals.health -= 20
		print ("hit")
