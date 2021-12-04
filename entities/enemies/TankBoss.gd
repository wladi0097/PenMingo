extends KinematicBody2D

var moveSpeed = 50
var curveSpeed = 0.02
var hp = 500
onready var head := $Head
onready var navigation : Navigation2D = find_parent("Navigation2D")
var rng = RandomNumberGenerator.new()
onready var animations := $AnimationPlayer

enum STATES {STATIONARY, FOLLOW, RAM}
var currentState = STATES.STATIONARY

func _ready():
	_on_SwitchState_timeout()

func _physics_process(delta):
	pass
#	if currentState != STATES.RAM:
#		lookAtPlayer()
#
#	if currentState != STATES.STATIONARY:
#		moveAtPlayer()

func lookAtPlayer():
	head.rotation = lerp_angle(head.rotation, GLOBAL.player.global_position.angle_to_point(head.global_position) - rotation, 0.03)

func moveAtPlayer():
	var path = navigation.get_simple_path(self.global_position, GLOBAL.player.global_position)
	path.remove(0)
	self.rotation = lerp_angle(self.rotation, path[0].angle_to_point(self.position), curveSpeed)
	self.move_and_slide(Vector2(1, 0).rotated(self.rotation) * moveSpeed)

func followShoot():
	pass

func stationaryShoot():
	pass

func hit(bullet, dmg):
	pass

func _on_SwitchState_timeout():
	match currentState:
		STATES.RAM:
			animations.play_backwards("RamState")
			yield(animations, "animation_finished")
	
	currentState = rng.randi_range(0, STATES.size() -1)
	print(currentState)
	
	# reset to default
	moveSpeed = 50
	curveSpeed = 0.02
	
	# set accoring to state
	match currentState:
		STATES.RAM:
			head.rotation = 0
			animations.play("RamState")
			moveSpeed = 300
			curveSpeed = 0.04
