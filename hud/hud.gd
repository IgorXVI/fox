extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var v_box_level_complete: VBoxContainer = $VBoxLevelComplete
@onready var v_box_game_over: VBoxContainer = $VBoxGameOver
@onready var h_box_hearts: HBoxContainer = $MarginContainer/HBoxContainer/HBoxHearts
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound
@onready var game_over_timer: Timer = $GameOverTimer

var _hearts: Array
var _game_over_timer_done = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score_label.text = "SCORE: %s" % ScoreManager.get_score_info()["score"]
	
	_hearts = h_box_hearts.get_children()
	SignalManager.on_level_complete.connect(on_level_complete)
	SignalManager.on_game_over.connect(on_game_over)
	SignalManager.on_player_hit.connect(on_player_hit)
	SignalManager.on_score_updated.connect(on_score_updated)

func on_score_updated(points: int):
	score_label.text = "SCORE: %s" % points

func on_player_hit(lives: int):
	_hearts[lives - 1].visible = false

func on_level_complete():
	Engine.time_scale = 0
	color_rect.visible = true
	v_box_level_complete.visible = true
	
func on_game_over():
	color_rect.visible = true
	v_box_game_over.visible = true
	
	game_over_sound.play()
	_game_over_timer_done = false
	game_over_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if v_box_level_complete.visible and Input.is_action_just_pressed("jump"):
		GameManager.load_next_level()
	
	if _game_over_timer_done and v_box_game_over.visible and Input.is_action_just_pressed("jump"):
		GameManager.load_main_scene()


func _on_game_over_timer_timeout() -> void:
	_game_over_timer_done = true
	Engine.time_scale = 0
