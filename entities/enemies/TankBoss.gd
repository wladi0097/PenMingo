extends "res://entities/enemies/EnemyBase.gd"

var moveSpeed = 50
var curveSpeed = 0.02
onready var head := $Head
var rng = RandomNumberGenerator.new()
onready var stateAnimations := $StatesAnimationplayer

enum STATES {STATIONARY, FOLLOW, RAM}
var currentState = STATES.STATIONARY

func _ready():
	_on_SwitchState_timeout()

func _physics_process(delta):
	if currentState != STATES.RAM:
		lookAtPlayer()

	if currentState != STATES.STATIONARY:
		moveAtPlayer()

func lookAtPlayer():
	head.rotation = lerp_angle(head.rotation, GLOBAL.player.global_position.angle_to_point(head.global_position) - rotation, 0.03)

func moveAtPlayer():
	self.rotation = lerp_angle(self.rotation, getAngleToPlayer(), curveSpeed)
	self.move_and_slide(Vector2(1, 0).rotated(self.rotation) * moveSpeed)

func followShoot():
	pass

func stationaryShoot():
	pass

func _on_SwitchState_timeout():
	match currentState:
		STATES.RAM:
			stateAnimations.play_backwards("RamState")
			yield(stateAnimations, "animation_finished")
		STATES.FOLLOW:
			pass
		STATES.STATIONARY:
			pass
	
	currentState = rng.randi_range(0, STATES.size() -1)
	
	# reset to default
	moveSpeed = 50
	curveSpeed = 0.02
	
	# set accoring to state
	match currentState:
		STATES.RAM:
			head.rotation = 0
			stateAnimations.play("RamState")
			moveSpeed = 300
			curveSpeed = 0.04
		STATES.FOLLOW:
			pass
		STATES.STATIONARY:
			pass
