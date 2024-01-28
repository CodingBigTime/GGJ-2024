extends Node

const SFX = {
	"convert": preload("res://assets/sfx/convert.wav"),
	"clown_die": preload("res://assets/sfx/clown_die.wav"),
	"splash": preload("res://assets/sfx/splash.wav"),
	"power_up": preload("res://assets/sfx/power_up.wav"),
	"player_hurt": preload("res://assets/sfx/player_hurt.wav"),
	"game_over": preload("res://assets/sfx/game_over.wav"),
	"try_convert": preload("res://assets/sfx/try_convert.wav")
}
@onready var players = $AudioStreamPlayers


func play_sound(sound_name: String) -> void:
	for player in players.get_children():
		if player.playing:
			continue
		player.stream = SFX[sound_name]
		player.play()
		return

	var new_player = AudioStreamPlayer.new()
	new_player.stream = SFX[sound_name]
	new_player.play()
	players.add_child(new_player)


func stop_all_sounds() -> void:
	for player in players:
		player.stop()
		player.stream = null
	players.clear()
