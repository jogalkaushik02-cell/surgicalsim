extends CanvasLayer

## SimulationControls - Start/End simulation buttons

@onready var start_button: Button = null
@onready var end_button: Button = null
@onready var pause_button: Button = null
@onready var resume_button: Button = null

func _ready() -> void:
	_create_ui()
	_update_button_states()

func _create_ui() -> void:
	var container = VBoxContainer.new()
	container.name = "ButtonContainer"
	container.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	container.offset_left = -150
	container.offset_top = -200
	container.offset_right = -10
	container.offset_bottom = -10
	add_child(container)
	
	start_button = Button.new()
	start_button.name = "StartButton"
	start_button.text = "Start Simulation"
	start_button.custom_minimum_size = Vector2(140, 50)
	start_button.pressed.connect(_on_start_pressed)
	container.add_child(start_button)
	
	pause_button = Button.new()
	pause_button.name = "PauseButton"
	pause_button.text = "Pause"
	pause_button.custom_minimum_size = Vector2(140, 50)
	pause_button.pressed.connect(_on_pause_pressed)
	container.add_child(pause_button)
	
	resume_button = Button.new()
	resume_button.name = "ResumeButton"
	resume_button.text = "Resume"
	resume_button.custom_minimum_size = Vector2(140, 50)
	resume_button.pressed.connect(_on_resume_pressed)
	container.add_child(resume_button)
	
	end_button = Button.new()
	end_button.name = "EndButton"
	end_button.text = "End Simulation"
	end_button.custom_minimum_size = Vector2(140, 50)
	end_button.pressed.connect(_on_end_pressed)
	container.add_child(end_button)

func _on_start_pressed() -> void:
	SimulationManager.start_simulation()
	_update_button_states()

func _on_pause_pressed() -> void:
	SimulationManager.pause_simulation()
	_update_button_states()

func _on_resume_pressed() -> void:
	SimulationManager.resume_simulation()
	_update_button_states()

func _on_end_pressed() -> void:
	SimulationManager.end_simulation()
	_update_button_states()
	_show_results()

func _update_button_states() -> void:
	var state = SimulationManager.current_state
	
	start_button.disabled = (state != SimulationManager.SimulationState.NOT_STARTED and 
							state != SimulationManager.SimulationState.ENDED)
	pause_button.disabled = (state != SimulationManager.SimulationState.RUNNING)
	resume_button.disabled = (state != SimulationManager.SimulationState.PAUSED)
	end_button.disabled = (state != SimulationManager.SimulationState.RUNNING and 
						  state != SimulationManager.SimulationState.PAUSED)

func _show_results() -> void:
	Events.log_event("showing_results")
