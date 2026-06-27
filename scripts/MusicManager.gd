extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready() -> void:
	# MUSIC
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	# SFX (optional separate channel)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

func play_music(stream: AudioStream):
	if music_player.stream == stream and music_player.playing:
		return
	# Enable looping based on the stream type
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
	music_player.stream = stream
	music_player.play()

func play_sfx(stream: AudioStream):
	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = stream
	add_child(player)

	player.finished.connect(func():
		player.queue_free()
	)

	player.play()
