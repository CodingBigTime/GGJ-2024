extends Node3D


func _ready():
	$DevilClown.died.connect(go_to_main_menu)


func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
