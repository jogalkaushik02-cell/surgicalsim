extends Control

## TutorialUI - Interactive tutorial interface

var tutorial_step_label: Label
var instruction_label: Label
var progress_bar: ProgressBar
var next_button: Button
var skip_button: Button
var step_container: VBoxContainer
var is_active: bool = false

signal tutorial_completed()
signal tutorial_skipped()

func _ready() -> void:
	hide()
	_setup_ui()
	Tutorial.tutorial_started.connect(_on_tutorial_started)
	Tutorial.tutorial_step_changed.connect(_on_tutorial_step_changed)
	Tutorial.tutorial_completed.connect(_on_tutorial_completed)

func _setup_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_CENTER)
	main_container.custom_minimum_size = Vector2(600, 500)
	main_container.position = Vector2(-300, -250)
	main_container.add_theme_constant_override("separation", 20)
	add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "TUTORIAL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.2, 0.8, 0.4))
	main_container.add_child(title)
	
	# Step container
	step_container = VBoxContainer.new()
	step_container.add_theme_constant_override("separation", 15)
	main_container.add_child(step_container)
	
	# Step label
	tutorial_step_label = Label.new()
	tutorial_step_label.text = "Step 1 / 10"
	tutorial_step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_step_label.add_theme_font_size_override("font_size", 20)
	tutorial_step_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	step_container.add_child(tutorial_step_label)
	
	# Instruction label
	instruction_label = Label.new()
	instruction_label.text = "Welcome to the tutorial!"
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction_label.custom_minimum_size = Vector2(500, 0)
	instruction_label.add_theme_font_size_override("font_size", 18)
	step_container.add_child(instruction_label)
	
	# Progress bar
	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(500, 30)
	progress_bar.max_value = 10
	progress_bar.value = 1
	progress_bar.show_percentage = false
	main_container.add_child(progress_bar)
	
	# Button container
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)
	main_container.add_child(button_container)
	
	# Skip button
	skip_button = Button.new()
	skip_button.text = "Skip Tutorial"
	skip_button.custom_minimum_size = Vector2(150, 50)
	skip_button.pressed.connect(_on_skip_pressed)
	button_container.add_child(skip_button)
	
	# Next button
	next_button = Button.new()
	next_button.text = "Next"
	next_button.custom_minimum_size = Vector2(150, 50)
	next_button.pressed.connect(_on_next_pressed)
	button_container.add_child(next_button)
	
	# Initially hidden
	visible = false

func start_tutorial() -> void:
	visible = true
	is_active = true
	Tutorial.start_tutorial()

func _on_tutorial_started() -> void:
	update_ui()

func _on_tutorial_step_changed(step: int, instruction: String) -> void:
	update_ui()

func _on_tutorial_completed() -> void:
	visible = false
	is_active = false
	tutorial_completed.emit()

func update_ui() -> void:
	var current = Tutorial.current_step
	var total = Tutorial.get_step_count()
	var step = Tutorial.get_current_step()
	
	tutorial_step_label.text = "Step %d / %d" % [current + 1, total]
	instruction_label.text = step.get("instruction", "")
	progress_bar.value = current + 1

func _on_skip_pressed() -> void:
	Tutorial.skip_tutorial()
	visible = false
	is_active = false
	tutorial_skipped.emit()

func _on_next_pressed() -> void:
	Tutorial.next_step()

func _input(event: InputEvent) -> void:
	if is_active and event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			Tutorial.next_step()
		elif event.pressed and event.keycode == KEY_ESCAPE:
			_on_skip_pressed()
