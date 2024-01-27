extends RigidBody3D

signal explode(water_balloon_aoe: WaterBalloonAoe)

var explosion_radius: float = 1
var water_balloon_aoe_scene: PackedScene = preload(
	"res://objects/water_balloon/water_balloon_aoe.tscn"
)


func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("ground"):
		var water_balloon_aoe = water_balloon_aoe_scene.instantiate()
		water_balloon_aoe.position = self.position
		water_balloon_aoe.position.y = 0.6
		water_balloon_aoe.set_radius(explosion_radius)
		explode.emit(water_balloon_aoe)
		queue_free()
