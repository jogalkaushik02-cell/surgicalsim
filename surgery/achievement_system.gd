extends Node

## AchievementSystem - Track and unlock achievements

signal achievement_unlocked(achievement: Dictionary)
signal achievement_progress_updated(achievement_id: String, progress: float)

# All achievements
var achievements: Dictionary = {
	"first_surgery": {
		"id": "first_surgery",
		"name": "First Steps",
		"description": "Complete your first surgery",
		"icon": "surgery",
		"unlocked": false,
		"progress": 0,
		"max_progress": 1,
		"reward": "Beginner Badge"
	},
	"perfect_surgery": {
		"id": "perfect_surgery",
		"name": "Perfect Score",
		"description": "Get 100% score on any surgery",
		"icon": "star",
		"unlocked": false,
		"progress": 0,
		"max_progress": 1,
		"reward": "Master Badge"
	},
	"speed_demon": {
		"id": "speed_demon",
		"name": "Speed Demon",
		"description": "Complete a surgery in under 3 minutes",
		"icon": "timer",
		"unlocked": false,
		"progress": 0,
		"max_progress": 1,
		"reward": "Speed Badge"
	},
	"no_bleeding": {
		"id": "no_bleeding",
		"name": "Bloodless",
		"description": "Complete a surgery with zero bleeding",
		"icon": "heart",
		"unlocked": false,
		"progress": 0,
		"max_progress": 1,
		"reward": "Precision Badge"
	},
	"five_surgeries": {
		"id": "five_surgeries",
		"name": "Getting Started",
		"description": "Complete 5 surgeries",
		"icon": "surgery",
		"unlocked": false,
		"progress": 0,
		"max_progress": 5,
		"reward": "Practice Badge"
	},
	"ten_surgeries": {
		"id": "ten_surgeries",
		"name": "Experienced",
		"description": "Complete 10 surgeries",
		"icon": "surgery",
		"unlocked": false,
		"progress": 0,
		"max_progress": 10,
		"reward": "Experienced Badge"
	},
	"twentyfive_surgeries": {
		"id": "twentyfive_surgeries",
		"name": "Veteran",
		"description": "Complete 25 surgeries",
		"icon": "surgery",
		"unlocked": false,
		"progress": 0,
		"max_progress": 25,
		"reward": "Veteran Badge"
	},
	"fifty_surgeries": {
		"id": "fifty_surgeries",
		"name": "Master Surgeon",
		"description": "Complete 50 surgeries",
		"icon": "surgery",
		"unlocked": false,
		"progress": 0,
		"max_progress": 50,
		"reward": "Master Badge"
	},
	"team_player": {
		"id": "team_player",
		"name": "Team Player",
		"description": "Complete 5 multiplayer surgeries",
		"icon": "team",
		"unlocked": false,
		"progress": 0,
		"max_progress": 5,
		"reward": "Team Badge"
	},
	"leader": {
		"id": "leader",
		"name": "Leader",
		"description": "Complete 10 surgeries as Lead Surgeon",
		"icon": "leader",
		"unlocked": false,
		"progress": 0,
		"max_progress": 10,
		"reward": "Leadership Badge"
	},
	"assistant_pro": {
		"id": "assistant_pro",
		"name": "Assistant Pro",
		"description": "Complete 10 surgeries as Assistant",
		"icon": "assistant",
		"unlocked": false,
		"progress": 0,
		"max_progress": 10,
		"reward": "Assistance Badge"
	},
	"nurse_expert": {
		"id": "nurse_expert",
		"name": "Nurse Expert",
		"description": "Complete 10 surgeries as Scrub Nurse",
		"icon": "nurse",
		"unlocked": false,
		"progress": 0,
		"max_progress": 10,
		"reward": "Nursing Badge"
	},
	"tutorial_master": {
		"id": "tutorial_master",
		"name": "Quick Learner",
		"description": "Complete the tutorial",
		"icon": "tutorial",
		"unlocked": false,
		"progress": 0,
		"max_progress": 1,
		"reward": "Learning Badge"
	},
	"all_roles": {
		"id": "all_roles",
		"name": "Jack of All Trades",
		"description": "Complete a surgery in each role",
		"icon": "roles",
		"unlocked": false,
		"progress": 0,
		"max_progress": 4,
		"reward": "Versatility Badge"
	},
	"complication_master": {
		"id": "complication_master",
		"name": "Crisis Manager",
		"description": "Complete 5 surgeries with complications",
		"icon": "crisis",
		"unlocked": false,
		"progress": 0,
		"max_progress": 5,
		"reward": "Crisis Badge"
	}
}

