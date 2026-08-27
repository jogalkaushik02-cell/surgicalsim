extends Node

## BleedingSimulation - Basic bleeding simulation

var is_bleeding: bool = false
var bleeding_severity: int = 0  # 0-10 scale
var bleeding_source: String = ""
var blood_loss: float = 0.0
var max_blood_loss: float = 500.0  # ml

# Bleeding rates per severity level (ml per second)
var bleeding_rates: Dictionary = {
	0: 0.0,
	1: 0.5,
	2: 1.0,
	3: 2.0,
	4: 3.0,
	5: 5.0,
	6: 8.0,
	7: 12.0,
	8: 18.0,
	9: 25.0,
	10: 35.0
}

signal bleeding_started(source: String, severity: int)
signal bleeding_stopped()
signal bleeding_updated(severity: int, blood_loss: float)
signal blood_loss_critical(blood_loss: float)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_bleeding and SimulationManager.is_simulation_running():
		var rate = bleeding_rates.get(bleeding_severity, 0.0)
		blood_loss += rate * delta
		bleeding_updated.emit(bleeding_severity, blood_loss)
		
		if blood_loss >= max_blood_loss * 0.8:
			blood_loss_critical.emit(blood_loss)

func start_bleeding(source: String, severity: int) -> void:
	is_bleeding = true
	bleeding_source = source
	bleeding_severity = clamp(severity, 0, 10)
	blood_loss = 0.0
	bleeding_started.emit(source, bleeding_severity)
	Events.log_event("bleeding_started", {"source": source, "severity": severity})

func stop_bleeding() -> void:
	is_bleeding = false
	bleeding_severity = 0
	bleeding_source = ""
	bleeding_stopped.emit()
	Events.log_event("bleeding_stopped", {"blood_loss": blood_loss})

func apply_pressure() -> void:
	if is_bleeding:
		bleeding_severity = max(bleeding_severity - 2, 0)
		if bleeding_severity == 0:
			stop_bleeding()
		Events.log_event("pressure_applied", {"new_severity": bleeding_severity})
		print("Pressure applied. New severity: ", bleeding_severity)

func apply_clamp() -> void:
	if is_bleeding:
		bleeding_severity = max(bleeding_severity - 4, 0)
		if bleeding_severity == 0:
			stop_bleeding()
		Events.log_event("clamp_applied", {"new_severity": bleeding_severity})
		print("Clamp applied. New severity: ", bleeding_severity)

func cauterize() -> void:
	if is_bleeding:
		bleeding_severity = 0
		stop_bleeding()
		Events.log_event("cauterized")
		print("Cauterized. Bleeding stopped.")

func get_blood_loss() -> float:
	return blood_loss

func get_severity() -> int:
	return bleeding_severity

func is_critical() -> bool:
	return blood_loss >= max_blood_loss * 0.8

func get_status() -> Dictionary:
	return {
		"is_bleeding": is_bleeding,
		"severity": bleeding_severity,
		"source": bleeding_source,
		"blood_loss": blood_loss,
		"max_blood_loss": max_blood_loss,
		"is_critical": is_critical()
	}

func reset() -> void:
	is_bleeding = false
	bleeding_severity = 0
	bleeding_source = ""
	blood_loss = 0.0
