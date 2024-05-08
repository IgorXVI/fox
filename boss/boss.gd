extends Node2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var visual: Node2D = $Visual
@onready var hit_box: Area2D = $Visual/HitBox

@export var lives: int = 5
@export var points: int = 5

const TRIGGER_CONDITION = "parameters/conditions/on_trigger"
const HIT_CONDITION = "parameters/conditions/on_hit"

var _invincible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hit_box.set_collision_mask_value(4, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_invincible(value: bool):
	_invincible = value
	animation_tree[HIT_CONDITION] = value

func take_damage():
	if _invincible:
		return
	
	set_invincible(true)
	tween_hit()
	reduce_lives()

func _on_trigger_area_entered(area: Area2D) -> void:
	if !animation_tree[TRIGGER_CONDITION]:
		animation_tree[TRIGGER_CONDITION] = true
		hit_box.set_collision_mask_value(4, true)

func tween_hit():
	var tween = get_tree().create_tween()
	tween.tween_property(visual, "position", Vector2.ZERO, 1.0)

func reduce_lives():
	lives -= 1
	if lives <= 0:
		SignalManager.on_boss_killed.emit(points)
		set_process(false)
		queue_free()

func _on_hit_box_area_entered(area: Area2D) -> void:
	take_damage()
