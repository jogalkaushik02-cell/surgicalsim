extends Node

## LocalSaveManager - Save/load everything locally (no cloud)

var save_directory: String = "user://saves/"
var max_save_slots: int = 3

signal save_success(slot: int)
signal save_error(slot: int, error: String)
signal load_success(slot: int, data: Dictionary)
signal load_error(slot: int, error: String)

func _ready() -> void:
	# Ensure save directory exists
	DirAccess.make_dir_recursive_absolute(save_directory)

func save_game(slot: int, game_data: Dictionary) -> bool:
	if slot < 0 or slot >= max_save_slots:
		save_error.emit(slot, "Invalid slot number")
		return false
	
	var save_data = {
		"slot": slot,
		"timestamp": Time.get_datetime_string_from_system(),
		"version": "1.0.0",
		"data": game_data
	}
	
	var file_path = save_directory + "save_slot_" + str(slot) + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		save_success.emit(slot)
		Events.log_event("game_saved", {"slot": slot})
		return true
	else:
		save_error.emit(slot, "Failed to open file")
		return false

func load_game(slot: int) -> Dictionary:
	if slot < 0 or slot >= max_save_slots:
		load_error.emit(slot, "Invalid slot number")
		return {}
	
	var file_path = save_directory + "save_slot_" + str(slot) + ".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK and json.data:
			load_success.emit(slot, json.data)
			Events.log_event("game_loaded", {"slot": slot})
			return json.data
	
	load_error.emit(slot, "No save found")
	return {}

func delete_save(slot: int) -> bool:
	var file_path = save_directory + "save_slot_" + str(slot) + ".json"
	
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		Events.log_event("save_deleted", {"slot": slot})
		return true
	return false

func get_save_info(slot: int) -> Dictionary:
	var file_path = save_directory + "save_slot_" + str(slot) + ".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK and json.data:
			return {
				"exists": true,
				"timestamp": json.data.get("timestamp", ""),
				"version": json.data.get("version", "")
			}
	
	return {"exists": false}

func get_all_saves() -> Array[Dictionary]:
	var saves = []
	for slot in range(max_save_slots):
		saves.append(get_save_info(slot))
	return saves

func has_any_saves() -> bool:
	for slot in range(max_save_slots):
		if get_save_info(slot).get("exists", false):
			return true
	return false

# ==================== SCORES ====================

func save_score(score_data: Dictionary) -> void:
	var scores = load_scores()
	
	score_data["timestamp"] = Time.get_datetime_string_from_system()
	scores.append(score_data)
	
	# Keep only top 100 scores
	scores.sort_custom(func(a, b): return a.get("score", 0) > b.get("score", 0))
	scores = scores.slice(0, 100)
	
	var file_path = save_directory + "scores.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(scores))
		file.close()

func load_scores() -> Array:
	var file_path = save_directory + "scores.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK and json.data:
			return json.data
	
	return []

func get_top_scores(limit: int = 10) -> Array:
	var scores = load_scores()
	return scores.slice(0, limit)

func clear_scores() -> void:
	var file_path = save_directory + "scores.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string("[]")
		file.close()

# ==================== SETTINGS ====================

func save_settings(settings: Dictionary) -> void:
	var file_path = save_directory + "settings.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()

func load_settings() -> Dictionary:
	var file_path = save_directory + "settings.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK and json.data:
			return json.data
	
	# Default settings
	return {
		"master_volume": 1.0,
		"sfx_volume": 0.8,
		"music_volume": 0.3,
		"haptic_enabled": true,
		"difficulty": "medium"
	}
