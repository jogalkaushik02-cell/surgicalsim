extends Node

## Appendicectomy - Complete appendicectomy state machine

enum AppendicectomyState {
	NOT_STARTED,
	INCISION,
	RETRACT_ABDOMEN,
	LOCATE_APPENDIX,
	GRASP_APPENDIX,
	DIVIDE_MESENTERY,
	REMOVE_APPENDIX,
	LIGATE_STUMP,
	CHECK_HEMOSTASIS,
	CLOSE_INCISION,
	COMPLETED
}

var current_step: AppendicectomyState = AppendicectomyState.NOT_STARTED
var step_history: Array[Dictionary] = []
var step_start_time: float = 0.0

# Valid instrument-target combinations for each step
var step_validations: Dictionary = {
	AppendicectomyState.INCISION: {
		"instrument": "Scalpel",
		"target": "Abdomen",
		"description": "Make incision in abdomen"
	},
	AppendicectomyState.RETRACT_ABDOMEN: {
		"instrument": "Retractor",
		"target": "Abdomen",
		"description": "Retract abdomen to expose contents"
	},
	AppendicectomyState.LOCATE_APPENDIX: {
		"instrument": "Retractor",
		"target": "Cecum",
		"description": "Locate and expose the appendix"
	},
	AppendicectomyState.GRASP_APPENDIX: {
		"instrument": "Forceps",
		"target": "Appendix",
		"description": "Grasp the appendix with forceps"
	},
	AppendicectomyState.DIVIDE_MESENTERY: {
		"instrument": "Scalpel",
		"target": "Mesentery",
		"description": "Divide the mesentery"
	},
	AppendicectomyState.REMOVE_APPENDIX: {
		"instrument": "Scalpel",
		"target": "Appendix",
		"description": "Remove the appendix"
	},
	AppendicectomyState.LIGATE_STUMP: {
		"instrument": "Suture",
		"target": "Appendix",
		"description": "Ligate the appendiceal stump"
	},
	AppendicectomyState.CHECK_HEMOSTASIS: {
		"instrument": "Forceps",
		"target": "Cecum",
		"description": "Check for bleeding"
	},
	AppendicectomyState.CLOSE_INCISION: {
		"instrument": "Suture",
		"target": "Abdomen",
		"description": "Close the incision"
	}
}

signal step_completed(step: int, step_name: String)
signal step_failed(step: int, step_name: String, reason: String)
signal appendicectomy_completed()
signal appendicectomy_step_changed(old_step: int, new_step: int)

func _ready() -> void:
	pass

func start_appendicectomy() -> void:
	current_step = AppendicectomyState.INCISION
	step_start_time = SimulationManager.get_simulation_time()
	appendicectomy_step_changed.emit(AppendicectomyState.NOT_STARTED, current_step)
	Events.log_event("appendicectomy_started")

func validate_interaction(instrument: String, target: String) -> Dictionary:
	if current_step == AppendicectomyState.NOT_STARTED:
		return {"valid": false, "reason": "Appendicectomy not started"}
	
	if current_step == AppendicectomyState.COMPLETED:
		return {"valid": false, "reason": "Appendicectomy already completed"}
	
	var step_data = step_validations.get(current_step)
	if not step_data:
		return {"valid": false, "reason": "Invalid step"}
	
	var is_correct_instrument = (instrument == step_data["instrument"])
	var is_correct_target = (target == step_data["target"])
	
	if is_correct_instrument and is_correct_target:
		var time_taken = SimulationManager.get_simulation_time() - step_start_time
		var step_record = {
			"step": current_step,
			"name": step_data["description"],
			"instrument": instrument,
			"target": target,
			"time_taken": time_taken,
			"result": "SUCCESS"
		}
		step_history.append(step_record)
		
		var old_step = current_step
		_advance_step()
		step_completed.emit(old_step, step_data["description"])
		Events.log_event("appendicectomy_step_completed", step_record)
		print("Step completed: ", step_data["description"])
		
		return {"valid": true, "reason": "Step completed", "step_data": step_data}
	else:
		var reason = ""
		if not is_correct_instrument:
			reason = "Wrong instrument. Expected: %s, Got: %s" % [step_data["instrument"], instrument]
		else:
			reason = "Wrong target. Expected: %s, Got: %s" % [step_data["target"], target]
		
		var step_record = {
			"step": current_step,
			"name": step_data["description"],
			"instrument": instrument,
			"target": target,
			"result": "FAILED",
			"reason": reason
		}
		step_history.append(step_record)
		step_failed.emit(current_step, step_data["description"], reason)
		Events.log_event("appendicectomy_step_failed", step_record)
		print("Step failed: ", reason)
		
		return {"valid": false, "reason": reason}

