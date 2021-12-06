extends Node2D

func _ready():
	showLabelContent()

func _on_StartRun_body_entered(body):
	CURRENT_RUN.startNewRun()
	queue_free()

func getTimeEnd():
	var timeEnd = OS.get_system_time_secs() - CURRENT_RUN.thisRunTimerStarted
	var m = floor(timeEnd / 60)
	var s = timeEnd % 60
	
	return cleanTimeString(s/60)+":"+cleanTimeString(s)

func cleanTimeString(time):
	return "0" + str(time) if time < 10 else str(time)

func showLabelContent():
	
	
	var newText = "            Your Run\n"
	newText += "Died After: " + getTimeEnd() + " sec \n"
	newText += "Dealt damage: " + str(CURRENT_RUN.thisRunDealthDamage) + " hits\n"
	newText += "Killed " + str(CURRENT_RUN.thisRunKilledEnemies) + " enemies\n"
	newText += "Switched animal " + str(CURRENT_RUN.thisRunSwitchedPlayers) + " times\n"
	$Label.text = newText
