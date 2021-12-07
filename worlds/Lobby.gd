extends Node2D

func _ready():
	showLabelContent()

func _on_StartRun_body_entered(_body):
	CURRENT_RUN.startNewRun()
	queue_free()

func getTimeEnd():
	var timeEnd = OS.get_system_time_msecs() - CURRENT_RUN.thisRunTimerStarted
	var minutes = int(timeEnd / 60 / 1000)
	var seconds = int(timeEnd / 1000) % 60
	var miliseconds = int(timeEnd) % 1000

	return ("%02d" % minutes) + (":%02d" % seconds) + (":%03d" % miliseconds)

func showLabelContent():
	var newText = "            Your Run\n"
	newText += "Died After: " + getTimeEnd() + " min \n"
	newText += "Dealt damage: " + str(CURRENT_RUN.thisRunDealthDamage) + " dmg\n"
	newText += "Rooms cleared: " + str(CURRENT_RUN.thisRunClearedRooms) + "\n"
	newText += "Killed " + str(CURRENT_RUN.thisRunKilledEnemies) + " enemies\n"
	newText += "Switched animal " + str(CURRENT_RUN.thisRunSwitchedPlayers) + " times\n"
	$Label.text = newText
