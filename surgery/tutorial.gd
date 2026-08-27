extends Node

## Tutorial - Step-by-step guide for new players

var current_step: int = 0
var tutorial_active: bool = false
var completed_steps: Array = []

signal tutorial_started()
signal tutorial_step_changed(step: int, instruction: String)
signal tutorial_completed()
signal tutorial_skipped()

# Tutorial steps for appendicectomy
var tutorial_steps: Array = [
	{
		"title": "Welcome to SURGICALSIM",
		"instruction": "This tutorial will teach you how to perform an appendicectomy. Follow the instructions carefully.",
		"action": "tap_to_continue"
	},
	{
		"title": "Select Your Instrument",
		"instruction": "Tap the Scalpel button on the right panel to select it. This is your primary cutting instrument.",
		"action": "select_scalpel"
	},
	{
		"title": "Identify the Target",
		"instruction": "Look for the red highlighted appendix in the center of the screen. This is your surgical target.",
		"action": "identify_appendix"
	},
	{
		"title": "Make the Incision",
		"instruction": "Swipe across the appendix to make your first incision. Use smooth, controlled movements.",
		"action": "cut_appendix"
	},
	{
		"title": "Check Patient Vitals",
		"instruction": "Monitor the patient's heart rate and blood pressure in the top-left corner. Keep them stable.",
		"action": "check_vitals"
	},
	{
		"title": "Control Bleeding",
		"instruction": "If bleeding occurs, use the Forceps to apply pressure. Tap the Forceps button to select it.",
		"action": "use_forceps"
	},
	{
		"title": "Retract Tissue",
		"instruction": "Select the Retractor to hold tissue open and improve visibility.",
		"action": "use_retractor"
	},
	{
		"title": "Complete the Procedure",
		"instruction": "Continue cutting until the appendix is fully detached. Follow the surgical steps shown at the bottom.",
		"action": "complete_surgery"
	},
	{
		"title": "Suture the Wound",
		"instruction": "Select the Suture to close the incision when the procedure is complete.",
		"action": "use_suture"
	},
	{
		"title": "Congratulations!",
		"instruction": "You've completed the tutorial! You're now ready to perform real surgeries. Good luck!",
		"action": "finish"
	}
]

func start_tutorial() -> void:
	current_step = 0
	completed_steps.clear()
	tutorial_active = true
	tutorial_started.emit()
	_show_current_step()

func skip_tutorial() -> void:
	tutorial_active = false
	tutorial_skipped.emit()

func next_step() -> void:
	if current_step < tutorial_steps.size() - 1:
		completed_steps.append(current_step)
		current_step += 1
		_show_current_step()
	else:
		complete_tutorial()

func complete_tutorial() -> void:
	tutorial_active = false
	completed_steps.append(current_step)
	tutorial_completed.emit()

func _show_current_step() -> void:
	if current_step < tutorial_steps.size():
		var step = tutorial_steps[current_step]
		tutorial_step_changed.emit(current_step, step["instruction"])

func get_current_step() -> Dictionary:
	if current_step < tutorial_steps.size():
		return tutorial_steps[current_step]
	return {}

func is_tutorial_active() -> bool:
	return tutorial_active

func get_progress() -> float:
	return float(current_step) / float(tutorial_steps.size())

func get_step_count() -> int:
	return tutorial_steps.size()

func get_completed_count() -> int:
	return completed_steps.size()
