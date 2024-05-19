extends Node


enum BULLET_KEY { PLAYER, ENEMY, ROCK }

enum SCENE_KEY { EXPLOSION, PICKUP }

const BULLETS = {
	BULLET_KEY.PLAYER: preload("res://bullets/player_bullet/player_bullet.tscn"),
	BULLET_KEY.ENEMY: preload("res://bullets/enemy_bullet/enemy_bullet.tscn"),
	BULLET_KEY.ROCK: preload("res://bullets/rock_bullet/rock_bullet.tscn")
}

const SIMPLE_SCENES = {
	SCENE_KEY.EXPLOSION: preload("res://enemy_explosion/enemy_explosion.tscn"),
	SCENE_KEY.PICKUP: preload("res://fruit_pick_up/fruit_pick_up.tscn")
}

func add_child_deferred(child_to_add) -> void:
	get_tree().root.add_child(child_to_add)

func call_add_child(child_to_add) -> void:
	call_deferred("add_child_deferred", child_to_add)

func create_bullet(speed: float, direction: Vector2, start_pos: Vector2, life_span: float, key: BULLET_KEY):
	var new_b = BULLETS[key].instantiate()
	new_b.setup(direction, life_span, speed)
	new_b.global_position = start_pos
	call_add_child(new_b)
	
func create_simple_scene(start_pos: Vector2, key: SCENE_KEY) -> void:
	var new_scene = SIMPLE_SCENES[key].instantiate()
	
	new_scene.global_position = start_pos
	
	call_add_child(new_scene)
