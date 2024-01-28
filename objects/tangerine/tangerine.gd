class_name Tangerine
extends RigidBody3D

const MAX_BOUNCES: int = 5
const PLAYER_DAMAGE: float = 5
var bounces: int = 0


func despawn():
	queue_free()


func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("player"):
		body.damage(5)
		despawn()
	elif body.is_in_group("minion"):
		body.die()
		despawn()
	elif body.is_in_group("ground"):
		bounces += 1
		# TODO: Play animation and maybe bounce sound
		if bounces >= MAX_BOUNCES:
			despawn()
