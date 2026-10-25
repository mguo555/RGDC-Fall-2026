extends Node2D

@onready var music_player = AudioStreamPlayer.new()
@onready var sfx_player = AudioStreamPlayer.new()

func _ready():
	add_child(music_player)
	add_child(sfx_player)
	music_player.volume_db = -15
	sfx_player.volume_db = -15
	
func play_music(stream: AudioStream):
	print("Playing music")
	music_player.stream = stream
	music_player.play()

func play_sfx(stream: AudioStream):
	print("Playing sfx")
	sfx_player.stream = stream
	sfx_player.play()
	
