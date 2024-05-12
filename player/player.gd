extends CharacterBody2D

class_name Player

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var debug_label: Label = $DebugLabel
@onready var sound_player: AudioStreamPlayer2D = $SoundPlayer
@onready var animation_player_invincible: AnimationPlayer = $AnimationPlayerInvincible
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var hurt_timer: Timer = $HurtTimer
@onready var hit_box: Area2D = $HitBox
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var ray_cast_right: RayCast2D = $RayCastRight


const GRAVITY: float = 800.0
const RUN_SPEED: float = 200.0
const MAX_FALL_SPEED: float = 400.0
const JUMP_VELOCITY: float = -300.0
const HURT_JUMP_VELOCITY: float = -100.0
const FALL_OFF_MAX: float = 100

const WALL_SLIDE: float = 20.0

enum PLAYER_STATE { IDLE, RUN, JUMP, FALL, HURT }

var _state: PLAYER_STATE = PLAYER_STATE.IDLE
var _invincible = false
var _lives: int = 5
var _can_coyote = true
var _jump_counter = 0
var _wall_jump_power = Vector2(300, -200)
var _wall_jump_direction = 0
var _is_wall_jumping = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	fallen_off()
		
	if !is_on_floor():
		velocity.y += GRAVITY * delta

		if _can_coyote and coyote_timer.is_stopped():
			coyote_timer.start()
	else:
		_can_coyote = true
		_is_wall_jumping = false
		_jump_counter = 0
		
	get_input()
		
	move_and_slide()
	
	calc_state()
	
	update_debug_label()
	
func update_debug_label() -> void:
	debug_label.text = "floor: %s\ninv: %s\nstate: %s\nlives: %s\nvel x: %.0f\nvel y: %.0f\n" % [
		is_on_floor(),
		_invincible,
		PLAYER_STATE.keys()[_state],
		_lives,
		velocity.x,
		velocity.y
	]

func get_input() -> void:
	if _state == PLAYER_STATE.HURT:
		return
		
	if is_on_wall() and Input.is_action_pressed("climb"):
		var flip_direction = false
		
		velocity.y = WALL_SLIDE
		
		if ray_cast_right.is_colliding():
			_wall_jump_direction = -1
			flip_direction = true
		else:
			_wall_jump_direction = 1
			flip_direction = false
		
		if Input.is_action_just_pressed("jump"):
			_is_wall_jumping = true
			sprite_2d.flip_h = flip_direction
			velocity = Vector2(_wall_jump_direction * _wall_jump_power.x, _wall_jump_power.y)
	
	if _is_wall_jumping:
		return
	
	velocity.x = 0
	
	if Input.is_action_pressed("left"):
		velocity.x = -RUN_SPEED
		sprite_2d.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = RUN_SPEED
		sprite_2d.flip_h = false
	
		
	if Input.is_action_just_pressed("jump") and _jump_counter < 1 and (is_on_floor() or _can_coyote):
		_jump_counter += 1
		
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


func _on_coyote_timer_timeout() -> void:
	_can_coyote = false
	coyote_timer.stop()


func _on_jump_kill_area_entered(area: Area2D) -> void:
	if !area.is_in_group("Dangers"):
		velocity.y = JUMP_VELOCITY
