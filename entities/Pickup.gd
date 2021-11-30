extends Area2D

onready var animations := $AnimationPlayer
export(CURRENT_RUN.REWARDS) var reward
export(bool) var isCustomReward = false
var rng = RandomNumberGenerator.new()

func _ready():
	if !isCustomReward:
		reward = CURRENT_RUN.currentRoomReward
		
	match reward:
		CURRENT_RUN.REWARDS.HEALTH:
			$Sprites/Health.show()
		CURRENT_RUN.REWARDS.UPGRADE:
			$Sprites/Upgrade.show()
		CURRENT_RUN.REWARDS.MAX_HEALTH:
			$Sprites/MaxHealth.show()
	animations.play("float")
	

func _on_Health_body_entered(body):
	match reward:
		CURRENT_RUN.REWARDS.HEALTH:
			GLOBAL.player.heal()
		CURRENT_RUN.REWARDS.UPGRADE:
			CURRENT_RUN.showUpgradeSelectionScreen()
		CURRENT_RUN.REWARDS.MAX_HEALTH:
			GLOBAL.player.addMaxHealth()
	
	queue_free()
