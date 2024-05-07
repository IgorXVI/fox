extends Camera2D

@onready var shake_timer: Timer = $ShakeTimer

@export var shake_amount: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	SignalManager.on_player_hit.connect(on_player_hit)
	SignalManager.on_game_over.connect(on_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	offset = Vector2(
		randf_range(-shake_amount, shake_amount),
		randf_range(-shake_amount, shake_amount)
	)

func on_game_over():
	set_process(false)
	offset = Vector2.ZERO

func _on_shake_timer_timeout() -> void:
	set_process(false)
	offset = Vector2.ZERO

func on_player_hit(_lives: int):
	set_process(true)
	shake_timer.start()
