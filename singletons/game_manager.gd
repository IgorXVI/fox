extends Node

const GROUP_PLAYER: String = "player"
const TOTAL_LEVELS: int = 4
const MAIN_SCENE: PackedScene = preload("res://main/main.tscn")

var _current_level: int = 0
var _level_scenes = {}

func _ready() -> void:
	for i in range(1, TOTAL_LEVELS + 1):
		_level_scenes[i] = load("res://levels/level_%s.tscn" % i)

func load_main_scene():
	ScoreManager.reset_score()
	
	_current_level = 0
	get_tree().change_scene_to_packed(MAIN_SCENE)
	
func load_next_level():	
	_current_level += 1
	
	if _current_level > TOTAL_LEVELS:
		load_main_scene()
	else:
		get_tree().change_scene_to_packed(_level_scenes[_current_level])
