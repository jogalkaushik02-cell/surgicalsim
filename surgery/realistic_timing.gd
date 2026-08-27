extends Node

## RealisticTiming - Controls timing of surgical procedures

# Realistic time scales (in seconds)
var time_scales: Dictionary = {
	"incision": 45.0,
	"retraction": 30.0,
	"locate_appendix": 60.0,
	"grasp_appendix": 20.0,
	"divide_mesentery": 90.0,
	"remove_appendix": 60.0,
	"ligate_stump": 45.0,
	"check_hemostasis": 30.0,
	"close_incision": 120.0
}

# Current timing state
var procedure_start_time: float = 0.0
var step_start_time: float = 0.0
var current_step: String = ""
var time_multiplier: float = 1.0  # For testing (1.0 = real time)

# Timing history
var step_timings: Array[Dictionary] = []

signal step_timing_recorded(step: String, duration: float, target: float)
signal procedure_timing_updated(elapsed: float, estimated_remaining: float)

func _ready() -> void:
	pass

func start_procedure() -> void:
	procedure_start_time = Time.get_ticks_msec() / 1000.0
	step_timings.clear()

func start_step(step_name: String) -> void:
	current_step = step_name
	step_start_time = Time.get_ticks_msec() / 1000.0

func end_step(step_name: String) -> Dictionary:
	var duration = (Time.get_ticks_msec() / 1000.0) - step_start_time
	var target = time_scales.get(step_name, 60.0)
	
	var timing = {
		"step": step_name,
		"duration": duration,
		"target": target,
		"ratio": duration / target,
		"rating": _rate_timing(duration, target)
	}
	
	step_timings.append(timing)
	step_timing_recorded.emit(step_name, duration, target)
	Events.log_event("step_timing", timing)
	
	return timing

func get_elapsed_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - procedure_start_time

func get_estimated_remaining() -> float:
	var total_target = 0.0
	var completed_target = 0.0
	
	for step in time_scales:
		total_target += time_scales[step]
		for timing in step_timings:
			if timing["step"] == step:
				completed_target += timing["target"]
				break
	
	return (total_target - completed_target) * time_multiplier

func get_step_duration(step_name: String) -> float:
	for timing in step_timings:
		if timing["step"] == step_name:
			return timing["duration"]
	return 0.0

func get_step_target(step_name: String) -> float:
	return time_scales.get(step_name, 60.0)

func _rate_timing(duration: float, target: float) -> String:
	var ratio = duration / target
	if ratio < 0.7:
		return "fast"
	elif ratio < 1.3:
		return "good"
	elif ratio < 1.8:
		return "slow"
	else:
		return "very_slow"

func set_time_multiplier(multiplier: float) -> void:
	time_multiplier = clamp(multiplier, 0.1, 10.0)

func get_timing_summary() -> Dictionary:
	var total_time = get_elapsed_time()
	var total_target = 0.0
	for step in time_scales:
		total_target += time_scales[step]
	
	return {
		"total_time": total_time,
		"total_target": total_target,
		"ratio": total_time / total_target if total_target > 0 else 0.0,
		"steps_completed": step_timings.size(),
		"steps_total": time_scales.size(),
		"step_details": step_timings.duplicate()
	}
