extends Area2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

const TRIGGER_CONDITION = "parameters/conditions/on_trigger"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_boss_killed.connect(on_boss_killed)

	
func on_boss_killed(_points: int):
	animation_tree[TRIGGER_CONDITION] = true
	monitoring = true
	SoundManager.play_clip(audio_stream_player_2d, SoundManager.SOUND_WIN)


func _on_area_entered(area: Area2D) -> void:
	print("LEVEL COMPLETE")
