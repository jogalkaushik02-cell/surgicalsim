extends Node

## SurgeryCatalog - Lists all available and upcoming surgeries

# Available surgeries (working)
var available_surgeries: Array = [
	{
		"id": "appendicectomy",
		"name": "Appendicectomy",
		"description": "Removal of the appendix",
		"difficulty": "Beginner",
		"duration": "30-45 min",
		"instruments": ["Scalpel", "Forceps", "Retractor", "Suture"],
		"status": "available",
		"unlocked": true,
		"icon": "appendix"
	}
]

# Upcoming surgeries (options only, not working yet)
var upcoming_surgeries: Array = [
	{
		"id": "cholecystectomy",
		"name": "Cholecystectomy",
		"description": "Gallbladder removal",
		"difficulty": "Intermediate",
		"duration": "60-90 min",
		"instruments": ["Laparoscope", "Graspers", "Clip Applier", "Electrocautery"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "gallbladder",
		"release_date": "TBA"
	},
	{
		"id": "hernia_repair",
		"name": "Hernia Repair",
		"description": "Inguinal hernia repair",
		"difficulty": "Beginner",
		"duration": "45-60 min",
		"instruments": ["Scalpel", "Mesh", "Suture", "Retractor"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "hernia",
		"release_date": "TBA"
	},
	{
		"id": "laparotomy",
		"name": "Exploratory Laparotomy",
		"description": "Exploratory surgery of the abdomen",
		"difficulty": "Advanced",
		"duration": "90-180 min",
		"instruments": ["Scalpel", "Retractor", "Suction", "Suture"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "abdomen",
		"release_date": "TBA"
	},
	{
		"id": "thyroidectomy",
		"name": "Thyroidectomy",
		"description": "Thyroid gland removal",
		"difficulty": "Advanced",
		"duration": "90-150 min",
		"instruments": ["Scalpel", "Clamps", "Retractor", "Suction"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "thyroid",
		"release_date": "TBA"
	},
	{
		"id": "mastectomy",
		"name": "Mastectomy",
		"description": "Breast removal",
		"difficulty": "Advanced",
		"duration": "120-180 min",
		"instruments": ["Scalpel", "Electrocautery", "Retractor", "Drain"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "breast",
		"release_date": "TBA"
	},
	{
		"id": "colectomy",
		"name": "Colectomy",
		"description": "Colon removal",
		"difficulty": "Expert",
		"duration": "180-300 min",
		"instruments": ["Stapler", "Scalpel", "Retractor", "Anastomosis Kit"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "colon",
		"release_date": "TBA"
	},
	{
		"id": "nephrectomy",
		"name": "Nephrectomy",
		"description": "Kidney removal",
		"difficulty": "Expert",
		"duration": "120-240 min",
		"instruments": ["Scalpel", "Vascular Clamps", "Retractor", "Suction"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "kidney",
		"release_date": "TBA"
	},
	{
		"id": "splenectomy",
		"name": "Splenectomy",
		"description": "Spleen removal",
		"difficulty": "Intermediate",
		"duration": "90-150 min",
		"instruments": ["Scalpel", "Clamps", "Retractor", "Suture"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "spleen",
		"release_date": "TBA"
	},
	{
		"id": "craniotomy",
		"name": "Craniotomy",
		"description": "Skull opening for brain surgery",
		"difficulty": "Expert",
		"duration": "240-480 min",
		"instruments": ["Craniotome", "Drill", "Retractor", "Microscope"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "skull",
		"release_date": "TBA"
	},
	{
		"id": "knee_replacement",
		"name": "Total Knee Replacement",
		"description": "Replacement of knee joint",
		"difficulty": "Intermediate",
		"duration": "90-150 min",
		"instruments": ["Saw", "Hammer", "Implants", "Cement"],
		"status": "coming_soon",
		"unlocked": false,
		"icon": "knee",
		"release_date": "TBA"
	}
]

# Categories
var categories: Array = [
	{"id": "general", "name": "General Surgery", "icon": "surgery"},
	{"id": "orthopedic", "name": "Orthopedic", "icon": "bone"},
	{"id": "cardiothoracic", "name": "Cardiothoracic", "icon": "heart"},
	{"id": "neurosurgery", "name": "Neurosurgery", "icon": "brain"},
	{"id": "urology", "name": "Urology", "icon": "kidney"},
	{"id": "ent", "name": "ENT", "icon": "ear"},
	{"id": "ophthalmology", "name": "Ophthalmology", "icon": "eye"},
	{"id": "plastic", "name": "Plastic Surgery", "icon": "plastic"}
]

signal surgery_selected(surgery_id: String)
signal surgery_info_requested(surgery_id: String)

func _ready() -> void:
	pass

# ==================== QUERIES ====================

func get_available_surgeries() -> Array:
	return available_surgeries

func get_upcoming_surgeries() -> Array:
	return upcoming_surgeries

func get_all_surgeries() -> Array:
	return available_surgeries + upcoming_surgeries

func get_surgery_by_id(surgery_id: String) -> Dictionary:
	for surgery in available_surgeries:
		if surgery["id"] == surgery_id:
			return surgery
	for surgery in upcoming_surgeries:
		if surgery["id"] == surgery_id:
			return surgery
	return {}

func get_surgeries_by_difficulty(difficulty: String) -> Array:
	var result = []
	for surgery in available_surgeries:
		if surgery["difficulty"] == difficulty:
			result.append(surgery)
	return result

func get_surgeries_by_category(category_id: String) -> Array:
	# For now, all are general surgery
	if category_id == "general":
		return available_surgeries + upcoming_surgeries
	return []

func is_surgery_available(surgery_id: String) -> bool:
	for surgery in available_surgeries:
		if surgery["id"] == surgery_id:
			return true
	return false

func get_available_count() -> int:
	return available_surgeries.size()

func get_upcoming_count() -> int:
	return upcoming_surgeries.size()

func get_categories() -> Array:
	return categories

func select_surgery(surgery_id: String) -> void:
	if is_surgery_available(surgery_id):
		surgery_selected.emit(surgery_id)

func request_surgery_info(surgery_id: String) -> void:
	surgery_info_requested.emit(surgery_id)
