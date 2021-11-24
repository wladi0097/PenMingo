extends Node

var player: KinematicBody2D

func loadLevel():
	get_tree().change_scene("res://worlds/Level01_Zoo.tscn")
