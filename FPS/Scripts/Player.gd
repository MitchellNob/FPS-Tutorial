	extends KinematicBody

#Physics
const GRAVITY = -50 #Constant Variable tells us how fast we are being pulled down
var vel = Vector3() #Variable that keeps track of our kinematic bodies velocity
const MAX_SPEED = 30 #Constant Variable that tells us our maximum speed
const JUMP_SPEED = 30 #Constant Variable that tells us our maximum jump
const ACCEL= 3.5 #Constant Variable that tells us how quickly we accelerate
const MAX_SPRINT_SPEED = 40 #Constant Variable that tells us how quickly we can go while sprinting
const SPRINT_ACCEL = 15 # Constant Variable that tells us how fast we accelerate to max sprinting speed
var is_sprinting = false #Boolean that tells us if we are sprinting or not
const DEACCEL= 16 #Constant Variable that tells us how quickly we going to deaccelerate
const MAX_SLOPE_ANGLE = 40 #Constant Variable that tells us how the steepest angle we can walk on

#Camera
var dir = Vector3() # 
var camera #The camera node
var rotation_helper #Node that holds all of the things that rotate on the x axis

#Mouse Sens
var MOUSE_SENSITIVITY = 0.05 #Variable for how sensitive the mouse is set default to 0.05

#Weapon Changing System
var animation_manager
var current_weapon_name = "UNARMED"
var weapons = {"UNARMED":null, "KNIFE":null, "PISTOL":null, "RIFLE":null}
const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1:"KNIFE", 2:"PISTOL", 3:"RIFLE"}
const WEAPON_NAME_TO_NUMBER = {"UNARMED":0, "KNIFE":1, "PISTOL":2, "RIFLE":3}
var changing_weapon = false
var changing_weapon_name = "UNARMED"

#Health
const MAX_HEALTH = 150 # Constant Variable for your maximum health
var health = 100 #Variable for how much health you have set 100 to default

#Miscellaenous
var UI_status_label #
var globals
var flashlight #Flashlight node

#Reloading
var reloading_weapon = false #Boolean to tell us whether or not the weapon is reloading

#Joypad Sensitivity
var JOYPAD_SENSITIVITY = 2 #Joypad sensitivity default set to 2
const JOYPAD_DEADZONE = 0.15 #Constant Variable this is the deadzone of the controller

#Mouse Scrolling
var mouse_scroll_value = 0
const MOUSE_SENSITIVITY_SCROLL_WHEEL = 0.08

#Grenade System
var grenade_amounts = {"Grenade":2, "Sticky Grenade":2} 
var current_grenade = "Grenade"
var grenade_scene = preload("res://Scenes/Grenade.tscn") #this variable preloads the scene so that befroe the game starts the scene is already loaded and ready to be instantiated without an hiccups
var sticky_grenade_scene = preload("res://Scenes/Sticky_Grenade.tscn")
const GRENADE_THROW_FORCE = 50

#Grabbing System
var grabbed_object = null
const OBJECT_THROW_FORCE = 120
const OBJECT_GRAB_DISTANCE = 7
const OBJECT_GRAB_RAY_DISTANCE = 10

#Respawn System
const RESPAWN_TIME = 4
var dead_time = 0
var is_dead = false

#Radial Menu
var Gun_selection = false

func _ready():
	globals = get_node("/root/Globals")
	global_transform.origin = globals.get_respawn_position()
	
	#Stores the Camera and Rotation helper nodes into their variables
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	
	animation_manager = $Rotation_Helper/Model/Animation_Player
	animation_manager.callback_function = funcref(self, "fire_bullet")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #This ensures that the mouse cannot move away from the game window
	
	weapons["KNIFE"] = $Rotation_Helper/Gun_Fire_Points/Knife_Point
	weapons["PISTOL"] = $Rotation_Helper/Gun_Fire_Points/Pistol_Point
	weapons["RIFLE"] = $Rotation_Helper/Gun_Fire_Points/Rifle_Point
	
	var gun_aim_point_pos = $Rotation_Helper/Gun_Aim_Point.global_transform.origin
	
	for weapon in weapons:
		var weapon_node = weapons[weapon]
		if weapon_node != null:
			weapon_node.player_node = self
			weapon_node.look_at(gun_aim_point_pos, Vector3(0, 1, 0))
			weapon_node.rotate_object_local(Vector3(0, 1, 0), deg2rad(180))
	
	current_weapon_name = "UNARMED"
	changing_weapon_name = "UNARMED"
	
	UI_status_label = $HUD/Panel/Gun_label
	
	#assigns the flashlight node to the variable
	flashlight = $Rotation_Helper/Flashlight
	
	#
	$HUD/Radial_Menu/Button.connect("pressed", self, "Gun_Selection", ["Primary"])
	$HUD/Radial_Menu/Button2.connect("pressed", self, "Gun_Selection", ["Secondary"])
	$HUD/Radial_Menu/Button3.connect("pressed", self, "Gun_Selection", ["Knife"])
	$HUD/Radial_Menu/Button4.connect("pressed", self, "Gun_Selection", ["Grenade"])
	$HUD/Radial_Menu/Button5.connect("pressed", self, "Gun_Selection", ["SGrenade"])

