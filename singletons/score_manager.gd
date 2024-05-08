extends Node


const HS_FILE: String = "user://SCORES.json"

var _score = 0
var _high_score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_highscore()
	
	SignalManager.on_boss_killed.connect(update_score)
	SignalManager.on_pickup_hit.connect(update_score)
	SignalManager.on_enemy_hit.connect(on_enemy_hit)
	
	SignalManager.on_level_complete.connect(save_highscore)
	SignalManager.on_game_over.connect(save_highscore)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_enemy_hit(points: int, _enemy_position: Vector2):
	update_score(points)
	
func update_score(points: int):
	_score += points
	
	if _score > _high_score:
		_high_score = _score
	
	SignalManager.on_score_updated.emit(_score)
	

func reset_score():
	_score = 0

func get_score_info() -> Dictionary:
	return {
		"score": _score,
		"high_score": _high_score
	}

func load_highscore():
	if !FileAccess.file_exists(HS_FILE):
		return
	
	var file = FileAccess.open(HS_FILE, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	print("loaded: ", data)
	
	if "high_score" in data:
		_high_score = data["high_score"]
		

func save_highscore():
	var file = FileAccess.open(HS_FILE, FileAccess.WRITE)
	
	var data = {
		"high_score": _high_score
	}
	
	var data_str = JSON.stringify(data)
	
	file.store_string(data_str)
	
	print("saved: ", data)
