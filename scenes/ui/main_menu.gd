extends Control

enum GameScene {
	MAIN,
	TEST_2D,
	TEST_3D,
}

const MAIN_SCENE_FILE = "res://scenes/main.tscn"
const TEST_2D_SCENE_FILE = "res://scenes/testing/main_2d.tscn"
const TEST_3D_SCENE_FILE = "res://scenes/testing/main_3d.tscn"

@export var game_scene: GameScene = GameScene.MAIN


func _ready():
	get_window().size = Vector2(1280, 720)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func start_game():
	var scene: String
	match game_scene:
		GameScene.MAIN:
			scene = MAIN_SCENE_FILE
		GameScene.TEST_2D:
			scene = TEST_2D_SCENE_FILE
		GameScene.TEST_3D:
			scene = TEST_3D_SCENE_FILE
		_:
			printerr("Invalid game scene: " + str(game_scene))
			return

	get_tree().change_scene_to_file(scene)


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