func _ready() -> void:
	_load_achievements()

# ==================== ACHIEVEMENT TRACKING ====================

func on_surgery_completed(stats: Dictionary) -> void:
	var score = stats.get("score", 0)
	var time = stats.get("time", 0)
	var bleeding = stats.get("bleeding", 0)
	var is_multiplayer = stats.get("is_multiplayer", false)
	var role = stats.get("role", 0)
	var had_complications = stats.get("complications", false)
	
	# First surgery
	_unlock_progress("first_surgery", 1)
	
	# Perfect score
	if score >= 100:
		_unlock_progress("perfect_surgery", 1)
	
	# Speed demon
	if time < 180:
		_unlock_progress("speed_demon", 1)
	
	# No bleeding
	if bleeding <= 0:
		_unlock_progress("no_bleeding", 1)
	
	# Surgery count achievements
	_unlock_progress("five_surgeries", 1)
	_unlock_progress("ten_surgeries", 1)
	_unlock_progress("twentyfive_surgeries", 1)
	_unlock_progress("fifty_surgeries", 1)
	
	# Team player
	if is_multiplayer:
		_unlock_progress("team_player", 1)
	
	# Role-based achievements
	match role:
		0:  # Lead Surgeon
			_unlock_progress("leader", 1)
		1:  # Assistant
			_unlock_progress("assistant_pro", 1)
		2:  # Scrub Nurse
			_unlock_progress("nurse_expert", 1)
	
	# Complication master
	if had_complications:
		_unlock_progress("complication_master", 1)

func on_tutorial_completed() -> void:
	_unlock_progress("tutorial_master", 1)

func on_role_played(role: int) -> void:
	_unlock_progress("all_roles", 1)

# ==================== PROGRESS ====================

func _unlock_progress(achievement_id: String, amount: int) -> void:
	if not achievements.has(achievement_id):
		return
	
	var achievement = achievements[achievement_id]
	if achievement["unlocked"]:
		return
	
	achievement["progress"] = min(achievement["progress"] + amount, achievement["max_progress"])
	achievement_progress_updated.emit(achievement_id, float(achievement["progress"]) / float(achievement["max_progress"]))
	
	if achievement["progress"] >= achievement["max_progress"]:
		achievement["unlocked"] = true
		achievement_unlocked.emit(achievement)
		_save_achievements()
		print("Achievement unlocked: ", achievement["name"])

# ==================== SAVE/LOAD ====================

func _save_achievements() -> void:
	var save_data = {}
	for id in achievements:
		save_data[id] = {
			"unlocked": achievements[id]["unlocked"],
			"progress": achievements[id]["progress"]
		}
	
	var file = FileAccess.open("user://achievements.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func _load_achievements() -> void:
	var file = FileAccess.open("user://achievements.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK:
			var save_data = json.data
			for id in save_data:
				if achievements.has(id):
					achievements[id]["unlocked"] = save_data[id].get("unlocked", false)
					achievements[id]["progress"] = save_data[id].get("progress", 0)

# ==================== QUERIES ====================

func get_all_achievements() -> Array:
	return achievements.values()

func get_unlocked_achievements() -> Array:
	var unlocked = []
	for achievement in achievements.values():
		if achievement["unlocked"]:
			unlocked.append(achievement)
	return unlocked

func get_locked_achievements() -> Array:
	var locked = []
	for achievement in achievements.values():
		if not achievement["unlocked"]:
			locked.append(achievement)
	return locked

func get_achievement(id: String) -> Dictionary:
	return achievements.get(id, {})

func get_total_achievements() -> int:
	return achievements.size()

func get_unlocked_count() -> int:
	return get_unlocked_achievements().size()

func get_completion_percentage() -> float:
	return float(get_unlocked_count()) / float(get_total_achievements()) * 100.0
