extends Node2D


func _ready():
	showGameStats()

func getTimeEnd():
	var timeEnd = OS.get_system_time_msecs() - CURRENT_RUN.thisRunTimerStarted
	var minutes = int(timeEnd / 60 / 1000)
	var seconds = int(timeEnd / 1000) % 60
	var miliseconds = int(timeEnd) % 1000

	return ("%02d" % minutes) + (":%02d" % seconds) + (":%03d" % miliseconds)

func cleanTimeString(time):
	return "0" + str(time) if time < 10 else str(time)

func showGameStats():
	var newText = "Your Run\n"
	newText += "* Your Time: " + getTimeEnd() + " min \n"
	newText += "* Attempt: " + str(GLOBAL.allRunsAttemts) + "\n"
	newText += "* Rooms cleared: " + str(CURRENT_RUN.thisRunClearedRooms) + "\n"
	newText += "* Dealt damage: " + str(CURRENT_RUN.thisRunDealthDamage) + " dmg\n"
	newText += "* Killed " + str(CURRENT_RUN.thisRunKilledEnemies) + " enemies\n"
	newText += "* Switched animal " + str(CURRENT_RUN.thisRunSwitchedPlayers) + " times\n"	
	$GameStats.text = newText


func _on_Area2D_body_entered(_body):
	get_tree().change_scene("res://scripts/MainMenu.tscn")
