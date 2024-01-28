class_name Villager
extends CharacterBody3D

signal died(villager: Villager)

enum State { IDLE, WANDER, FLEE, ATTACK }
enum Type { NORMAL, RANGED, HEAVY }

const CAN_ATTACK_TYPES = [Type.RANGED, Type.HEAVY]

const TEXTURES_NORMAL = {
	"normal_up": preload("res://assets/sprites/villagers/normal/villager_up.png"),
	"normal_down": preload("res://assets/sprites/villagers/normal/villager_down.png"),
	"left_normal": preload("res://assets/sprites/villagers/normal/villager_left.png"),
	"right_normal": preload("res://assets/sprites/villagers/normal/villager_right.png"),
	"left_up": preload("res://assets/sprites/villagers/normal/villager_up_left.png"),
	"right_up": preload("res://assets/sprites/villagers/normal/villager_up_right.png"),
	"left_down": preload("res://assets/sprites/villagers/normal/villager_down_left.png"),
	"right_down": preload("res://assets/sprites/villagers/normal/villager_down_right.png"),
}

const TEXTURES_RANGED = {
	"normal_up": preload("res://assets/sprites/villagers/ranged/villager_up.png"),
	"normal_down": preload("res://assets/sprites/villagers/ranged/villager_down.png"),
	"left_normal": preload("res://assets/sprites/villagers/ranged/villager_left.png"),
	"right_normal": preload("res://assets/sprites/villagers/ranged/villager_right.png"),
	"left_up": preload("res://assets/sprites/villagers/ranged/villager_up_left.png"),
	"right_up": preload("res://assets/sprites/villagers/ranged/villager_up_right.png"),
	"left_down": preload("res://assets/sprites/villagers/ranged/villager_down_left.png"),
	"right_down": preload("res://assets/sprites/villagers/ranged/villager_down_right.png"),
}

const TEXTURES = {
	Type.NORMAL: TEXTURES_NORMAL,
	Type.RANGED: TEXTURES_RANGED,
}

@export var type: Type = Type.NORMAL
@export var wander_speed = 2.0
@export var flee_speed = 3.0
@export var flee_distance = 5.0
@export var attack_distance = 10.0
@export var despawn_distance = 18.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_position := Vector3.ZERO
var marked_for_attack := false

var state = State.IDLE

@onready var current_state_timer: Timer = $StateTimer


func can_attack():
	return CAN_ATTACK_TYPES.has(self.type)


func _update_player_pos(player_pos: Vector3):
	player_position = player_pos


func _ready():
	current_state_timer.timeout.connect(_on_current_state_timer_timeout)


func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
	self.position.y = min(2, self.position.y)


func _process(_delta: float):
	$Sprite3D.texture = TEXTURES[self.type][ActorUtils.get_movement_string(
		Vector2(velocity.x, velocity.z)
	)]


func _attack():
	printerr("Normal villagers can't attack!")


func set_state(new_state: State):
	match [new_state, self.state]:
		[State.IDLE, ..]:
			# Stop moving
			self.velocity = Vector3.ZERO
		[State.WANDER, State.WANDER]:
			# Continue moving in the same direction, update speed
			var direction = self.velocity.normalized()
			self.velocity = direction * wander_speed
		[State.WANDER, ..]:
			# Choose a new random direction
			var random_angle = randf_range(0, 2 * PI)
			var direction = Vector3(cos(random_angle), 0, sin(random_angle))
			self.velocity = direction * wander_speed
		[State.FLEE, ..]:
			# Move away from the player
			var direction = self.position - player_position
			direction = direction.normalized()
			self.velocity = direction * self.flee_speed
		[State.ATTACK, ..]:
			_attack()
			self.velocity = Vector3.ZERO
	self.state = new_state


func _on_current_state_timer_timeout():
	var distance_to_player = self.position.distance_to(player_position)
	if distance_to_player > self.despawn_distance:
		queue_free()
	elif distance_to_player < self.flee_distance:
		self.set_state(State.FLEE)
	elif self.state == State.ATTACK:
		self.set_state(State.WANDER)
	elif self.can_attack() and distance_to_player < self.attack_distance:
		self.set_state(State.ATTACK)
	elif self.state == State.IDLE:
		if randf() > 0.2:
			self.set_state(State.WANDER)
		else:
			self.set_state(State.IDLE)
	elif self.state == State.WANDER:
		if randf() > 0.8:
			self.set_state(State.IDLE)
		else:
			self.set_state(State.WANDER)
	elif self.state == State.FLEE:
		if randf() > 0.5:
			self.set_state(State.IDLE)
		else:
			self.set_state(State.FLEE)


func mark_for_attack():
	marked_for_attack = true
	$Sprite3D.modulate = Color(0, 1, 1)


func die():
	died.emit(self)
	queue_free()
