extends Node2D

var isEnabled = false
onready var camera = $Player/Camera2D
onready var points = $points

func _ready():
	hide()

func disable():
	isEnabled = false
	camera.current = false
	hide()

func enable():
	isEnabled = true
	camera.current = true
	show()

func _physics_process(delta):
	if !isEnabled: return
	
	var motion = Vector2()
	
	if Input.is_action_pressed("up"):
		motion.y -= 1
	if Input.is_action_pressed("right"):
		motion.x += 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1
		
	$Player.move_and_slide(motion * 100)