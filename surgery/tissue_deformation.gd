extends Node

## TissueDeformation - Basic tissue physics

var deformed_tissues: Dictionary = {}
var deformation_decay_rate: float = 0.1

signal tissue_deformed(tissue_name: String, amount: float)
signal tissue_recovered(tissue_name: String)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Decay deformations over time
	var tissues_to_remove = []
	for tissue_name in deformed_tissues:
		var tissue = deformed_tissues[tissue_name]
		tissue["current"] = lerp(tissue["current"], 0.0, deformation_decay_rate * delta)
		
		if abs(tissue["current"]) < 0.01:
			tissues_to_remove.append(tissue_name)
			tissue_recovered.emit(tissue_name)
	
	for tissue_name in tissues_to_remove:
		deformed_tissues.erase(tissue_name)

func apply_deformation(tissue_name: String, amount: float, position: Vector3 = Vector3.ZERO) -> void:
	if not deformed_tissues.has(tissue_name):
		deformed_tissues[tissue_name] = {
			"current": 0.0,
			"max": 0.0,
			"position": position,
			"history": []
		}
	
	var tissue = deformed_tissues[tissue_name]
	tissue["current"] = clamp(tissue["current"] + amount, -1.0, 1.0)
	tissue["max"] = max(tissue["max"], abs(tissue["current"]))
	tissue["history"].append({
		"amount": amount,
		"position": position,
		"time": Time.get_ticks_msec()
	})
	
	# Keep only last 10 history entries
	if tissue["history"].size() > 10:
		tissue["history"].pop_front()
	
	tissue_deformed.emit(tissue_name, tissue["current"])

func apply_cut_deformation(tissue_name: String, cut_depth: float, position: Vector3) -> void:
	apply_deformation(tissue_name, cut_depth * 0.5, position)
	apply_deformation(tissue_name + "_bleed", cut_depth * 0.3, position)

func apply_grasp_deformation(tissue_name: String, grasp_strength: float, position: Vector3) -> void:
	apply_deformation(tissue_name, grasp_strength * 0.2, position)

func apply_retract_deformation(tissue_name: String, retract_force: float, position: Vector3) -> void:
	apply_deformation(tissue_name, -retract_force * 0.3, position)

func get_deformation(tissue_name: String) -> float:
	if deformed_tissues.has(tissue_name):
		return deformed_tissues[tissue_name]["current"]
	return 0.0

func get_max_deformation(tissue_name: String) -> float:
	if deformed_tissues.has(tissue_name):
		return deformed_tissues[tissue_name]["max"]
	return 0.0

func get_all_deformations() -> Dictionary:
	var result = {}
	for tissue_name in deformed_tissues:
		result[tissue_name] = deformed_tissues[tissue_name]["current"]
	return result

func reset_tissue(tissue_name: String) -> void:
	deformed_tissues.erase(tissue_name)
	tissue_recovered.emit(tissue_name)

func reset_all() -> void:
	deformed_tissues.clear()
