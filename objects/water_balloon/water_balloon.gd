extends RigidBody3D

signal explode(water_balloon_aoe: WaterBalloonAoe)

const VARIANTS = {
	"blue": preload("res://assets/sprites/balloon/blue_balloon.png"),
	"pink": preload("res://assets/sprites/balloon/pink_balloon.png"),
	"gold": preload("res://assets/sprites/balloon/gold_balloon.png"),
}

var explosion_radius: float = 2
var water_balloon_aoe_scene: PackedScene = preload(
	"res://objects/water_balloon/water_balloon_aoe.tscn"
)


func _ready():
	var water_balloon_sprite = Sprite3D.new()
	water_balloon_sprite.texture = Random.random_from_array(VARIANTS.values())
	water_balloon_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	water_balloon_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	water_balloon_sprite.pixel_size = 0.03
	add_child(water_balloon_sprite)


func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("ground"):
		var water_balloon_aoe = water_balloon_aoe_scene.instantiate()
		water_balloon_aoe.position = self.position
		water_balloon_aoe.position.y = 0.6
		water_balloon_aoe.set_radius(explosion_radius)
		explode.emit(water_balloon_aoe)
		queue_free()
