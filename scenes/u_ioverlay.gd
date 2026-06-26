extends Control
@onready var pause_screen: Panel = $PauseScreen


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_screen.visible = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() ->void:
	pause_screen.visible = true

func _on_quit_game_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

func _on_hover() -> void :
	MusicManager.play_sfx(preload("res://assets/music/SFX/SweetSounds_SFX/WAV/Click.wav"))
	
func _on_pressed() -> void:
	MusicManager.play_sfx(preload("res://assets/music/SFX/SweetSounds_SFX/WAV/Bump.wav"))
	
func _on_back_pressed() -> void:
	pause_screen.visible = false
	pass # Replace with function body.

func _on_main_menu_pressed() ->void:
	get_tree().change_scene_to_file("res://Scenes/Start.tscn")

func _on_controls_pressed() -> void:
	
	pass # Replace with function body.
