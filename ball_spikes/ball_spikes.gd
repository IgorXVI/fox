extends PathFollow2D

@export var speed: float = 0.05

func _process(delta: float) -> void:
	progress_ratio += delta * speed
