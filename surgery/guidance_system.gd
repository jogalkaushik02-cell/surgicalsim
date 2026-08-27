extends Node

## GuidanceSystem - Real-time guidance for surgical procedures

var is_guidance_active: bool = false
var current_guidance: String = ""
var guidance_history: Array[Dictionary] = []
var show_hints: bool = true

# Guidance messages for each step
var guidance_messages: Dictionary = {
	"INCISION": {
		"instruction": "Make an incision in the abdomen using the Scalpel",
		"hint": "Select the Scalpel, then tap on the Abdomen",
		"warning": "Ensure proper incision placement"
	},
	"RETRACT_ABDOMEN": {
		"instruction": "Retract the abdomen to expose contents",
		"hint": "Select the Retractor, then tap on the Abdomen",
		"warning": "Apply gentle, steady pressure"
	},
	"LOCATE_APPENDIX": {
		"instruction": "Locate and expose the appendix",
		"hint": "Select the Retractor, then tap on the Cecum",
		"warning": "Identify the appendix before proceeding"
	},
	"GRASP_APPENDIX": {
		"instruction": "Grasp the appendix with forceps",
		"hint": "Select the Forceps, then tap on the Appendix",
		"warning": "Grasp firmly but avoid tearing"
	},
	"DIVIDE_MESENTERY": {
		"instruction": "Divide the mesentery",
		"hint": "Select the Scalpel, then tap on the Mesentery",
		"warning": "Control bleeding carefully"
	},
	"REMOVE_APPENDIX": {
		"instruction": "Remove the appendix",
		"hint": "Select the Scalpel, then tap on the Appendix",
		"warning": "Ensure complete removal"
	},
	"LIGATE_STUMP": {
		"instruction": "Ligate the appendiceal stump",
		"hint": "Select the Suture, then tap on the Appendix",
		"warning": "Secure the stump properly"
	},
	"CHECK_HEMOSTASIS": {
		"instruction": "Check for bleeding",
		"hint": "Select the Forceps, then tap on the Cecum",
		"warning": "Ensure no active bleeding"
	},
	"CLOSE_INCISION": {
		"instruction": "Close the incision",
		"hint": "Select the Suture, then tap on the Abdomen",
		"warning": "Close in layers"
	}
}

signal guidance_updated(guidance: String)
signal guidance_warning(warning: String)
signal guidance_hint(hint: String)

func _ready() -> void:
	Events.surgical_state_changed.connect(_on_surgical_state_changed)

func _on_surgical_state_changed(_old_state: String, new_state: String) -> void:
	if is_guidance_active:
		update_guidance(new_state)

func start_guidance() -> void:
	is_guidance_active = true
	current_guidance = ""
	guidance_history.clear()
	Events.log_event("guidance_started")

func stop_guidance() -> void:
	is_guidance_active = false
	current_guidance = ""
	Events.log_event("guidance_stopped")

func update_guidance(step_name: String) -> void:
	if not is_guidance_active:
		return
	
	var guidance_data = guidance_messages.get(step_name)
	if guidance_data:
		current_guidance = guidance_data["instruction"]
		guidance_updated.emit(current_guidance)
		
		if show_hints:
			guidance_hint.emit(guidance_data["hint"])
		
		if guidance_data.has("warning"):
			guidance_warning.emit(guidance_data["warning"])
		
		guidance_history.append({
			"step": step_name,
			"instruction": guidance_data["instruction"],
			"timestamp": Time.get_datetime_string_from_system()
		})
		
		Events.log_event("guidance_updated", {"step": step_name, "instruction": guidance_data["instruction"]})

func get_current_guidance() -> String:
	return current_guidance

func get_guidance_for_step(step_name: String) -> Dictionary:
	return guidance_messages.get(step_name, {})

func get_guidance_history() -> Array[Dictionary]:
	return guidance_history

func set_show_hints(show: bool) -> void:
	show_hints = show

func get_status() -> Dictionary:
	return {
		"is_active": is_guidance_active,
		"current_guidance": current_guidance,
		"show_hints": show_hints,
		"history_count": guidance_history.size()
	}
