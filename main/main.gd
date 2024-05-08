extends CanvasLayer
@onready var label_high_score: Label = $VBoxContainer/LabelHighScore


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_high_score.text = "HIGH SCORE: %s" % ScoreManager.get_score_info()["high_score"]
	
	Engine.time_scale = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		GameManager.load_next_level()
