extends Control

@onready var pause_screen: Panel = $PauseScreen

func _ready() -> void:
	pause_screen.visible = false

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	pause_screen.visible = true
	get_tree().paused = true

func _on_back_pressed() -> void:
	pause_screen.visible = false
	get_tree().paused = false

func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Start.tscn")

func _on_controls_pressed() -> void:
	pass

func _on_hover() -> void:
	MusicManager.play_sfx(preload("res://assets/music/SFX/SweetSounds_SFX/WAV/Click.wav"))

func _on_pressed() -> void:
	MusicManager.play_sfx(preload("res://assets/music/SFX/SweetSounds_SFX/WAV/Bump.wav"))
