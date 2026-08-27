extends Node

## Event Bus - Global signal system for decoupled communication

# Simulation events
signal simulation_started()
signal simulation_ended()
signal simulation_paused()
signal simulation_resumed()

# Patient events
signal patient_vitals_changed(vitals: Dictionary)
signal patient_condition_changed(condition: String)

# Instrument events
signal instrument_selected(instrument_name: String)
signal instrument_dropped()
signal instrument_used(tool_name: String, target: String)

# Anatomy events
signal anatomy_selected(anatomy_name: String)
signal anatomy_deselected()
signal anatomy_damaged(anatomy_name: String, damage_type: String)

# Cutting events
signal cut_performed(instrument: String, target: String, result: String)
signal cut_registered(cut_event: Dictionary)

# Surgical state events
signal surgical_state_changed(old_state: String, new_state: String)

# Bleeding events
signal bleeding_started(source: String, severity: int)
signal bleeding_stopped()
signal bleeding_updated(severity: int, blood_loss: float)
signal blood_loss_critical(blood_loss: float)

# Camera events
signal camera_reset()
signal camera_zoom_changed(zoom_level: float)

# UI events
signal ui_update_requested()
signal debug_info_requested()

# Event logging
var event_log: Array[Dictionary] = []
var event_count: int = 0

func log_event(event_type: String, data: Dictionary = {}) -> void:
	var event = {
		"id": event_count,
		"type": event_type,
		"data": data,
		"timestamp": Time.get_datetime_string_from_system(),
		"elapsed_time": 0.0
	}
	if SimulationManager:
		event["elapsed_time"] = SimulationManager.get_simulation_time()
	event_log.append(event)
	event_count += 1
	ui_update_requested.emit()
	# Keep only last 500 events to prevent memory leak
	if event_log.size() > 500:
		event_log = event_log.slice(-500)

func log_surgical_event(action: String, instrument: String, target: String, result: String) -> Dictionary:
	var event = {
		"id": event_count,
		"type": "surgical_action",
		"action": action,
		"instrument": instrument,
		"target": target,
		"result": result,
		"timestamp": Time.get_datetime_string_from_system(),
		"elapsed_time": 0.0
	}
	if SimulationManager:
		event["elapsed_time"] = SimulationManager.get_simulation_time()
	event_log.append(event)
	event_count += 1
	cut_registered.emit(event)
	ui_update_requested.emit()
	# Keep only last 500 events to prevent memory leak
	if event_log.size() > 500:
		event_log = event_log.slice(-500)
	return event

func get_events() -> Array[Dictionary]:
	return event_log

func get_surgical_events() -> Array[Dictionary]:
	var surgical_events: Array[Dictionary] = []
	for event in event_log:
		if event.get("type") == "surgical_action":
			surgical_events.append(event)
	return surgical_events

func clear_events() -> void:
	event_log.clear()
	event_count = 0
