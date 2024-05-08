extends CharacterBody2D

class_name Player

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var debug_label: Label = $DebugLabel
@onready var sound_player: AudioStreamPlayer2D = $SoundPlayer
@onready var shooter: Node2D = $Shooter
@onready var animation_player_invincible: AnimationPlayer = $AnimationPlayerInvincible
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var hurt_timer: Timer = $HurtTimer
@onready var hit_box: Area2D = $HitBox


const GRAVITY: float = 1000.0
const RUN_SPEED: float = 300.0
const MAX_FALL_SPEED: float = 400.0
const JUMP_VELOCITY: float = -500.0
const HURT_JUMP_VELOCITY: float = -100.0
const FALL_OFF_MAX: float = 100

enum PLAYER_STATE { IDLE, RUN, JUMP, FALL, HURT }

var _state: PLAYER_STATE = PLAYER_STATE.IDLE
var _invincible = false
var _lives: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	fallen_off()
	
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		
	get_input()
		
	move_and_slide()
	
	calc_state()
	
	update_debug_label()
	
	if Input.is_action_just_pressed("shot"):
		shoot()
	
func update_debug_label() -> void:
	debug_label.text = "floor: %s\ninv: %s\nstate: %s\nlives: %s\nvel x: %.0f\nvel y: %.0f\n" % [
		is_on_floor(),
		_invincible,
		PLAYER_STATE.keys()[_state],
		_lives,
		velocity.x,
		velocity.y
	]

func shoot() -> void:
	if sprite_2d.flip_h:
		shooter.shoot(Vector2.LEFT)
	else:
		shooter.shoot(Vector2.RIGHT)

func get_input() -> void:
	if _state == PLAYER_STATE.HURT:
		return
	
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
			apply_hurt_jump()
		PLAYER_STATE.FALL:
			animation_player.play("fall")
		PLAYER_STATE.JUMP:
			animation_player.play("jump")


func go_invincible():
	_invincible = true
	animation_player_invincible.play("invincible")
	invincible_timer.start()
	
func apply_hurt_jump():
	animation_player.play("hurt")
	velocity.y = HURT_JUMP_VELOCITY
	hurt_timer.start()
	
func fallen_off():
	if global_position.y < FALL_OFF_MAX:
		return
	
	SignalManager.on_game_over.emit()
	set_physics_process(false)

func apply_hit():
	if _invincible:
		return
		
	_lives -= 1
	SignalManager.on_player_hit.emit(_lives)
	if _lives <= 0:
		SignalManager.on_game_over.emit()
		set_physics_process(false)
		return
	
	go_invincible()
	set_state(PLAYER_STATE.HURT)
	
	SoundManager.play_clip(sound_player, SoundManager.SOUND_DAMAGE)

func _on_hit_box_area_entered(area: Area2D) -> void:
	apply_hit()

func check_inside_danger():
	for area in hit_box.get_overlapping_areas():
		if area.is_in_group("Dangers"):
			apply_hit()
			return

func _on_invincible_timer_timeout() -> void:
	_invincible = false
	animation_player_invincible.stop()
	check_inside_danger()


func _on_hurt_timer_timeout() -> void:
	set_state(PLAYER_STATE.IDLE)
