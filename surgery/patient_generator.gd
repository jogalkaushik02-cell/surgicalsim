extends Node

## PatientGenerator - Creates random patients with variability

# Patient templates
var patient_templates: Array[Dictionary] = [
	{
		"name": "John Smith",
		"age": 35,
		"gender": "Male",
		"bmi": 24.5,
		"conditions": [],
		"difficulty": "easy"
	},
	{
		"name": "Sarah Johnson",
		"age": 28,
		"gender": "Female",
		"bmi": 22.0,
		"conditions": [],
		"difficulty": "easy"
	},
	{
		"name": "Robert Chen",
		"age": 45,
		"gender": "Male",
		"bmi": 32.5,
		"conditions": ["hypertension"],
		"difficulty": "medium"
	},
	{
		"name": "Maria Garcia",
		"age": 52,
		"gender": "Female",
		"bmi": 28.0,
		"conditions": ["diabetes", "obesity"],
		"difficulty": "medium"
	},
	{
		"name": "James Wilson",
		"age": 68,
		"gender": "Male",
		"bmi": 26.0,
		"conditions": ["heart_disease", "hypertension", "diabetes"],
		"difficulty": "hard"
	},
	{
		"name": "Emily Brown",
		"age": 19,
		"gender": "Female",
		"bmi": 19.5,
		"conditions": [],
		"difficulty": "easy"
	},
	{
		"name": "Ahmed Hassan",
		"age": 42,
		"gender": "Male",
		"bmi": 35.0,
		"conditions": ["obesity", "sleep_apnea"],
		"difficulty": "hard"
	},
	{
		"name": "Lisa Anderson",
		"age": 38,
		"gender": "Female",
		"bmi": 23.0,
		"conditions": ["asthma"],
		"difficulty": "medium"
	}
]

# Complication types
var possible_complications: Array[Dictionary] = [
	{
		"type": "adhesions",
		"description": "Scar tissue from previous surgery",
		"severity": "medium",
		"effect": "Makes tissue planes difficult to identify"
	},
	{
		"type": "obesity",
		"description": "Excess abdominal fat",
		"severity": "medium",
		"effect": "Longer incision needed, harder access"
	},
	{
		"type": "inflammation",
		"description": "Severe inflammation of appendix",
		"severity": "high",
		"effect": "Tissue is fragile, easy to tear"
	},
	{
		"type": "perforation",
		"description": "Appendix has ruptured",
		"severity": "high",
		"effect": "Contamination, harder cleanup"
	},
	{
		"type": "bleeding_disorder",
		"description": "Patient has bleeding tendency",
		"severity": "high",
		"effect": "Increased bleeding risk"
	},
	{
		"type": "anatomical_variant",
		"description": "Unusual appendix position",
		"severity": "low",
		"effect": "Harder to locate"
	}
]

# Current patient data
var current_patient: Dictionary = {}
var active_complications: Array[Dictionary] = []

signal patient_generated(patient: Dictionary)
signal complication_detected(complication: Dictionary)
signal patient_vitals_changed_realtime(vitals: Dictionary)

func _ready() -> void:
	pass

func generate_random_patient() -> Dictionary:
	# Pick random template
	var template = patient_templates[randi() % patient_templates.size()].duplicate()
	
	# Add some randomness to age and BMI
	template["age"] = template["age"] + randi_range(-5, 5)
	template["bmi"] = template["bmi"] + randf_range(-2.0, 2.0)
	
	# Randomly add complications based on difficulty
	active_complications.clear()
	var complication_chance = 0.0
	match template["difficulty"]:
		"easy":
			complication_chance = 0.2
		"medium":
			complication_chance = 0.5
		"hard":
			complication_chance = 0.8
	
	# Maybe add 1-2 complications
	if randf() < complication_chance:
		var comp = possible_complications[randi() % possible_complications.size()].duplicate()
		active_complications.append(comp)
		complication_detected.emit(comp)
	
	if randf() < complication_chance * 0.5:
		var comp = possible_complications[randi() % possible_complications.size()].duplicate()
		if comp["type"] not in active_complications.map(func(c): return c["type"]):
			active_complications.append(comp)
			complication_detected.emit(comp)
	
	# Generate initial vitals based on patient
	template["vitals"] = _generate_initial_vitals(template)
	template["complications"] = active_complications
	
	current_patient = template
	patient_generated.emit(template)
	Events.log_event("patient_generated", {"name": template["name"], "difficulty": template["difficulty"]})
	
	return template

func _generate_initial_vitals(patient: Dictionary) -> Dictionary:
	var base_hr = 72
	var base_systolic = 120
	var base_diastolic = 80
	var base_spo2 = 98
	var base_rr = 16
	var base_temp = 36.8
	
	# Adjust based on age
	if patient["age"] > 60:
		base_hr += 5
		base_systolic += 10
	elif patient["age"] < 25:
		base_hr -= 3
	
	# Adjust based on conditions
	for condition in patient.get("conditions", []):
		match condition:
			"hypertension":
				base_systolic += 15
				base_diastolic += 10
			"diabetes":
				base_spo2 -= 1
			"heart_disease":
				base_hr += 8
			"obesity":
				base_rr += 2
				base_spo2 -= 2
	
	# Add some randomness
	return {
		"heart_rate": base_hr + randi_range(-3, 3),
		"systolic_bp": base_systolic + randi_range(-5, 5),
		"diastolic_bp": base_diastolic + randi_range(-3, 3),
		"spo2": clamp(base_spo2 + randi_range(-1, 1), 90, 100),
		"respiratory_rate": base_rr + randi_range(-1, 1),
		"temperature": base_temp + randf_range(-0.2, 0.2)
	}

func get_current_patient() -> Dictionary:
	return current_patient

func get_complications() -> Array[Dictionary]:
	return active_complications

func has_complication(complication_type: String) -> bool:
	for comp in active_complications:
		if comp["type"] == complication_type:
			return true
	return false

func get_difficulty() -> String:
	return current_patient.get("difficulty", "easy")

func get_patient_info() -> String:
	if current_patient.is_empty():
		return "No patient loaded"
	
	var info = "%s, %d, %s" % [
		current_patient.get("name", "Unknown"),
		current_patient.get("age", 0),
		current_patient.get("gender", "Unknown")
	]
	
	if not current_patient.get("conditions", []).is_empty():
		info += "\nConditions: " + ", ".join(current_patient["conditions"])
	
	if not active_complications.is_empty():
		info += "\nComplications: " + ", ".join(active_complications.map(func(c): return c["description"]))
	
	return info

func reset() -> void:
	current_patient.clear()
	active_complications.clear()
