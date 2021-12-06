extends Node2D


func _ready():
	showGameStats()

func getTimeEnd():
	var timeEnd = OS.get_system_time_secs() - CURRENT_RUN.thisRunTimerStarted
	var m = floor(timeEnd / 60)
	var s = timeEnd % 60
	
	return cleanTimeString(s/60)+":"+cleanTimeString(s)

func cleanTimeString(time):
	return "0" + str(time) if time < 10 else str(time)

func showGameStats():
	var newText = "Your Run\n"
	newText += "* Your Time: " + getTimeEnd() + " min \n"
	newText += "* Attempts: " + str(GLOBAL.allRunsAttemts) + "\n"
	newText += "* Dealt damage: " + str(CURRENT_RUN.thisRunDealthDamage) + " hits\n"
	newText += "* Killed " + str(CURRENT_RUN.thisRunKilledEnemies) + " enemies\n"
	newText += "* Switched animal " + str(CURRENT_RUN.thisRunSwitchedPlayers) + " times\n"	
	$GameStats.text = newText


func _on_Area2D_body_entered(body):
	get_tree().change_scene("res://scripts/MainMenu.tscn")