func _physics_process(delta):
	
	#If you are not dead call all 3 of these functions to store code
	if !is_dead: 
		process_input(delta)
		process_view_input(delta)
		process_movement(delta)

	
	#If you are holding any objects then these three functions are not to be used, in this instance that would be the changing weapons, reloading and selecting a gun.
	if grabbed_object == null:
		process_changing_weapons(delta)
		process_reloading(delta)
	 
	#These two functions do not require parameters to start so they should run no matter what.
	process_UI(delta)
	process_respawn(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3() #set the directioin to an empty vector3 so that it can move in a 3D axis
	var cam_xform = camera.get_global_transform() #we get the cameras coordinats and then put it into a variable
	
	var input_movement_vector = Vector2() #we set a vector2 into a variable so that we can move on 2D axis
	
	#If we press WASD it moves us in the corresponding direction by adding or subtracting one to the corresponding axis on the 2D plane
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x = 1

	input_movement_vector = input_movement_vector.normalized()
	
	if Input.get_connected_joypads().size() > 0:
		var joypad_vec = Vector2(0, 0)
		if OS.get_name() == "Windows":
			joypad_vec = Vector2(Input.get_joy_axis(0, 0), -Input.get_joy_axis(0, 1))
		elif OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))
		if joypad_vec.length() < JOYPAD_DEADZONE:
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))
			input_movement_vector += joypad_vec
	
	#We add the cameras local z axis timesed by the input movement vector in order to make it so the player moves forwards and backwards in relation to where
	#the camera is pointing
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	#If the player is on the floor and we have pressed the space bar we set the y velocity to the jump speed
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Sprinting
	#If the Shift key is being pressed then we make the boolean is_sprint = true, if it is not than the boolean is set to false
	if Input.is_action_pressed("movement_sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
	# ----------------------------------

	# ----------------------------------
	# Turning the flashlight on/off
	#If F is pressed on the keyboard and the flashlight is being used, hide the flashlight, if it is not than show it
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	#if the mouse mode is visible change it so that it is hidden and locked in position
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# ----------------------------------

	# ----------------------------------
	# Firing the weapons
	if Input.is_action_pressed("fire"): #if mouse button 1s pressed
		if changing_weapon == false: #and you are not currently changing a weapon
			if reloading_weapon == false: #and you are not currently reloading a weapon
				if Gun_selection == false:
					var current_weapon = weapons[current_weapon_name] #make the current_weapon variable the current weapons name
					if current_weapon != null: # #if the current weapon variable DOES equal something 
						if current_weapon.ammo_in_weapon > 0: #and the ammo in the current weapon is more than 0
							if animation_manager.current_state == current_weapon.IDLE_ANIM_NAME: #if the animation playiong at the moment is the idle animation
								animation_manager.set_animation(current_weapon.FIRE_ANIM_NAME) #set the current weapons animation to the firing animation
						else: #if this is not happening
							reloading_weapon = true #you are reloading the weapon
	# ----------------------------------

	# ----------------------------------
	# Reloading
	if reloading_weapon == false: #if you are not reloading the weapon
		if changing_weapon == false: #if you are not changing the weapon
			if Input.is_action_just_pressed("reload"): #if you press R on the keyboard
				var current_weapon = weapons[current_weapon_name] #make the current_weapon variable the current weapons name
				if current_weapon != null: #if the current weapon does equal something
					if current_weapon.CAN_RELOAD == true: #if current weapon can reload
						var current_anim_state = animation_manager.current_state #Set the variable current_anim_state to the current animation
						var is_reloading = false #set the reloading to false
						for weapon in weapons: #for is used to repeat a block of code
							var weapon_node = weapons[weapon]
							if weapon_node != null:
								if current_anim_state == weapon_node.RELOADING_ANIM_NAME:
									is_reloading = true
						if is_reloading == false:
							reloading_weapon = true
	# ----------------------------------

	# ----------------------------------
	# Gun Selection Menu
	#If the TAB key is pressed then the Gun selection menu becomes visible and
	if Input.is_action_pressed("ui_focus_next"):
		$HUD/Radial_Menu.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		Gun_selection = true
	else:
		$HUD/Radial_Menu.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Gun_selection = false
	# ----------------------------------
	
	
func process_view_input(delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	# ----------------------------------
	# Joypad rotation
	var joypad_vec = Vector2()
	if Input.get_connected_joypads().size() > 0:
		if OS.get_name() == "Windows":
			joypad_vec = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
		elif OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))
		if joypad_vec.length() < JOYPAD_DEADZONE:
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))

		rotation_helper.rotate_x(deg2rad(joypad_vec.y * JOYPAD_SENSITIVITY))
		rotate_y(deg2rad(joypad_vec.x * JOYPAD_SENSITIVITY * -1))
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	# ----------------------------------

	# ----------------------------------
	# Changing and throwing grenades
	#if your press V on the keyboard and the current grenade is grenade change it to sticky grenade, if it is sticky grenade change it to grenade
	if Input.is_action_just_pressed("change_grenade"):
		if current_grenade == "Grenade":
			current_grenade = "Sticky Grenade"
		elif current_grenade == "Sticky Grenade":
			current_grenade = "Grenade"
		
	#if the G is pressed on the keyboard and the current grenade has more than one ammo, take one ammo away
	if Input.is_action_just_pressed("fire_grenade"):
		if grenade_amounts[current_grenade] > 0:
			grenade_amounts[current_grenade] -= 1
			
			#add a variable called grenade clone
			var grenade_clone
			if current_grenade == "Grenade": #if the current grenade is equal to grenade
				grenade_clone = grenade_scene.instance() #creating an instance of something is basically instantiating an object into the scene, in this case we are instantiating a grenade into the scene, or in other words creating a grenade
			elif current_grenade == "Sticky Grenade":
				grenade_clone = sticky_grenade_scene.instance()
				grenade_clone.player_body = self
			
			get_tree().root.add_child(grenade_clone)
			grenade_clone.global_transform = $Rotation_Helper/Grenade_Toss_Pos.global_transform
			grenade_clone.apply_impulse(Vector3(0, 0, 0), grenade_clone.global_transform.basis.z * GRENADE_THROW_FORCE)