func _advance_step() -> void:
	match current_step:
		AppendicectomyState.INCISION:
			current_step = AppendicectomyState.RETRACT_ABDOMEN
		AppendicectomyState.RETRACT_ABDOMEN:
			current_step = AppendicectomyState.LOCATE_APPENDIX
		AppendicectomyState.LOCATE_APPENDIX:
			current_step = AppendicectomyState.GRASP_APPENDIX
		AppendicectomyState.GRASP_APPENDIX:
			current_step = AppendicectomyState.DIVIDE_MESENTERY
		AppendicectomyState.DIVIDE_MESENTERY:
			current_step = AppendicectomyState.REMOVE_APPENDIX
		AppendicectomyState.REMOVE_APPENDIX:
			current_step = AppendicectomyState.LIGATE_STUMP
		AppendicectomyState.LIGATE_STUMP:
			current_step = AppendicectomyState.CHECK_HEMOSTASIS
		AppendicectomyState.CHECK_HEMOSTASIS:
			current_step = AppendicectomyState.CLOSE_INCISION
		AppendicectomyState.CLOSE_INCISION:
			current_step = AppendicectomyState.COMPLETED
			appendicectomy_completed.emit()
			Events.log_event("appendicectomy_completed", {
				"total_steps": step_history.size(),
				"successful_steps": step_history.filter(func(s): return s["result"] == "SUCCESS").size()
			})
			print("Appendicectomy completed!")
	
	step_start_time = SimulationManager.get_simulation_time()

func get_current_step_name() -> String:
	match current_step:
		AppendicectomyState.NOT_STARTED:
			return "NOT_STARTED"
		AppendicectomyState.INCISION:
			return "INCISION"
		AppendicectomyState.RETRACT_ABDOMEN:
			return "RETRACT_ABDOMEN"
		AppendicectomyState.LOCATE_APPENDIX:
			return "LOCATE_APPENDIX"
		AppendicectomyState.GRASP_APPENDIX:
			return "GRASP_APPENDIX"
		AppendicectomyState.DIVIDE_MESENTERY:
			return "DIVIDE_MESENTERY"
		AppendicectomyState.REMOVE_APPENDIX:
			return "REMOVE_APPENDIX"
		AppendicectomyState.LIGATE_STUMP:
			return "LIGATE_STUMP"
		AppendicectomyState.CHECK_HEMOSTASIS:
			return "CHECK_HEMOSTASIS"
		AppendicectomyState.CLOSE_INCISION:
			return "CLOSE_INCISION"
		AppendicectomyState.COMPLETED:
			return "COMPLETED"
	return "UNKNOWN"

func get_current_step_description() -> String:
	var step_data = step_validations.get(current_step)
	if step_data:
		return step_data["description"]
	return ""

func get_step_history() -> Array[Dictionary]:
	return step_history

func get_progress() -> Dictionary:
	var completed_steps = step_history.filter(func(s): return s["result"] == "SUCCESS").size()
	var total_steps = step_validations.size()
	return {
		"current_step": current_step,
		"current_step_name": get_current_step_name(),
		"completed_steps": completed_steps,
		"total_steps": total_steps,
		"progress_percent": int((float(completed_steps) / float(total_steps)) * 100)
	}

func reset() -> void:
	current_step = AppendicectomyState.NOT_STARTED
	step_history.clear()
	step_start_time = 0.0
