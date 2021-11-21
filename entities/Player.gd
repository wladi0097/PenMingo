extends KinematicBody2D

var maxHp = 5
var currentHp = 5
var movementSpeed := 150
var penguinShotSpread := 0.3
var penguinShotRandomSpread := 0.08
var penguinShotPositionRandomSpread := 5
var penguinShotKnockback := 1
var flamingoShotKnockback := 10
var rng = RandomNumberGenerator.new()
onready var penguinShotPosition := $penguinShot
onready var regularBullet := preload("res://entities/Bullet.tscn")
onready var sniperBullet := preload("res://entities/SniperBullet.tscn")
onready var penguinShotTimer := $penguinShotTimer
onready var flamingoShotTimer := $flamingoShotTimer
onready var camera := $Camera2D
onready var penguinShootLoopAudio := $penguinShootLoop
onready var flamingoShootAudio := $flamingoShoot
onready var animations := $AnimationPlayer
onready var switchTimer := $switchTimer

onready var penguinIdle := $PenguinSprite/penguinIdle
onready var penguinMove := $PenguinSprite/penguinMove
onready var penguinAttack := $PenguinSprite/penguinAttack
onready var penguinIdleBackpack := $PenguinSprite/penguinIdleBackpack
onready var penguinSpriteCollection := $PenguinSprite
onready var collision := $CollisionShape2D

onready var flamingoIdle := $FlamingoSprite/flamingoIdle
onready var flamingoMove := $FlamingoSprite/flamingoMove
onready var flamingoSpriteCollection := $FlamingoSprite



enum PlayerTypes {PENGUIN, FLAMINGO}
var currentplayerType = PlayerTypes.PENGUIN
var velocity := Vector2()

func _ready():
	GLOBAL.player = self
	updateHpBox()
	rng.randomize()

func _process(delta):
	movement()
	
	if get_global_mouse_position().x < global_position.x:
		penguinSpriteCollection.scale.y = -1
		flamingoSpriteCollection.scale.y = -1
		collision.position.y = 6
	else:
		penguinSpriteCollection.scale.y = 1
		flamingoSpriteCollection.scale.y = 1
		collision.position.y = -6
	
func _input(event):
	if event.is_action_pressed("action"):
		if currentplayerType == PlayerTypes.FLAMINGO:
			flamingoShot()
	
	if event.is_action_pressed("action2") && switchTimer.is_stopped():
		switchTimer.start()
		penguinShootLoopAudio.stop()
		slide()
		if currentplayerType == PlayerTypes.PENGUIN:
			showFlamingoSettings()
		else:
			showPenguinSettings()

func showPenguinSettings():
	currentplayerType = PlayerTypes.PENGUIN
	flamingoSpriteCollection.hide()
	penguinSpriteCollection.show()
	pass
	
func showFlamingoSettings():
	currentplayerType = PlayerTypes.FLAMINGO
	flamingoSpriteCollection.show()
	penguinSpriteCollection.hide()
	pass
	
func slide():
	animations.play("switch")
	movement(15)

func shootSingleBullet(bulletType, new_rotation, allowRandomShots = false):
	var shootPositon = penguinShotPosition.global_position
	
	if allowRandomShots:
		new_rotation += rng.randf_range(-penguinShotRandomSpread, penguinShotRandomSpread)
		shootPositon.y += rng.randf_range(-penguinShotPositionRandomSpread, penguinShotPositionRandomSpread)
	
	var bullet_instance = bulletType.instance()
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
	
	if currentplayerType == PlayerTypes.PENGUIN:
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
	
	if Input.is_action_pressed("up"):
		motion.y -= 1
	if Input.is_action_pressed("right"):
		motion.x += 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1
	
	if motion == Vector2():
		penguinIdle.visible = true
		penguinMove.visible = false
		flamingoIdle.visible = true
		flamingoMove.visible = false
	else:
		penguinIdle.visible = false
		penguinMove.visible = true
		flamingoIdle.visible = false
		flamingoMove.visible = true
		self.move_and_slide(motion * movementSpeed * extraSpeed)
	
#	if !animations.has_playing("slide"):
	self.look_at(get_global_mouse_position())
	
func hit(body, dmg):
	currentHp -= 1
	updateHpBox()
	
	if currentHp == 0:
		die()
		

func die():
	currentHp = maxHp
	updateHpBox()
	pass
	
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
