extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		GameManager.load_next_level()
