extends CanvasLayer

onready var selection1 = $ChooseUpgrade/HBoxContainer/select1
onready var selection2 = $ChooseUpgrade/HBoxContainer/select2
onready var container = $ChooseUpgrade

var availableUpgrades = [-1, -1]

func showRewardSelection():
	GLOBAL.player.canMove = false
	container.show()
	availableUpgrades = CURRENT_RUN.getTwoRandomUpgrades()
	selection1.text = CURRENT_RUN.getTextForUpgrade(availableUpgrades[0])
	selection2.text = CURRENT_RUN.getTextForUpgrade(availableUpgrades[1])

func addUpgradeAndHide(buttonIndex):
	GLOBAL.player.canMove = true
	CURRENT_RUN.upgradeSelected(availableUpgrades[buttonIndex])
	container.hide()

func _on_select1_button_down():
	addUpgradeAndHide(0)


func _on_select2_button_down():
	addUpgradeAndHide(1)
