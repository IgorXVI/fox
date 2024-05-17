extends Area2D

@onready var sound: AudioStreamPlayer = $Sound

const POINTS: int = 1

func _on_area_entered(area: Area2D) -> void:
	set_collision_mask_value(2, false)
	sound.play()
	SignalManager.on_pickup_hit.emit(POINTS)
	hide()
