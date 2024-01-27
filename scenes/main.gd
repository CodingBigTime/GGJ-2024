extends Node3D

var clown_minion_scene: PackedScene = preload("res://actors/clown_minion/clown_minion.tscn")
var junk1: CompressedTexture2D = preload("res://assets/sprites/junk/junk1.png")
var junk2: CompressedTexture2D = preload("res://assets/sprites/junk/junk2.png")

var junk_options: Array[CompressedTexture2D] = [junk1, junk2]

@onready var devil_clown = $DevilClown
@onready var villager_factory = $DevilClown/VillagerFactory
@onready var score_label = $main_ui/AspectRatioContainer2/score_label
@onready var boost_bar = $main_ui/AspectRatioContainer/BoostBar


func _ready():
	self.devil_clown.died.connect(self._go_to_main_menu)
	self.devil_clown.throw_water_balloon.connect(self._on_player_throw_water_balloon)
	self.devil_clown.hit_cymbals.connect(self._on_cymbals_hit)
	self.devil_clown.power_updated.connect(self.boost_bar.update_value)
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
	print("Water balloon explode: ", water_balloon_aoe.position)


func _on_cymbals_hit(cymbals_aoe: CymbalsAoe):
	add_child(cymbals_aoe)
	print("Cymbals hit: ", cymbals_aoe.position)
	cymbals_aoe.hit_villager.connect(self._on_cymbals_hit_villager)


func _on_cymbals_hit_villager(villager: Villager):
	print("Cymbals hit villager: ", villager.position)
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
	# TODO: Add cloud or confetti particle effect
	return clown_minion


func _on_clown_minion_died(clown_minion: ClownMinion):
	# Convert clown minion to junk
	var junk_texture = Random.random_from_array(self.junk_options)
	var junk_sprite = Sprite3D.new()
	junk_sprite.texture = junk_texture
	junk_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	junk_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	junk_sprite.position = clown_minion.position
	# TODO: Add another particle effect
	add_child(junk_sprite)
