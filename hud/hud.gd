extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var v_box_level_complete: VBoxContainer = $VBoxLevelComplete
@onready var v_box_game_over: VBoxContainer = $VBoxGameOver
@onready var h_box_hearts: HBoxContainer = $MarginContainer/HBoxContainer/HBoxHearts

var _hearts: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hearts = h_box_hearts.get_children()
	SignalManager.on_level_complete.connect(on_level_complete)
	SignalManager.on_game_over.connect(on_game_over)
	SignalManager.on_player_hit.connect(on_player_hit)
	
func on_player_hit(lives: int):
	_hearts[lives - 1].visible = false

func on_level_complete():
	Engine.time_scale = 0
	color_rect.visible = true
	v_box_level_complete.visible = true
	
func on_game_over():
	Engine.time_scale = 0
	color_rect.visible = true
	v_box_game_over.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if v_box_level_complete.visible and Input.is_action_just_pressed("jump"):
		GameManager.load_next_level()
	
	if v_box_game_over.visible and Input.is_action_just_pressed("jump"):
		GameManager.load_main_scene()
