extends Node3D

const CLOWN_DROP_CHANCE = 0.4

var clown_minion_scene: PackedScene = preload("res://actors/clown_minion/clown_minion.tscn")
var junk_scene: PackedScene = preload("res://objects/junk/junk.tscn")
var confetti_scene: PackedScene = preload("res://scenes/particles/confetti.tscn")

@onready var devil_clown = $DevilClown
@onready var villager_factory = $DevilClown/VillagerFactory
@onready var score_label = $main_ui/AspectRatioContainer2/ScoreLabel
@onready var boost_bar = $main_ui/AspectRatioContainer/BoostBar


func _ready():
	self.devil_clown.died.connect(self._go_to_main_menu)
	self.devil_clown.throw_water_balloon.connect(self._on_player_throw_water_balloon)
	self.devil_clown.hit_cymbals.connect(self._on_cymbals_hit)
	self.devil_clown.power_change.connect(self.boost_bar.update_value)
	print_debug(self.villager_factory)
	self.villager_factory.spawn_villager.connect(self._on_spawn_villager)


func get_current_villagers() -> Array[Villager]:
	var children = get_children()
	var villagers: Array[Villager] = []
	for child in children:
		if child.is_in_group("villager"):
			villagers.append(child)
	return villagers


func _go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_water_balloon_explode(water_balloon_aoe: WaterBalloonAoe):
	add_child(water_balloon_aoe)


func _on_cymbals_hit(cymbals_aoe: CymbalsAoe):
	add_child(cymbals_aoe)
	cymbals_aoe.hit_villager.connect(self._on_cymbals_hit_villager)


func _on_cymbals_hit_villager(villager: Villager):
	if randf() < self.devil_clown.CYMBALS_CONVERT_CHANCE:
		villager.die()


func _on_player_throw_water_balloon(
	water_balloon_scene: PackedScene, balloon_position: Vector3, balloon_linear_velocity: Vector3
):
	var water_balloon: Node3D = water_balloon_scene.instantiate()

	water_balloon.position = balloon_position
	water_balloon.linear_velocity = balloon_linear_velocity
	water_balloon.explode.connect(self._on_water_balloon_explode)
	add_child(water_balloon)


func _on_spawn_villager(villager_scene: PackedScene, relative_spawn_position: Vector3):
	var current_villagers = get_current_villagers()
	if current_villagers.size() >= self.villager_factory.MAX_VILLAGERS:
		return
	var villager: Node3D = villager_scene.instantiate()
	self.devil_clown.position_updated.connect(villager._update_player_pos)
	villager.position = self.devil_clown.position + relative_spawn_position
	villager.died.connect(self._on_villager_died)
	add_child(villager)


func _on_villager_died(villager: Villager):
	# Convert villager to clown minion
	self.score_label.increase_score(1)
	var clown_minion = self.clown_minion_scene.instantiate()
	clown_minion.position = villager.position

	self.devil_clown.position_updated.connect(clown_minion._update_player_pos)
	clown_minion.died.connect(self._on_clown_minion_died)
	add_child(clown_minion)

	var confetti = confetti_scene.instantiate()
	confetti.position = clown_minion.position
	confetti.amount = 64
	confetti.one_shot = true
	confetti.emitting = true
	add_child(confetti)

	return clown_minion


func _on_clown_minion_died(_clown_minion: ClownMinion):
	# Convert clown minion to junk
	if randf() > CLOWN_DROP_CHANCE:
		return
	var junk = junk_scene.instantiate()
	junk.position = _clown_minion.position
	# TODO: Add another particle effect
	add_child(junk)
