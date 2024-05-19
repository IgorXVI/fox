extends Node2D

@onready var player_camera: Camera2D = $PlayerCamera
@onready var player: CharacterBody2D = $Player
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_game_over.connect(on_game_over)
	Engine.time_scale = 1

func _physics_process(delta: float) -> void:
	player_camera.position = player.position
	
func on_game_over():
	audio_stream_player.stop()
