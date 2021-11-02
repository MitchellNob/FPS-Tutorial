extends Spatial

var speed = -70 #set the speed of the fireball to travel backwards

onready var globals = get_node("/root/Globals") #grab the node globals so that this script can use the global commands

func _ready():
	pass #it doesn't use the ready script

func _physics_process(delta): #
	var forward_dir = global_transform.basis.z.normalized() #stores the global transform of the z axis, it has been normalized aswell
	global_translate(forward_dir * speed * delta) #Adds the forward direction timesed by the speed and delta to the global transform of the fireball
	#making it move	

func _on_Area_body_entered(body): #if something enters the CollisionShape store in a variable called body . . .
	if body.is_in_group("Player"): #if the body is also in the group Player . . .
		globals.health -= 20 #minus 20 health from the players global health
