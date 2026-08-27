extends Node

## Simulation Manager - Controls simulation state and lifecycle

enum SimulationState {
	NOT_STARTED,
	RUNNING,
	PAUSED,
	ENDED
}

enum SurgicalState {
	READY,
	INCISION_STARTED,
	TARGET_INTERACTION,
	COMPLETED
}

var current_state: SimulationState = SimulationState.NOT_STARTED
var surgical_state: SurgicalState = SurgicalState.READY
var simulation_time: float = 0.0
var start_time: String = ""
var end_time: String = ""

# Patient vital signs (placeholder values)
var patient_vitals: Dictionary = {
	"heart_rate": 72,
	"systolic_bp": 120,
	"diastolic_bp": 80,
	"spo2": 98,
	"respiratory_rate": 16,
	"temperature": 36.8
}

# Selected instrument
var selected_instrument: String = "None"

# Selected anatomy
var selected_anatomy: String = "None"

# Interaction tracking
var interaction_count: int = 0
var valid_interaction_count: int = 0
var invalid_interaction_count: int = 0

# Scoring
var score: int = 0
var max_score: int = 100
var step_scores: Dictionary = {}

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if current_state == SimulationState.RUNNING:
		simulation_time += delta
		_update_vitals(delta)

func start_simulation() -> void:
	current_state = SimulationState.RUNNING
	surgical_state = SurgicalState.READY
	start_time = Time.get_datetime_string_from_system()
	simulation_time = 0.0
	interaction_count = 0
	valid_interaction_count = 0
	invalid_interaction_count = 0
	score = 0
	step_scores.clear()
	Events.simulation_started.emit()
	Events.log_event("simulation_started")
	Events.surgical_state_changed.emit("", get_surgical_state_name())

func pause_simulation() -> void:
	if current_state == SimulationState.RUNNING:
		current_state = SimulationState.PAUSED
		Events.simulation_paused.emit()
		Events.log_event("simulation_paused")

func resume_simulation() -> void:
	if current_state == SimulationState.PAUSED:
		current_state = SimulationState.RUNNING
		Events.simulation_resumed.emit()
		Events.log_event("simulation_resumed")

func end_simulation() -> void:
	current_state = SimulationState.ENDED
	end_time = Time.get_datetime_string_from_system()
	Events.simulation_ended.emit()
	Events.log_event("simulation_ended", {
		"duration": simulation_time,
		"vitals": patient_vitals.duplicate(),
		"interactions": interaction_count,
		"valid_interactions": valid_interaction_count,
		"invalid_interactions": invalid_interaction_count,
		"score": score
	})

func select_instrument(instrument_name: String) -> void:
	selected_instrument = instrument_name
	Events.instrument_selected.emit(instrument_name)
	Events.log_event("instrument_selected", {"instrument": instrument_name})

func select_anatomy(anatomy_name: String) -> void:
	selected_anatomy = anatomy_name
	Events.anatomy_selected.emit(anatomy_name)
	Events.log_event("anatomy_selected", {"anatomy": anatomy_name})

func use_instrument_on_target(tool_name: String, target_name: String) -> void:
	Events.instrument_used.emit(tool_name, target_name)
	Events.log_event("instrument_used", {
		"tool": tool_name,
		"target": target_name
	})

func register_interaction(instrument: String, target: String, is_valid: bool) -> Dictionary:
	interaction_count += 1
	var result = "SUCCESS" if is_valid else "INVALID"
	
	if is_valid:
		valid_interaction_count += 1
		_advance_surgical_state()
		_calculate_score(instrument, target)
	else:
		invalid_interaction_count += 1
		_deduct_score()
	
	var interaction_event = Events.log_surgical_event("INTERACTION", instrument, target, result)
	Events.cut_performed.emit(instrument, target, result)
	
	return interaction_event

func _advance_surgical_state() -> void:
	var old_state = get_surgical_state_name()
	match surgical_state:
		SurgicalState.READY:
			surgical_state = SurgicalState.INCISION_STARTED
		SurgicalState.INCISION_STARTED:
			surgical_state = SurgicalState.TARGET_INTERACTION
		SurgicalState.TARGET_INTERACTION:
			surgical_state = SurgicalState.COMPLETED
	var new_state = get_surgical_state_name()
	Events.surgical_state_changed.emit(old_state, new_state)
	Events.log_event("surgical_state_changed", {"from": old_state, "to": new_state})

func _calculate_score(instrument: String, target: String) -> void:
	var step_key = instrument + "_" + target
	if not step_scores.has(step_key):
		step_scores[step_key] = 10
		score = min(score + 10, max_score)

func _deduct_score() -> void:
	score = max(score - 5, 0)

func get_surgical_state_name() -> String:
	match surgical_state:
		SurgicalState.READY:
			return "READY"
		SurgicalState.INCISION_STARTED:
			return "INCISION_STARTED"
		SurgicalState.TARGET_INTERACTION:
			return "TARGET_INTERACTION"
		SurgicalState.COMPLETED:
			return "COMPLETED"
	return "UNKNOWN"

func is_simulation_running() -> bool:
	return current_state == SimulationState.RUNNING

func _update_vitals(delta: float) -> void:
	var hr_variation = sin(simulation_time * 0.5) * 2.0
	patient_vitals["heart_rate"] = 72 + int(hr_variation)
	
	var bp_variation = sin(simulation_time * 0.3) * 3.0
	patient_vitals["systolic_bp"] = 120 + int(bp_variation)
	patient_vitals["diastolic_bp"] = 80 + int(bp_variation * 0.5)
	
	var spo2_variation = sin(simulation_time * 0.2) * 1.0
	patient_vitals["spo2"] = clamp(98 + int(spo2_variation), 90, 100)
	
	Events.patient_vitals_changed.emit(patient_vitals)

func get_simulation_time() -> float:
	return simulation_time

func get_formatted_time() -> String:
	var minutes = int(simulation_time) / 60
	var seconds = int(simulation_time) % 60
	return "%02d:%02d" % [minutes, seconds]

func get_results() -> Dictionary:
	var bleeding_status = {}
	var bleeding_sim = get_node_or_null("/root/MainScene/BleedingSimulation")
	if bleeding_sim:
		bleeding_status = bleeding_sim.get_status()
	
	return {
		"duration": simulation_time,
		"start_time": start_time,
		"end_time": end_time,
		"final_vitals": patient_vitals.duplicate(),
		"event_count": Events.event_count,
		"events": Events.get_events(),
		"surgical_events": Events.get_surgical_events(),
		"interaction_count": interaction_count,
		"valid_interaction_count": valid_interaction_count,
		"invalid_interaction_count": invalid_interaction_count,
		"final_surgical_state": get_surgical_state_name(),
		"score": score,
		"max_score": max_score,
		"step_scores": step_scores.duplicate(),
		"bleeding_status": bleeding_status
	}
