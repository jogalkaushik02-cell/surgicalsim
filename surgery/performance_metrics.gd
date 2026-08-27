extends Node

## PerformanceMetrics - Performance metrics and evaluation

var metrics: Dictionary = {}
var start_time: float = 0.0
var end_time: float = 0.0
var total_time: float = 0.0

# Metrics categories
var time_metrics: Dictionary = {}
var accuracy_metrics: Dictionary = {}
var efficiency_metrics: Dictionary = {}
var safety_metrics: Dictionary = {}

# Evaluation criteria
var evaluation_criteria: Dictionary = {
	"time": {
		"name": "Time",
		"description": "Complete surgery within time limit",
		"max_score": 100,
		"weight": 0.3
	},
	"accuracy": {
		"name": "Accuracy",
		"description": "Follow correct surgical steps",
		"max_score": 100,
		"weight": 0.4
	},
	"safety": {
		"name": "Patient Safety",
		"description": "Maintain stable vital signs",
		"max_score": 100,
		"weight": 0.3
	}
}

signal metrics_updated(metrics: Dictionary)
signal evaluation_completed(evaluation: Dictionary)

func _ready() -> void:
	pass

func start_tracking() -> void:
	start_time = SimulationManager.get_simulation_time()
	metrics.clear()
	time_metrics.clear()
	accuracy_metrics.clear()
	efficiency_metrics.clear()
	safety_metrics.clear()
	Events.log_event("metrics_tracking_started")

func stop_tracking() -> void:
	end_time = SimulationManager.get_simulation_time()
	total_time = end_time - start_time
	_calculate_all_metrics()
	Events.log_event("metrics_tracking_stopped", {"total_time": total_time})

func _calculate_all_metrics() -> void:
	_calculate_time_metrics()
	_calculate_accuracy_metrics()
	_calculate_efficiency_metrics()
	_calculate_safety_metrics()
	
	metrics = {
		"time": time_metrics,
		"accuracy": accuracy_metrics,
		"efficiency": efficiency_metrics,
		"safety": safety_metrics,
		"total_time": total_time
	}
	
	metrics_updated.emit(metrics)

func _calculate_time_metrics() -> void:
	time_metrics = {
		"total_time": total_time,
		"average_step_time": total_time / max(1, _get_completed_steps()),
		"fastest_step": _get_fastest_step(),
		"slowest_step": _get_slowest_step()
	}

func _calculate_accuracy_metrics() -> void:
	var interactions = SimulationManager.interaction_count
	var valid = SimulationManager.valid_interaction_count
	var invalid = SimulationManager.invalid_interaction_count
	
	accuracy_metrics = {
		"total_interactions": interactions,
		"valid_interactions": valid,
		"invalid_interactions": invalid,
		"accuracy_rate": float(valid) / max(1.0, float(interactions)) * 100.0,
		"steps_completed": _get_completed_steps(),
		"total_steps": 9  # Appendicectomy has 9 steps
	}

func _calculate_efficiency_metrics() -> void:
	efficiency_metrics = {
		"unnecessary_interactions": max(0, SimulationManager.interaction_count - _get_completed_steps()),
		"efficiency_score": _calculate_efficiency_score()
	}

func _calculate_safety_metrics() -> void:
	var bleeding_sim = get_node_or_null("/root/MainScene/BleedingSimulation")
	var blood_loss = 0.0
	if bleeding_sim:
		blood_loss = bleeding_sim.get_blood_loss()
	
	safety_metrics = {
		"blood_loss": blood_loss,
		"max_safe_blood_loss": 500.0,
		"safety_score": _calculate_safety_score(blood_loss),
		"vitals_stable": _check_vitals_stability()
	}

func _get_completed_steps() -> int:
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr and interaction_mgr.appendicectomy_sm:
		return interaction_mgr.appendicectomy_sm.get_progress().get("completed_steps", 0)
	return 0

func _get_fastest_step() -> float:
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr and interaction_mgr.appendicectomy_sm:
		var history = interaction_mgr.appendicectomy_sm.get_step_history()
		var min_time = INF
		for step in history:
			if step.get("result") == "SUCCESS":
				min_time = min(min_time, step.get("time_taken", INF))
		return min_time if min_time < INF else 0.0
	return 0.0

func _get_slowest_step() -> float:
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr and interaction_mgr.appendicectomy_sm:
		var history = interaction_mgr.appendicectomy_sm.get_step_history()
		var max_time = 0.0
		for step in history:
			if step.get("result") == "SUCCESS":
				max_time = max(max_time, step.get("time_taken", 0.0))
		return max_time
	return 0.0

func _calculate_efficiency_score() -> int:
	var completed = _get_completed_steps()
	var total = SimulationManager.interaction_count
	if total == 0:
		return 100
	var efficiency = float(completed) / float(total) * 100.0
	return clamp(int(efficiency), 0, 100)

func _calculate_safety_score(blood_loss: float) -> int:
	var max_safe = 500.0
	var score = 100 - int((blood_loss / max_safe) * 100.0)
	return clamp(score, 0, 100)

func _check_vitals_stability() -> bool:
	var vitals = SimulationManager.patient_vitals
	var hr = vitals.get("heart_rate", 72)
	var bp_sys = vitals.get("systolic_bp", 120)
	var spo2 = vitals.get("spo2", 98)
	
	return hr >= 60 and hr <= 100 and bp_sys >= 90 and bp_sys <= 140 and spo2 >= 95

func get_evaluation() -> Dictionary:
	var time_score = _evaluate_time()
	var accuracy_score = _evaluate_accuracy()
	var safety_score_eval = _evaluate_safety()
	
	var total_score = int(
		time_score * evaluation_criteria["time"]["weight"] +
		accuracy_score * evaluation_criteria["accuracy"]["weight"] +
		safety_score_eval * evaluation_criteria["safety"]["weight"]
	)
	
	var evaluation = {
		"time_score": time_score,
		"accuracy_score": accuracy_score,
		"safety_score": safety_score_eval,
		"total_score": total_score,
		"grade": _get_grade(total_score),
		"details": {
			"time": time_metrics,
			"accuracy": accuracy_metrics,
			"safety": safety_metrics
		}
	}
	
	evaluation_completed.emit(evaluation)
	return evaluation

func _evaluate_time() -> int:
	if total_time <= 300:  # 5 minutes
		return 100
	elif total_time <= 600:  # 10 minutes
		return 80
	elif total_time <= 900:  # 15 minutes
		return 60
	elif total_time <= 1200:  # 20 minutes
		return 40
	else:
		return 20

func _evaluate_accuracy() -> int:
	return accuracy_metrics.get("accuracy_rate", 0)

func _evaluate_safety() -> int:
	return safety_metrics.get("safety_score", 100)

func _get_grade(score: int) -> String:
	if score >= 90:
		return "A"
	elif score >= 80:
		return "B"
	elif score >= 70:
		return "C"
	elif score >= 60:
		return "D"
	else:
		return "F"

func get_metrics() -> Dictionary:
	return metrics

func reset() -> void:
	metrics.clear()
	start_time = 0.0
	end_time = 0.0
	total_time = 0.0
	time_metrics.clear()
	accuracy_metrics.clear()
	efficiency_metrics.clear()
	safety_metrics.clear()
