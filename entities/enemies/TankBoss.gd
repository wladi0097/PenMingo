extends "res://entities/enemies/EnemyBase.gd"

var moveSpeed = 50
var curveSpeed = 0.02
var shotSpread = 0.3
onready var head := $Head
onready var stateAnimations := $StatesAnimationplayer
onready var followStateShootTimer := $FollowStateShootTimer
onready var stationaryStateShootTimer := $StationaryStateShootTimer
onready var tankShootFrom := $Head/TankShootFrom
onready var shootSound := $shootSound
onready var tankSound := $tankSounds
onready var shootExplosionSound := $shootExplosionSound
var isIdle = true

enum STATES {STATIONARY, FOLLOW, RAM}
var currentState = STATES.RAM

func _ready():
	pass

func _physics_process(_delta):
	if isIdle: return
	
	if currentState != STATES.RAM:
		lookAtPlayer()

	if currentState != STATES.STATIONARY:
		moveAtPlayer()
		
	if currentState == STATES.FOLLOW:
		followShoot()
	
	if currentState == STATES.STATIONARY:
		stationaryShoot()

func lookAtPlayer():
	head.rotation = lerp_angle(head.rotation, GLOBAL.player.global_position.angle_to_point(head.global_position) - rotation, 0.03)

func moveAtPlayer():
	self.rotation = lerp_angle(self.rotation, getAngleToPlayer(), curveSpeed)
	self.move_and_slide(Vector2(1, 0).rotated(self.rotation) * moveSpeed)

func followShoot():
	if followStateShootTimer.is_stopped():
		followStateShootTimer.start()
		shootSound.play()
		var shootRotation = head.global_position.direction_to(tankShootFrom.global_position).angle()
		spawnBullet(tankShootFrom.global_position, shootRotation)
		spawnBullet(tankShootFrom.global_position, shootRotation + shotSpread)
		spawnBullet(tankShootFrom.global_position, shootRotation - shotSpread)

func stationaryShoot():
	if stationaryStateShootTimer.is_stopped():
		stationaryStateShootTimer.start()
		shootSound.play()
		for i in range(0, 360, rng.randi_range(15, 20)):
			spawnBullet(global_position, deg2rad(i))

func getRandomState():
	var statesWithoutCurrent = range(0, STATES.size())
	statesWithoutCurrent.remove(currentState)
	return statesWithoutCurrent[rng.randi_range(0, statesWithoutCurrent.size() -1)]

func switchStateTo(newState = null):
	match currentState:
		STATES.RAM:
			stateAnimations.play_backwards("RamState")
			yield(stateAnimations, "animation_finished")
		STATES.FOLLOW:
			pass
		STATES.STATIONARY:
			pass
	
	if newState == null:
		newState = getRandomState()
	
	currentState = newState
	
	# reset to default
	moveSpeed = 50
	curveSpeed = 0.02
	tankSound.pitch_scale = 1
	
	# set accoring to state
	match currentState:
		STATES.RAM:
			head.rotation = 0
			stateAnimations.play("RamState")
			moveSpeed = 300
			curveSpeed = 0.04
			tankSound.pitch_scale = 1.5
		STATES.FOLLOW:
			pass
		STATES.STATIONARY:
			pass

func _on_SwitchState_timeout():
	switchStateTo()

func _on_RamDamage_body_entered(body):
	if currentState == STATES.RAM:
		body.hit(self, 1)

func _on_ShootBombTimer_timeout():
	shootExplosionSound.play()
	spawnBomb()

func _on_WakeUp_body_entered(_body):
	if isIdle:
		isIdle = false
		switchStateTo(STATES.RAM)
		$AnimatedSprite.play()
		$SwitchState.start()
		$ShootBombTimer.start()
	