# ----------------------------------

# ----------------------------------
# Grabbing and throwing objects
	#This part of the code uses something called a raycast without actually having a raycast, a raycast is a type
	#of technique used, in which a ray of sorts is projected from where the camera is looking and moves in front of the player
	#rays can be infinite however this one has a distance so if anyuthing touches the ray within that distance it can then be picked up
	if Input.is_action_just_pressed("Grab") and current_weapon_name == "UNARMED":
		if grabbed_object == null:
			var state = get_world().direct_space_state
	
			var center_position = get_viewport().size / 2
			var ray_from = camera.project_ray_origin(center_position)
			var ray_to = ray_from + camera.project_ray_normal(center_position) * OBJECT_GRAB_RAY_DISTANCE
			
			var ray_result = state.intersect_ray(ray_from, ray_to, [self, $Rotation_Helper/Gun_Fire_Points/Knife_Point/Area])
			if !ray_result.empty():
				if ray_result["collider"] is RigidBody:
					grabbed_object = ray_result["collider"]
					grabbed_object.mode = RigidBody.MODE_STATIC
					
					grabbed_object.collision_layer = 0
					grabbed_object.collision_mask = 0
	
		else:
			grabbed_object.mode = RigidBody.MODE_RIGID
			
			grabbed_object.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * OBJECT_THROW_FORCE)
			
			grabbed_object.collision_layer = 1
			grabbed_object.collision_mask = 1
			
			grabbed_object = null
	
	if grabbed_object != null:
		grabbed_object.global_transform.origin = camera.global_transform.origin + (-camera.global_transform.basis.z.normalized() * OBJECT_GRAB_DISTANCE)
