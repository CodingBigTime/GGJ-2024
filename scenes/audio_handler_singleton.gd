extends Node

const SFX = {
	"convert": "res://assets/sfx/convert.wav",
	"clown_die": "res://assets/sfx/clown_die.wav",
	"splash": "res://assets/sfx/splash.wav"
}
@onready var players = $AudioStreamPlayers


func play_sound(sound_name: String) -> void:
	for player in players.get_children():
		if player.playing:
			continue
		player.stream = load(SFX[sound_name])
		player.play()
		return

	var new_player = AudioStreamPlayer.new()
	new_player.stream = load(sound_name)
	new_player.play()
	players.add_child(new_player)


func stop_all_sounds() -> void:
	for player in players:
		player.stop()
		player.stream = null
	players.clear()
