extends Node3D


func _ready():
	$DevilClown.died.connect(self._go_to_main_menu)
	$DevilClown.throw_water_balloon.connect(self._on_player_throw_water_balloon)
	$DevilClown.hit_cymbals.connect(self._on_cymbals_hit)


func _go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_water_balloon_explode(explosion_area: Area3D):
	if GlobalState.debug:
		add_child(explosion_area)
	print("Water balloon explode: ", explosion_area.position)


func _on_cymbals_hit(cymbal_area: Area3D):
	if GlobalState.debug:
		add_child(cymbal_area)
	print("Cymbals hit: ", cymbal_area.position)


func _on_player_throw_water_balloon(
	water_balloon_scene: PackedScene, balloon_position: Vector3, balloon_linear_velocity: Vector3
):
	var water_balloon: Node3D = water_balloon_scene.instantiate()

	water_balloon.position = balloon_position
	water_balloon.linear_velocity = balloon_linear_velocity
	water_balloon.explode.connect(self._on_water_balloon_explode)
	add_child(water_balloon)
