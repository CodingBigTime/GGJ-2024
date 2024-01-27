extends Control

enum GameScene {
	MAIN,
	TEST_2D,
	TEST_3D,
}

const MAIN_SCENE_FILE = "res://scenes/main.tscn"

@export var game_scene: GameScene = GameScene.MAIN


func _ready():
	get_window().size = Vector2(1280, 720)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func start_game():
	get_tree().change_scene_to_file(MAIN_SCENE_FILE)


func quit_game():
	get_tree().quit()


func _process(_delta: float):
	if Input.is_action_just_pressed("ui_select"):
		start_game()
	elif Input.is_action_just_pressed("ui_cancel"):
		quit_game()


func _on_start_button_pressed():
	start_game()


func _on_exit_button_pressed():
	quit_game()


func _on_butremove_meta():
	$ButtonDownSFX.play()


func _on_button_up():
	$ButtonUpSFX.play()