# ----------------------------------


func process_movement(delta):
	dir.y = 0 #set the y value on dir to 0
	dir = dir.normalized() #we use normalize so that the player moves at a constant speed even when moving diagonally

	vel.y += delta*GRAVITY #we add the gravity variable to the players Y velocity simulating gravity

	var hvel = vel # assign velocity to a new variable called hvel
	hvel.y = 0 #set hvels y velococity to 0

	var target = dir #assign velocity to a new variable called target
	if is_sprinting: #if you are sprint
		target *= MAX_SPRINT_SPEED #times your target speed by your max sprint speed
	else: #if you are not sprint then simply times you target speed by your max speed
		target *= MAX_SPEED

	var accel #make a new variable called accel
	
	if dir.dot(hvel) > 0: #if our player is moving using hvel
		if is_sprinting: # and we are spring then we set accel to SPRINT ACCEL to accelerate at a sprinting pace
			accel = SPRINT_ACCEL
		else: #if we are not sprinting that accel is equal to normal acceleration
			accel = ACCEL
	else: #if we are not doing any of that, then we are not moving and we need to slow down, so make accel equal to deaccel to deaccelerate
		accel = DEACCEL
	
	#Liner interpolation takes two known values and estimates a new unknown value, in this case we are estimating hvel using target and accel times delta value
	#to get the new hvel value
	hvel = hvel.linear_interpolate(target, accel*delta) 
	vel.x = hvel.x #we then change the vel variable to the new hvel values
	vel.z = hvel.z
	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE)) #we then have to make it so that the kinematic body can handle moving the player through the world using the physics


func process_changing_weapons(delta):
	#If the boolean for changing weapons is equal to true then weapon unequipped is equal to false
	#If the current weapon is equal to nothing, weapon unequipped is equal to true
	if changing_weapon == true: 

		var weapon_unequipped = false 
		var current_weapon = weapons[current_weapon_name]

		if current_weapon == null:
			weapon_unequipped = true
		else:
			if current_weapon.is_weapon_enabled == true:
				weapon_unequipped = current_weapon.unequip_weapon()
			else:
				weapon_unequipped = true

		if weapon_unequipped == true:

			var weapon_equiped = false
			var weapon_to_equip = weapons[changing_weapon_name]

			if weapon_to_equip == null:
				weapon_equiped = true
			else:
				if weapon_to_equip.is_weapon_enabled == false:
					weapon_equiped = weapon_to_equip.equip_weapon()
				else:
					weapon_equiped = true

			if weapon_equiped == true:
				changing_weapon = false
				current_weapon_name = changing_weapon_name
				changing_weapon_name = ""


func _input(event):
	
	if is_dead: #if you are dead then return to the function where this piece of code was called on
		return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: #if an event is an inputEventMouseMotion (in other words whenever the mouse cursor moves)
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY)) #rotate the rotation_helper node on the x axis by the y value provided by InputEventMouseMotion
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1)) #rotate the entire kinematic body on the y axis by the x value you got from the InputEventMouseMotion

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70) #A clamp is used to cap the angle at which a camera can rotate so that you can't rotate 360 degrees on the y axis
		rotation_helper.rotation_degrees = camera_rot

	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
			if event.button_index == BUTTON_WHEEL_UP:
				mouse_scroll_value += MOUSE_SENSITIVITY_SCROLL_WHEEL
			elif event.button_index == BUTTON_WHEEL_DOWN:
				mouse_scroll_value -= MOUSE_SENSITIVITY_SCROLL_WHEEL

				mouse_scroll_value = clamp(mouse_scroll_value, 0, WEAPON_NUMBER_TO_NAME.size() - 1)

				if changing_weapon == false:
					if reloading_weapon == false:
						var round_mouse_scroll_value = int(round(mouse_scroll_value))
						if WEAPON_NUMBER_TO_NAME[round_mouse_scroll_value] != current_weapon_name:
							changing_weapon_name = WEAPON_NUMBER_TO_NAME[round_mouse_scroll_value]
							changing_weapon = true
							mouse_scroll_value = round_mouse_scroll_value

func fire_bullet():
	if changing_weapon == true:
		return

	weapons[current_weapon_name].fire_weapon()

