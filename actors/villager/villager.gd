class_name Villager
extends CharacterBody3D

signal died(villager: Villager)

enum State { IDLE, WONDER, FLEE, ATTACK }

const WONDER_SPEED = 2.0
const FLEE_SPEED = 3.0
const FLEE_DISTANCE = 5.0
const DESPAWN_DISTANCE = 20.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_position := Vector3()
var marked_for_attack := false

var state = State.IDLE

@onready var current_state_timer: Timer = $StateTimer


func _update_player_pos(player_pos: Vector3):
	player_position = player_pos


func _ready():
	current_state_timer.timeout.connect(_on_current_state_timer_timeout)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()


func _on_current_state_timer_timeout():
	var distance_to_player = self.position.distance_to(player_position)
	if distance_to_player > self.DESPAWN_DISTANCE:
		queue_free()
	elif distance_to_player < self.FLEE_DISTANCE:
		state = State.FLEE
	else:
		match state:
			State.IDLE:
				if randf_range(0, 1) > 0.2:
					state = State.WONDER
					var random_angle = randf_range(0, 2 * PI)
					var direction = Vector3(cos(random_angle), 0, sin(random_angle))
					self.velocity = direction * self.WONDER_SPEED
				else:
					state = State.IDLE
			State.WONDER:
				if randf_range(0, 1) > 0.8:
					state = State.IDLE
				else:
					state = State.WONDER
			State.FLEE:
				if randf_range(0, 1) > 0.5:
					state = State.FLEE
				else:
					state = State.IDLE

	match state:
		State.IDLE:
			self.velocity = Vector3()
		State.FLEE:
			var direction = self.position - player_position
			direction = direction.normalized()
			self.velocity = direction * self.FLEE_SPEED


func mark_for_attack():
	marked_for_attack = true
	$Mark.visible = true
	$Sprite3D.visible = false


func die():
	died.emit(self)
	queue_free()
