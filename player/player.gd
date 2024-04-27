extends CharacterBody2D

class_name Player

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var debug_label: Label = $DebugLabel
@onready var sound_player: AudioStreamPlayer2D = $SoundPlayer
@onready var shooter: Node2D = $Shooter


const GRAVITY: float = 1000.0
const RUN_SPEED: float = 120.0
const MAX_FALL_SPEED: float = 400.0
const HURT_TIME: float = 0.3
const JUMP_VELOCITY: float = -400.0

enum PLAYER_STATE { IDLE, RUN, JUMP, FALL, HURT }

var _state: PLAYER_STATE = PLAYER_STATE.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		
	get_input()
		
	move_and_slide()
	
	calc_state()
	
	update_debug_label()
	
	if Input.is_action_just_pressed("shot"):
		shoot()
	
func update_debug_label() -> void:
	debug_label.text = "floor: %s\nstate: %s\nvel x: %.0f\nvel y: %.0f\n" % [
		is_on_floor(),
		PLAYER_STATE.keys()[_state],
		velocity.x,
		velocity.y
	]

func shoot() -> void:
	if sprite_2d.flip_h:
		shooter.shoot(Vector2.LEFT)
	else:
		shooter.shoot(Vector2.RIGHT)

func get_input() -> void:
	velocity.x = 0
	
	if Input.is_action_pressed("left"):
		velocity.x = -RUN_SPEED
		sprite_2d.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = RUN_SPEED
		sprite_2d.flip_h = false
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		SoundManager.play_clip(sound_player, SoundManager.SOUND_JUMP)
	
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL_SPEED)

func calc_state() -> void:
	if _state == PLAYER_STATE.HURT:
		return
	
	if is_on_floor():
		if velocity.x == 0:
			set_state(PLAYER_STATE.IDLE)
			pass
		else:
			set_state(PLAYER_STATE.RUN)
			pass
	else:
		if velocity.y > 0:
			set_state(PLAYER_STATE.FALL)
			pass
		else:
			set_state(PLAYER_STATE.JUMP)
			pass

func set_state(new_state: PLAYER_STATE) -> void:
	if new_state == _state:
		return
		
	if _state == PLAYER_STATE.FALL and (new_state == PLAYER_STATE.IDLE or new_state == PLAYER_STATE.RUN):
		SoundManager.play_clip(sound_player, SoundManager.SOUND_LAND)
	
	_state = new_state
	
	match _state:
		PLAYER_STATE.IDLE:
			animation_player.play("iddle")
		PLAYER_STATE.RUN:
			animation_player.play("run")
		PLAYER_STATE.HURT:
			animation_player.play("hurt")
		PLAYER_STATE.FALL:
			animation_player.play("fall")
		PLAYER_STATE.JUMP:
			animation_player.play("jump")


func _on_hit_box_area_entered(area: Area2D) -> void:
	print("area hit")
