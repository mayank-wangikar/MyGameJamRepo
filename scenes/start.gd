extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

var player : AudioStreamPlayer

func _ready():
	main_buttons.visible = true
	options.visible = false
	# play music ONCE via global manager
	MusicManager.play_music(preload("res://assets/music/LVER.wav"))
	

func _on_start_button_pressed() -> void :
	get_tree().change_scene_to_file("res://Scenes/Clockscene.tscn")
	MusicManager.play_sfx(preload("res://assets/music/SFX/SweetSounds_SFX/WAV/Bump.wav"))


func _on_hover() -> void :
	MusicManager.play_sfx(preload("res://assets/music/SFX/SweetSounds_SFX/WAV/Click.wav"))
	
func _on_options_pressed() -> void:
	MusicManager.play_sfx(preload("res://assets/music/SFX/SweetSounds_SFX/WAV/Bump.wav"))
	main_buttons.visible = false
	options.visible = true


func _on_controls_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/ControlsScreen.tscn")

# Quit button
func _on_quit_button_pressed() -> void:
	MusicManager.play_sfx(preload("res://assets/music/SFX/SweetSounds_SFX/WAV/Bump.wav"))

	get_tree().quit()


func _on_back_pressed() -> void:
	MusicManager.play_sfx(preload("res://assets/music/SFX/SweetSounds_SFX/WAV/Bump.wav"))
 # Replace with function body.


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
	pass # Replace with function body.
