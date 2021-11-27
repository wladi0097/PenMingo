extends Node2D

export var isLocked = true
export var isFinished = false
export(Array, NodePath) var nextPoints
export(CURRENT_RUN.REWARDS) var reward
export(bool) var isCustomReward = false

onready var animations = $PressAnimationPlayer
onready var pressSprite = $Press
onready var lockSprite = $Lock
onready var finishedSprite = $Finished
onready var rewardsSprites = $Rewards
var isPlayerOnPoint = false

func _ready():
	if !isCustomReward:
		reward = CURRENT_RUN.getRandomReward()
	
	match reward:
		CURRENT_RUN.REWARDS.HEALTH:
			$Rewards/health.show()
		CURRENT_RUN.REWARDS.UPGRADE:
			$Rewards/upgrade.show()
	
	animations.play("Press")
	
	if isFinished:
		finished()
	elif isLocked:
		locked()
	else:
		unlock()
		
func finished():
	isPlayerOnPoint = false
	isFinished = true
	lockSprite.hide()
	pressSprite.hide()
	rewardsSprites.hide()
	finishedSprite.show()

func unlock():
	if isFinished: return
	
	isLocked = false
	lockSprite.hide()
	rewardsSprites.show()

func locked():
	lockSprite.show()
	
func _input(event):
	if isPlayerOnPoint && event.is_action_pressed("E"):
		CURRENT_RUN.loadNextRoomWithReward(reward)
		finished()
		
		for nodePoint in nextPoints:
			get_node(nodePoint).unlock()

func _on_Area2D_body_entered(body):
	if isLocked || isFinished: return
	
	isPlayerOnPoint = true
	pressSprite.show()

func _on_Area2D_body_exited(body):
	if isLocked || isFinished: return
	
	isPlayerOnPoint = false
	pressSprite.hide()
