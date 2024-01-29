extends Node3D

const CLOWN_DROP_CHANCE = 0.4

var clown_minion_scene: PackedScene = preload("res://actors/clown_minion/clown_minion.tscn")
var junk_scene: PackedScene = preload("res://objects/junk/junk.tscn")
var confetti_scene: PackedScene = preload("res://scenes/particles/confetti.tscn")
var death_particles_scene: PackedScene = preload("res://scenes/particles/death_particles.tscn")

@onready var devil_clown = $DevilClown
@onready var villager_factory = $DevilClown/VillagerFactory
@onready var score_label = $MainHud/AspectRatioContainer2/ScoreLabel
@onready var boost_bar = $MainHud/AspectRatioContainer/BoostBar
@onready var aim_cursor = $MainHud/AimCursor
@onready var spell_1_label = $MainHud/Spell1AspectRatioContainer/Label
@onready var spell_2_label = $MainHud/Spell2AspectRatioContainer/Label


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	self.devil_clown.died.connect(self._go_to_main_menu)
	self.devil_clown.throw_water_balloon.connect(self._on_player_throw_water_balloon)
	self.devil_clown.hit_cymbals.connect(self._on_cymbals_hit)
	self.devil_clown.power_change.connect(self.boost_bar.update_value)
	self.devil_clown.cursor_update.connect(self._update_aim_cursor)
	self.devil_clown.input_method_update.connect(self._update_controls_tooltips)
	self.villager_factory.spawn_villager.connect(self._on_spawn_villager)


func get_current_villagers() -> Array[Villager]:
	var children = get_children()
	var villagers: Array[Villager] = []
	for child in children:
		if child.is_in_group("villager"):
			villagers.append(child)
	return villagers


func _go_to_main_menu():
	AudioHandlerSingleton.play_sound("game_over")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_water_balloon_explode(water_balloon_aoe: WaterBalloonAoe):
	add_child(water_balloon_aoe)


func _on_cymbals_hit(cymbals_aoe: CymbalsAoe):
	add_child(cymbals_aoe)
	cymbals_aoe.hit_villager.connect(self._on_cymbals_hit_villager)


func _on_cymbals_hit_villager(villager: Villager):
	if randf() < self.devil_clown.CYMBALS_CONVERT_CHANCE:
		villager.damage(1)


func _on_player_throw_water_balloon(water_balloon: WaterBalloon):
	water_balloon.explode.connect(self._on_water_balloon_explode)
	add_child(water_balloon)


func _spawn_tangerine(tangerine: Tangerine):
	add_child(tangerine)


func _slam_player(damage: float):
	self.devil_clown.damage(damage)


func _on_spawn_villager(villager_scene: PackedScene, relative_spawn_position: Vector3):
	var current_villagers = get_current_villagers()
	if current_villagers.size() >= self.villager_factory.MAX_VILLAGERS:
		return
	var villager: Node3D = villager_scene.instantiate()
	self.devil_clown.position_updated.connect(villager._update_player_pos)
	villager.position = self.devil_clown.position + relative_spawn_position
	villager.died.connect(self._on_villager_died)
	if villager.has_signal("throw_tangerine"):
		villager.throw_tangerine.connect(self._spawn_tangerine)
	if villager.has_signal("slam_player"):
		villager.slam_player.connect(self._slam_player)
	add_child(villager)


func _on_villager_died(villager: Villager):
	# Convert villager to clown minion
	self.score_label.increase_score(1)
	var clown_minion: ClownMinion = self.clown_minion_scene.instantiate()
	if villager.marked_for_attack:
		clown_minion.enraged = true
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

	AudioHandlerSingleton.play_sound("convert")

	return clown_minion


func _on_clown_minion_died(_clown_minion: ClownMinion):
	# Convert clown minion to junk
	if randf() > CLOWN_DROP_CHANCE:
		var junk = junk_scene.instantiate()
		junk.position = _clown_minion.position
		junk.position.y = 0
		add_child(junk)
	var smoke = death_particles_scene.instantiate()
	smoke.position = _clown_minion.position
	smoke.set_one_time()
	add_child(smoke)


func _update_aim_cursor(coordinates: Vector2):
	self.aim_cursor.position = coordinates


func _update_controls_tooltips(input_method: DevilClown.InputMethod):
	match input_method:
		DevilClown.InputMethod.MOUSE:
			self.spell_1_label.text = "Shift / LClick"
			self.spell_2_label.text = "Space / RClick"
		DevilClown.InputMethod.CONTROLLER:
			self.spell_1_label.text = "RTrigger"
			self.spell_2_label.text = "LTrigger"
		_:
			printerr("Unknown input method: ", input_method)
