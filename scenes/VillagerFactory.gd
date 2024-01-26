extends Node3D

signal player_position_signal(player_pos: Vector3)

var villager = preload("res://actors/Villager/villager.tscn")
var player_position: Vector3 = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready():
	var villager_instance: Villager = villager.instantiate()
	player_position_signal.connect(villager_instance._update_player_pos)
	villager_instance.position = Vector3(2, 2, 2)


func _on_devil_clown_position_signal(position):
	player_position_signal.emit(position)
