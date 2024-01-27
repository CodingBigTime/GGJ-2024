class_name Villager
extends CharacterBody3D

signal died

const SPEED = 5.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_position = Vector3()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()


func _update_player_pos(player_pos):
	player_position = player_pos
