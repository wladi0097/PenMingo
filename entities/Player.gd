extends KinematicBody2D

var maxHp = 5
var isDead = false
export var currentHp = 5
var movementSpeed := 150
var penguinShotSpread := 0.3
var penguinShotRandomSpread := 0.08
var penguinShotPositionRandomSpread := 5
var penguinShotKnockback := 1
var flamingoShotKnockback := 10
var rng = RandomNumberGenerator.new()
onready var regularBullet := preload("res://entities/Bullet.tscn")
onready var sniperBullet := preload("res://entities/SniperBullet.tscn")
onready var trail := preload("res://entities/Trail.tscn")

onready var camera := $Camera2D
onready var animations := $AnimationPlayer
onready var hitAnimationPlayer := $HitAnimationPlayer
onready var hitCooldown := $HitCooldown
onready var switchTimer := $switchTimer
onready var invincibleTimerAfterSwitch := $InvincibleTimerAfterSwitch
onready var switchTrail := $switchTrail
onready var collision := $CollisionShape2D
onready var penguinShotPosition := $penguinShot
onready var slideAudio := $slideAudio
onready var pickupTextAnimationPlayer := $PickupTextAnimationPlayer
onready var upgradeAudio := $upgradeAudio
onready var healAudio := $healAudio

onready var penguinShootLoopAudio := $penguinShootLoop
onready var penguinShotTimer := $penguinShotTimer
onready var penguinIdle := $PenguinSprite/penguinIdle
onready var penguinMove := $PenguinSprite/penguinMove
onready var penguinAttack := $PenguinSprite/penguinAttack
onready var penguinIdleBackpack := $PenguinSprite/penguinIdleBackpack
onready var penguinSpriteCollection := $PenguinSprite

onready var flamingoShootAudio := $flamingoShoot
onready var flamingoShotTimer := $flamingoShotTimer
onready var flamingoIdle := $FlamingoSprite/flamingoIdle
onready var flamingoMove := $FlamingoSprite/flamingoMove
onready var flamingoSpriteCollection := $FlamingoSprite

enum PLAYER_TYPES {PENGUIN, FLAMINGO}
var currentplayerType = PLAYER_TYPES.PENGUIN
var velocity := Vector2()

onready var pickupText := $CanvasLayer/Control/PickUpText

enum UPGRADE_STATE {NOTHING, SLIDE, TRIPPLE_SHOT, EXPLOSIVE_SHOT}
var upgradeText = ["", "Rightlick Dash", "Penguin tripple shot", "Flamingo explosive shot"]
var currentUpgradeState = UPGRADE_STATE.NOTHING

func _ready():
	GLOBAL.player = self
	AudioServer.set_bus_effect_enabled(1, 0, false)
	AudioServer.set_bus_volume_db(1, 1)
	AudioServer.set_bus_mute(2, false)
	updateHpBox()
	rng.randomize()

func _physics_process(delta):
	if isDead:
		return

	movement()
	rotateSpriteAccoringToMouse()

func _input(event):
	if event.is_action_pressed("action"):
		if currentplayerType == PLAYER_TYPES.FLAMINGO:
			flamingoShot()
	
	if event.is_action_pressed("action2"):
		slide()

func showPenguinSettings():
	currentplayerType = PLAYER_TYPES.PENGUIN
	flamingoSpriteCollection.hide()
	penguinSpriteCollection.show()
	pass
	
func showFlamingoSettings():
	currentplayerType = PLAYER_TYPES.FLAMINGO
	flamingoSpriteCollection.show()
	penguinSpriteCollection.hide()
	pass
	
func slide():	
	if switchTimer.is_stopped():
		switchTimer.start()
		invincibleTimerAfterSwitch.start()
		penguinShootLoopAudio.stop()
		if currentplayerType == PLAYER_TYPES.PENGUIN:
			showFlamingoSettings()
		else:
			showPenguinSettings()
		animations.play("switch")
		slideAudio.play()
		
		if currentUpgradeState >= UPGRADE_STATE.SLIDE:
			movement(15)

