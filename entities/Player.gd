extends KinematicBody2D
class_name Player

var isDead = false
var canMove = true
var penguinShotSpread := 0.3
var penguinShotRandomSpread := 0.08
var penguinShotPositionRandomSpread := 5
var penguinShotKnockback := 1
var flamingoShotKnockback := 10
var rng = RandomNumberGenerator.new()
onready var regularBullet := preload("res://entities/attacks/Bullet.tscn")
onready var sniperBullet := preload("res://entities/attacks/SniperBullet.tscn")
onready var spinDmg := preload("res://entities/attacks/SpinDmg.tscn")
onready var trail := preload("res://entities/attacks/Trail.tscn")
onready var surroundEntity := preload("res://entities/attacks/surroundEntity.tscn")
onready var explosiveBarrel := preload("res://entities/props/ExplosiveBarrel.tscn")

onready var camera := $Camera2D
onready var animations := $AnimationPlayer
onready var hitAnimationPlayer := $HitAnimationPlayer
onready var hitCooldown := $HitCooldown
onready var switchTimer := $switchTimer
onready var invincibleTimerAfterSwitch := $InvincibleTimerAfterSwitch
onready var collision := $CollisionShape2D
onready var penguinShotPosition := $penguinShot
onready var slideAudio := $slideAudio
onready var hitAudio := $hitAudio
onready var pickupTextAnimationPlayer := $PickupTextAnimationPlayer
onready var healAudio := $healAudio
onready var slideTimeAnimationPlayer := $SliderTimeAnimation/AnimationPlayer
onready var sliderTimeAnimationContainer := $SliderTimeAnimation
onready var slideAnimations := $SlideAnimationPlayer
onready var slideParticles := $SlideParticles

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

func _ready():
	GLOBAL.player = self
	rng.randomize()
	
	enableAllSound()
	updateHpBox()
	updateStats()
	addUpgrades()

func enableAllSound():
	AudioServer.set_bus_effect_enabled(1, 0, false)
	AudioServer.set_bus_volume_db(1, 1)
	AudioServer.set_bus_mute(2, false)

func updateStats():
	penguinShotTimer.wait_time = CURRENT_RUN.currentPenguinShootSpeed
	flamingoShotTimer.wait_time = CURRENT_RUN.currentFlamingoShootSpeed

func addUpgrades():
	if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.DEFENSE_SURROUNDING):
		var surroundEntity_instance = surroundEntity.instance()
		add_child(surroundEntity_instance)
		
	if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.POOPING_EXPLOSVIE_BARREL):
		$PoopBomb.start()
		
func _physics_process(_delta):
	if isDead: return
	if canMove: movement()

	rotateSpriteAccoringToMouse()
	self.look_at(get_global_mouse_position())

func _input(event):
	if isDead || !canMove:
		return
	
	if event.is_action_pressed("action"):
		if currentplayerType == PLAYER_TYPES.FLAMINGO:
			flamingoShot()
	
	if event.is_action_pressed("action2"):
		slide()

func showPenguinSettings():
	currentplayerType = PLAYER_TYPES.PENGUIN
	flamingoSpriteCollection.hide()
	penguinSpriteCollection.show()
	
func showFlamingoSettings():
	currentplayerType = PLAYER_TYPES.FLAMINGO
	flamingoSpriteCollection.show()
	penguinSpriteCollection.hide()
	
func slide():
	if switchTimer.is_stopped():
		if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.DASH_DAMAGE):
			var spinDmg_instance = spinDmg.instance()
			spinDmg_instance.global_position = global_position
			get_tree().get_root().call_deferred("add_child", spinDmg_instance)
		
		slideAnimations.play("slide")
		slideParticles.emitting = true
		canBeHitByBullets(false)
		slideTimeAnimationPlayer.play("progress")
		switchTimer.start()
		invincibleTimerAfterSwitch.start()
		penguinShootLoopAudio.stop()
		if currentplayerType == PLAYER_TYPES.PENGUIN:
			showFlamingoSettings()
		else:
			showPenguinSettings()
		slideAudio.play()
		movement(15)
		CURRENT_RUN.thisRunSwitchedPlayers += 1

