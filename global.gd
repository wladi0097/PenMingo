extends Node

var player: KinematicBody2D

func loadLevel():
	print("load new level")
	get_tree().change_scene("res://worlds/Lobby.tscn")
