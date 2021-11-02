extends KinematicBody

#this is an enumeration, it is a type of data class that groups a bunch of constant variables together, to create a dictionary
#of sorts. This is used for a state machine in many programming languages and is great for AI.
enum {
	IDLE, #IDLE is a keyword within the dictionary, whenever this is called it basically acts as an if statement
	KILL #KILL is the same as IDLE
	}

var target = null #target doesn't equal anything yet
var hitTimer = false #hitTimer is set to false
var timer = null #there is no timer yet
var hit_delay = 2 #this is the delay on the hits from the enemy
var can_hit = true #this is a boolean to see if the enemy can hit or not, if it is true then the enemy is allowed
#to hit the player
var gruntHealth = 50#This is the current health of the grunt

onready var globals = get_node("/root/Globals") #I call on the globals node here so that I can use the global variables later in the code,
#I use the onready variable here so that I don't have to put it into my ready script, it will just start up when the code is started.
onready var Raycast = $RayCast #I reference the raycast node here so that the code realizes that I have a raycast in the scene
onready var Grunt = $Eyes #I then reference a spatial node that represents the eyes, it is used so that the grunt will look where the 
#eyes are looking
onready var state = IDLE #when the script starts the state is put automatically into idle

const turnSpeed = 2 #speed that grunt turns
const Height = 10 #Height of player
const maxHealth = 50 #the Max health of the grunt
const Gruntspeed = 2500 #constant variable for the speed of the grunt

func _ready(): #everything in here will occur as soon as the node thats attatched to this script starts
	timer = Timer.new() #We create a new Timer node
	timer.set_one_shot(true) #we make it so that when the timer hits 0 it will stop
	timer.set_wait_time(hit_delay) #this sets the wait time in seconds, in this case it is set to the hit_delay which is 2 seconds
	timer.connect("timeout", self, "on_timeout_complete") #This runs a timeout function within itself, so when the 2 second timer is done
	#it calls the function on_timeout_complete.
	add_child(timer) #We also need to add a child, this means that it will become a child of Grunt
	gruntHealth = maxHealth #on ready the gruntHealth is reset to the maxHealth


func on_timeout_complete(): #When the on_timeout_complete function is called
	can_hit = true #the boolean can_hit is equal to true, this means that the enemy is able to hit me again

func _process(delta): #function _process means that it processes everything within here every frame, however things like movement,
#would be uneven if it was processed every frame. delta contains the time elapsed in seconds meaning that if you were to multiply 
#the movement by delta it would work consistently regardless of the frames you are getting
	
	match state: 
		KILL:
			Grunt.look_at(target.global_transform.origin + Vector3(0, Height, 0), Vector3(0, 1, 0)) #here the Eyes
			#use a function called look_at, this sets the Grunt to look at global vector 3 transform of the target, which in 
			#this case is the player.
			rotate_y(deg2rad(Grunt.rotation.y * turnSpeed))
			#this rotates the rest of the grunt to where the Eyes are looking, it uses deg2rad, which converts degrees into radians
			#There are a multitude of benefits to using radians, we rotate the Grunts y axis by the eyes y axis timesed by the turnSpeed
			#to make the turning seem more natural and slow it down a little.
			move_to_target(delta) #calls the move_to_target function
			KILL() #calls the KILL function
		IDLE:
			pass #does not use this piece of script


func _on_Vision_body_entered(body): #If the player enters the Vision area of the Grunt node then this function is activated
	if target == null: #if the target doesn't equal anything . . .
		if body.is_in_group("Player"): #if the body that entered the Vision area was the player . . .
			target = body #the target is equal to the player
			state = KILL #the state is set to KILL


func _on_Vision_body_exited(body): #when the player exits the Vision area
	if target != null: #if the target doesn't equal nothing . . .
		if body == target: #if the thing that left the Vision area was the player . . .
			target = null #the target is reset to nothing
			state = IDLE #the state is set back to idle


func move_to_target(delta): #function called in the KILL state
	var direction = (target.transform.origin - transform.origin).normalized() #this gets a variable named the direction which houses the 
	#players transform minused by the grunts origin and then the .normalized minuses that number by one
	move_and_slide(direction * Gruntspeed  * delta, Vector3.UP) #this uses move_and_slide to move the player towards the Player, it timeses the
	#number we got just then (direction) by the speed and then delta to keep it consistent, it also moves on the UP vector, which can be 
	#written as Vector3(0,1,0)


func KILL():
	if Raycast.is_colliding() && can_hit: #If the raycast is colliding with something . . .
			var hit = Raycast.get_collider() #create a variable called hit, within that variable state what the raycast collided with
			if hit.is_in_group("Player"): #if what it collided with was grouped with Player . . .
				globals.health -= 10 #call the global script and within the global script minus the players health by 10
				can_hit = false #can_hit is turned to false, meaning the Grunt cannot hit
				timer.start() #restart the timer


func bullet_hit(damage, bullet_hit_pos): #if the grunt is hit with a bullet
	gruntHealth -= damage #current health of grunt is minused by the guns damage
	if gruntHealth <= 0: #if the grunts health is below 0
		globals.score += 100 #increase score by 100
		queue_free() #kill the Grunt


