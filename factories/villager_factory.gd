extends Node3D

signal spawn_villager(villager_scene: PackedScene, relative_spawn_position: Vector3)

const MAX_VILLAGERS = 80

const VILLAGER_NORMAL_SCENE := preload("res://actors/villager/villager.tscn")
const VILLAGER_RANGED_SCENE := preload("res://actors/villager/villager_ranged.tscn")
const VILLAGER_HEAVY_SCENE := preload("res://actors/villager/villager_heavy.tscn")

const VILLAGERS := [VILLAGER_NORMAL_SCENE, VILLAGER_RANGED_SCENE]
const VILLAGER_SPAWN_WEIGHTS: Array[float] = [0.895, 0.1]

const MINI_BOSS_SCORE_THRESHOLD = 10
const MINI_BOSSES := [VILLAGER_HEAVY_SCENE]
const MINI_BOSS_SPAWN_WEIGHTS: Array[float] = [1.0]

var current_score_threshold := 10

@onready var path_follow: PathFollow3D = $Path3D/PathFollow3D


func _ready():
	for i in range(MAX_VILLAGERS):
		emit_spawn_villager()


func emit_spawn_villager():
	path_follow.progress_ratio = randf()
	var spawn_position = path_follow.position
	spawn_position.y += 1
	var villager_scene: PackedScene
	if (
		GlobalState.current_game_score >= current_score_threshold
		or Input.is_action_pressed("debug_spawn_mini_boss")
	):
		current_score_threshold += self.MINI_BOSS_SCORE_THRESHOLD
		villager_scene = Random.weighted_choice(self.MINI_BOSSES, self.MINI_BOSS_SPAWN_WEIGHTS)
	else:
		villager_scene = Random.weighted_choice(self.VILLAGERS, self.VILLAGER_SPAWN_WEIGHTS)
	self.spawn_villager.emit(villager_scene, spawn_position)


func _on_timer_timeout():
	emit_spawn_villager()