func shootSingleBullet(bulletType, new_rotation, allowRandomShots = false):
	var shootPositon = penguinShotPosition.global_position
	
	if allowRandomShots:
		new_rotation += rng.randf_range(-penguinShotRandomSpread, penguinShotRandomSpread)
		shootPositon.y += rng.randf_range(-penguinShotPositionRandomSpread, penguinShotPositionRandomSpread)
		
	var bullet_instance = bulletType.instance()
	bullet_instance.fire(shootPositon, self.rotation_degrees, new_rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	
func penguinShot():
	if !penguinShotTimer.is_stopped(): return
	penguinShotTimer.start()
	
	if !penguinShootLoopAudio.playing:
		penguinShootLoopAudio.playing = true
	camera.set_offset(Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)))
	move_and_collide(get_global_mouse_position().direction_to(self.global_position).normalized() * penguinShotKnockback)
	shootSingleBullet(regularBullet, rotation, true)
	
	if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.TRIPPLE_SHOT):
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
	
	if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.FLAMINGO_SECOND_SHOT):
		shootSingleBullet(sniperBullet, deg2rad(rng.randi_range(0, 360)))
	
	if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.FLAMINGO_BACK_SHOOT):
		shootSingleBullet(regularBullet, fmod(rotation + PI, 2*PI))

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
			
		var caluclatedSpeed = motion * CURRENT_RUN.currentMovementSpeed * extraSpeed
		self.move_and_slide(caluclatedSpeed, Vector2(0, 0), false, 4,  0.785398, false)
		checkCollisionsWithRigidBodies()
		
		if extraSpeed > 1:
			trail_instance.addPoint(position)
			get_tree().get_root().call_deferred("add_child", trail_instance)
	
func checkCollisionsWithRigidBodies():
	for i in get_slide_count():
		var checkCollision: KinematicCollision2D = get_slide_collision(i)
		if checkCollision.collider is RigidBody2D:
			checkCollision.collider.apply_central_impulse(-checkCollision.normal)

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
		sliderTimeAnimationContainer.scale.y = -1
	else:
		penguinSpriteCollection.scale.y = 1
		flamingoSpriteCollection.scale.y = 1
		collision.position.y = -1
		sliderTimeAnimationContainer.scale.y = 1

func hit(_body, _dmg):
	if !hitCooldown.is_stopped() || !invincibleTimerAfterSwitch.is_stopped(): return
	hitCooldown.start()
	
	CURRENT_RUN.currentHp -= 1
	
	hitAudio.play()
	if CURRENT_RUN.currentHp == 0:
		die()
	elif CURRENT_RUN.currentHp > 0:
		hitAnimationPlayer.play("hit")
		updateHpBox()
		
func die():
	isDead = true
	AudioServer.set_bus_effect_enabled(1, 0, true)
	AudioServer.set_bus_volume_db(1, -20)
	AudioServer.set_bus_mute(2, true)
	$DeathAnimationPlayer.play("die")
	$deathAudio.play()
	
func heal(times = 1):
	healAudio.play()
	
	for _i in range(times):
		if CURRENT_RUN.currentHp < CURRENT_RUN.currentMaxHp:
			CURRENT_RUN.currentHp += 1
	
	updateHpBox()
		
func addMaxHealth():
	healAudio.play()
	CURRENT_RUN.currentMaxHp += 1
	heal()
	updateHpBox()
	
func addStatUpgrade():
	var statUpgrade = CURRENT_RUN.applyRandomStatusUpgrade()
	showPickUpText(CURRENT_RUN.getTextForStatusUpgrade(statUpgrade))
	
func showPickUpText(content):
	pickupText.text = content
	pickupTextAnimationPlayer.play("pickup")
	
func canBeHitByBullets(value):
	set_collision_mask_bit(5, value)
	
onready var hpContainer := $CanvasLayer/Control/HpContainer
onready var hpFilledIcon := $CanvasLayer/Control/preload/HpFilled
onready var hpEmptyIcon := $CanvasLayer/Control/preload/HpEmpty
func updateHpBox():
	for child in hpContainer.get_children():
		hpContainer.remove_child(child)
		child.queue_free()
	
	for _i in range(CURRENT_RUN.currentHp):
		hpContainer.add_child(hpFilledIcon.duplicate())
	for _i in range(CURRENT_RUN.currentMaxHp - CURRENT_RUN.currentHp):
		hpContainer.add_child(hpEmptyIcon.duplicate())


func _on_Restart_button_down():
	CURRENT_RUN.PlayerClickedRestart()

func _on_InvincibleTimerAfterSwitch_timeout():
	canBeHitByBullets(true)

func _on_PoopBomb_timeout():
	var explosiveBarrel_instance = explosiveBarrel.instance()
	explosiveBarrel_instance.global_position = global_position + (-global_position.direction_to(get_global_mouse_position()) * 10)
	get_tree().get_root().call_deferred("add_child", explosiveBarrel_instance)
	
