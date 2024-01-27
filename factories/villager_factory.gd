extends Node3D

signal spawn_villager(villager_scene: PackedScene, relative_spawn_position: Vector3)

const MAX_VILLAGERS = 50

var villager_scene = preload("res://actors/villager/villager.tscn")
@onready var path_follow: PathFollow3D = $Path3D/PathFollow3D


func _ready():
	for i in range(MAX_VILLAGERS):
		emit_spawn_villager()


func emit_spawn_villager():
	path_follow.progress_ratio = randf()
	var spawn_position = path_follow.position
	spawn_position.y += 1
	self.spawn_villager.emit(villager_scene, spawn_position)


func _on_timer_timeout():
	emit_spawn_villager()