func process_UI(delta):
	#Check to see if the current weapon name is equal to unarmed or knife
	#if it does then it only shows the health of your character and the ammo fo your grenades
	#if you are currently holding an actual weapon then the text will show your health along with your weapon ammo, spare ammo and grenade ammo
	if current_weapon_name == "UNARMED" or current_weapon_name == "KNIFE": 
		UI_status_label.text = "HEALTH: " + str(health) + \
				"\n" + current_grenade + ": " + str(grenade_amounts[current_grenade])
	else:
		var current_weapon = weapons[current_weapon_name]
		UI_status_label.text = "HEALTH: " + str(health) + \
				"\nAMMO: " + str(current_weapon.ammo_in_weapon) + "/" + str(current_weapon.spare_ammo) + \
				"\n" + current_grenade + ": " + str(grenade_amounts[current_grenade])

func process_reloading(delta):
	if reloading_weapon == true:
		var current_weapon = weapons[current_weapon_name]
		if current_weapon != null:
			current_weapon.reload_weapon()
		reloading_weapon = false

func add_health(additional_health):
	health += additional_health
	health = clamp(health, 0, MAX_HEALTH)

func add_ammo(additional_ammo):
	if (current_weapon_name != "UNARMED"):
		if (weapons[current_weapon_name].CAN_REFILL == true):
			weapons[current_weapon_name].spare_ammo += weapons[current_weapon_name].AMMO_IN_MAG * additional_ammo

func add_grenade(additional_grenade):
	grenade_amounts[current_grenade] += additional_grenade
	grenade_amounts[current_grenade] = clamp(grenade_amounts[current_grenade], 0, 4)

func process_respawn(delta):

	#If our health is less than or equal to 0 and we are not already dead 
	#We make it so that we are changing weapons and we are unarmed
	#We then add the death screen panel and disable our HUD, we set is dead to true, throw any objects we have in our hands using an impulse and start the respawn timer
	if health <= 0 and !is_dead:
		$Body_CollisionShape.disabled = true
		$Feet_CollisionShape.disabled = true
	
		changing_weapon = true
		changing_weapon_name = "UNARMED"
	
		$HUD/Death_Screen.visible = true
	
		$HUD/Panel.visible = false
		$HUD/Crosshair.visible = false
	
		dead_time = RESPAWN_TIME
		is_dead = true
	
		if grabbed_object != null:
			grabbed_object.mode = RigidBody.MODE_RIGID
			grabbed_object.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * OBJECT_THROW_FORCE / 2) #applying an impluse is a type of force that can be applied to an object in order to simulate a sudden force
	
			grabbed_object.collision_layer = 1
			grabbed_object.collision_mask = 1
	
			grabbed_object = null
	
	if is_dead:
		dead_time -= delta
	
		var dead_time_pretty = str(dead_time).left(3)
		$HUD/Death_Screen/Label.text = "You died\n" + dead_time_pretty + " seconds till respawn"
	
		if dead_time <= 0:
			global_transform.origin = globals.get_respawn_position()
	
			$Body_CollisionShape.disabled = false
			$Feet_CollisionShape.disabled = false
	
			$HUD/Death_Screen.visible = false
	
			$HUD/Panel.visible = true
			$HUD/Crosshair.visible = true
	
			for weapon in weapons:
				var weapon_node = weapons[weapon]
				if weapon_node != null:
					weapon_node.reset_weapon()
	
			health = 100
			grenade_amounts = {"Grenade":2, "Sticky Grenade":2}
			current_grenade = "Grenade"
	
			is_dead = false

func create_sound(sound_name, position=null):
	globals.play_sound(sound_name, false, position)

func Gun_Selection(button_name):
	
	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name]
	
	if button_name == "Grenade":
		current_grenade = "Grenade"
		print("Grenade")
	elif button_name == "SGrenade":
		current_grenade = "Sticky Grenade"
		print("SGrenade")
	elif button_name == "Primary":
		weapon_change_number = 3
		print("AR")
	elif button_name == "Secondary":
		weapon_change_number = 2
	elif button_name == "Knife":
		weapon_change_number = 1
	
	if changing_weapon == false:
		if reloading_weapon == false:
			if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:
				changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
				changing_weapon = true
				mouse_scroll_value = weapon_change_number
