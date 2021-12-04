extends Node2D

var isEnabled = false
onready var camera = $Player/Camera2D
onready var points = $points
onready var mapBorder = $mapBorder
onready var player = $Player
onready var audio = $AudioStreamPlayer

func _ready():
	hide()

func disable():
	audio.stop()
	player.set_collision_layer_bit(6, false)
	player.set_collision_mask_bit(6, false)
	mapBorder.set_collision_layer_bit(6, false)
	isEnabled = false
	camera.current = false
	hide()

func enable():
	audio.play()
	player.set_collision_layer_bit(6, true)
	player.set_collision_mask_bit(6, true)
	mapBorder.set_collision_layer_bit(6, true)
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
		
	player.move_and_slide(motion * 100)
