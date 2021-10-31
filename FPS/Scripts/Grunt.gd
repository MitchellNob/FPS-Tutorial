extends KinematicBody

enum {
	IDLE,
	KILL
	}

export var speed = 3000

var target = null
var hitTimer = false
var timer = null
var hit_delay = 2
var can_hit = true
var gruntHealth = 20

onready var health_drop = preload("res://Scenes/Health_Pickup.tscn")
onready var ammo_drop = preload("res://Scenes/Ammo_Pickup.tscn")
onready var globals = get_node("/root/Globals")
onready var timer_node = get_node("Timer")
onready var Raycast = $RayCast
onready var Grunt = $Eyes

const turnSpeed = 2
const Height = 10
const maxHealth = 20

var state = IDLE

func _ready():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(hit_delay) 
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	gruntHealth = maxHealth


func on_timeout_complete():
	can_hit = true

func _process(delta):
	
	match state:
		KILL:
			Grunt.look_at(target.global_transform.origin + Vector3(0, Height, 0), Vector3(0, 1, 0))
			rotate_y(deg2rad(Grunt.rotation.y * turnSpeed))
			move_to_target(delta)
			KILL()
		IDLE:
			pass


func _on_Vision_body_entered(body):
	if target == null:
		if body.is_in_group("Player"):
			target = body
			state = KILL


func _on_Vision_body_exited(body):
	if target != null:
		if body == target:
			target = null
			state = IDLE


func move_to_target(delta):
	var direction = (target.transform.origin - transform.origin).normalized()
	move_and_slide(direction * speed * delta, Vector3.UP)


func KILL():
	if Raycast.is_colliding() && can_hit:
			var hit = Raycast.get_collider()
			if hit.is_in_group("Player"):
				globals.health -= 10
				can_hit = false
				timer.start()


func bullet_hit(damage, bullet_hit_pos):
	gruntHealth -= damage
	if gruntHealth <= 0:
		queue_free()
		