func shootSingleBullet(bulletType, new_rotation, allowRandomShots = false):
	var shootPositon = penguinShotPosition.global_position
	
	if allowRandomShots:
		new_rotation += rng.randf_range(-penguinShotRandomSpread, penguinShotRandomSpread)
		shootPositon.y += rng.randf_range(-penguinShotPositionRandomSpread, penguinShotPositionRandomSpread)
		
	var bullet_instance = bulletType.instance()
	
	if bulletType == sniperBullet && currentUpgradeState >= UPGRADE_STATE.EXPLOSIVE_SHOT:
		bullet_instance.isExplodingBullet = true
	
	bullet_instance.fire(shootPositon, self.rotation_degrees, new_rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	
func penguinShot():
	if !penguinShotTimer.is_stopped():
		return
	penguinShotTimer.start()
	
	if !penguinShootLoopAudio.playing:
		penguinShootLoopAudio.playing = true
	camera.set_offset(Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)))
	move_and_collide(get_global_mouse_position().direction_to(self.global_position).normalized() * penguinShotKnockback)
	shootSingleBullet(regularBullet, rotation, true)
	
	if currentUpgradeState >= UPGRADE_STATE.TRIPPLE_SHOT:
		shootSingleBullet(regularBullet, rotation + penguinShotSpread, true)
		shootSingleBullet(regularBullet, rotation - penguinShotSpread, true)
	
func flamingoShot():
	if !flamingoShotTimer.is_stopped():
		return
	flamingoShotTimer.start()
	flamingoShootAudio.play()
	
	move_and_collide(get_global_mouse_position().direction_to(self.global_position).normalized() * flamingoShotKnockback)
	shootSingleBullet(sniperBullet, rotation)

	animations.play("shootFlamingo")

func movement(extraSpeed = 1):
	var motion = Vector2()
	
	handlePenguinShot()
	
	if Input.is_action_pressed("up"):
		motion.y -= 1
	if Input.is_action_pressed("right"):
		motion.x += 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1
		
	var movementHappend = motion != Vector2()
	
	switchMovementAnimation(movementHappend)
	if movementHappend:
		var trail_instance
		if extraSpeed > 1:
			trail_instance = trail.instance()
			trail_instance.addPoint(position)
			
		self.move_and_slide(motion * movementSpeed * extraSpeed)
		
		if extraSpeed > 1:
			trail_instance.addPoint(position)
			get_tree().get_root().call_deferred("add_child", trail_instance)
	
	self.look_at(get_global_mouse_position())

func handlePenguinShot():
	if currentplayerType == PLAYER_TYPES.PENGUIN:
		if Input.is_action_pressed("action"):
			penguinAttack.visible = true
			penguinIdleBackpack.visible = false
			penguinShot()
		if !Input.is_action_pressed("action"):
			penguinAttack.visible = false
			penguinIdleBackpack.visible = true
			if penguinShootLoopAudio.playing:
				penguinShootLoopAudio.stop()
			camera.set_offset(Vector2())

func switchMovementAnimation(didMove):
	if didMove:
		penguinIdle.visible = false
		penguinMove.visible = true
		flamingoIdle.visible = false
		flamingoMove.visible = true
	else:
		penguinIdle.visible = true
		penguinMove.visible = false
		flamingoIdle.visible = true
		flamingoMove.visible = false

func rotateSpriteAccoringToMouse():
	if get_global_mouse_position().x < global_position.x:
		penguinSpriteCollection.scale.y = -1
		flamingoSpriteCollection.scale.y = -1
		collision.position.y = 1
	else:
		penguinSpriteCollection.scale.y = 1
		flamingoSpriteCollection.scale.y = 1
		collision.position.y = -1

func hit(body, dmg):
	if !hitCooldown.is_stopped() || !invincibleTimerAfterSwitch.is_stopped(): return
	hitCooldown.start()
	
	currentHp -= 1
	
	if currentHp == 0:
		die()
	elif currentHp > 0:
		hitAnimationPlayer.play("hit")
		updateHpBox()
		
func die():
	isDead = true
	AudioServer.set_bus_effect_enabled(1, 0, true)
	AudioServer.set_bus_volume_db(1, -20)
	AudioServer.set_bus_mute(2, true)
	$DeathAnimationPlayer.play("die")
	$deathAudio.play()
	
func heal():
	if currentHp <= maxHp:
		healAudio.play()
		currentHp += 1
		updateHpBox()
		
func upgrade(): # power up
	currentUpgradeState += 1
	upgradeAudio.play()
	showPickUpText(upgradeText[currentUpgradeState])
	
func showPickUpText(content):
	pickupText.text = content
	pickupTextAnimationPlayer.play("pickup")
	
onready var hpContainer := $CanvasLayer/Control/HpContainer
onready var hpFilledIcon := $CanvasLayer/Control/preload/HpFilled
onready var hpEmptyIcon := $CanvasLayer/Control/preload/HpEmpty
func updateHpBox():
	for child in hpContainer.get_children():
		hpContainer.remove_child(child)
		child.queue_free()
	
	for i in range(currentHp):
		hpContainer.add_child(hpFilledIcon.duplicate())
	for i in range(maxHp - currentHp):
		hpContainer.add_child(hpEmptyIcon.duplicate())


func _on_Restart_button_down():
	GLOBAL.loadLevel()
