extends Node2D

@onready var sound: AudioStreamPlayer2D = $Sound
@onready var shoot_timer: Timer = $ShootTimer

@export var speed: float = 50.0
@export var life_span: float = 10.0
@export var bullet_key: ObjectMaker.BULLET_KEY = ObjectMaker.BULLET_KEY.ROCK
@export var shoot_delay: float = 0.7

var _can_shoot = true

func _read() -> void:
	shoot_timer.wait_time = shoot_delay

func shoot(direction: Vector2) -> void:
	if !_can_shoot:
		return
	
	_can_shoot = false
	SoundManager.play_clip(sound, SoundManager.SOUND_LASER)
	ObjectMaker.create_bullet(speed, direction, global_position, life_span, bullet_key)


func _on_shoot_timer_timeout() -> void:
	_can_shoot = true
