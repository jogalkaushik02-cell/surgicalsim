extends Control

## AchievementUI - Display achievements and progress

var achievement_list: VBoxContainer
var scroll_container: ScrollContainer
var title_label: Label
var stats_label: Label

var unlocked_color = Color(0.2, 0.8, 0.4)
var locked_color = Color(0.4, 0.4, 0.4)
var bg_color = Color(0.12, 0.12, 0.15)

signal closed()

func _ready() -> void:
	_setup_ui()
	AchievementSystem.achievement_unlocked.connect(_on_achievement_unlocked)

func _setup_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Main panel
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(700, 550)
	panel.position = Vector2(-350, -275)
	add_child(panel)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = bg_color
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(0.3, 0.3, 0.3)
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var main_container = VBoxContainer.new()
	main_container.add_theme_constant_override("separation", 15)
	panel.add_child(main_container)
	
	# Header
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 20)
	main_container.add_child(header)
	
	title_label = Label.new()
	title_label.text = "ACHIEVEMENTS"
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	header.add_child(title_label)
	
	var close_button = Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(40, 40)
	close_button.pressed.connect(_on_close_pressed)
	header.add_child(close_button)
	
	# Stats
	stats_label = Label.new()
	stats_label.text = "0 / 15 Unlocked (0%)"
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	main_container.add_child(stats_label)
	
	# Scroll container
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(scroll_container)
	
	# Achievement list
	achievement_list = VBoxContainer.new()
	achievement_list.add_theme_constant_override("separation", 10)
	scroll_container.add_child(achievement_list)
	
	_update_achievements()
	visible = false

func show_achievements() -> void:
	visible = true
	_update_achievements()

func _update_achievements() -> void:
	# Clear list
	for child in achievement_list.get_children():
		child.queue_free()
	
	# Update stats
	var unlocked = AchievementSystem.get_unlocked_count()
	var total = AchievementSystem.get_total_achievements()
	var percentage = AchievementSystem.get_completion_percentage()
	stats_label.text = "%d / %d Unlocked (%d%%)" % [unlocked, total, percentage]
	
	# Add unlocked achievements first
	var achievements = AchievementSystem.get_all_achievements()
	achievements.sort_custom(func(a, b): return a["unlocked"] and not b["unlocked"])
	
	for achievement in achievements:
		var row = _create_achievement_row(achievement)
		achievement_list.add_child(row)

func _create_achievement_row(achievement: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(650, 80)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.18, 0.22) if not achievement["unlocked"] else Color(0.15, 0.25, 0.15)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 3
	style.border_color = unlocked_color if achievement["unlocked"] else locked_color
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	panel.add_child(hbox)
	
	# Icon placeholder
	var icon_rect = ColorRect.new()
	icon_rect.custom_minimum_size = Vector2(50, 50)
	icon_rect.color = unlocked_color if achievement["unlocked"] else locked_color
	hbox.add_child(icon_rect)
	
	# Info
	var info = VBoxContainer.new()
	info.add_theme_constant_override("separation", 5)
	hbox.add_child(info)
	
	var name_label = Label.new()
	name_label.text = achievement["name"]
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1) if achievement["unlocked"] else Color(0.5, 0.5, 0.5))
	info.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = achievement["description"]
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info.add_child(desc_label)
	
	# Progress
	var progress = ProgressBar.new()
	progress.custom_minimum_size = Vector2(100, 15)
	progress.max_value = achievement["max_progress"]
	progress.value = achievement["progress"]
	progress.show_percentage = false
	hbox.add_child(progress)
	
	# Reward
	var reward_label = Label.new()
	reward_label.text = achievement["reward"]
	reward_label.add_theme_font_size_override("font_size", 12)
	reward_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2) if achievement["unlocked"] else Color(0.5, 0.5, 0.5))
	hbox.add_child(reward_label)
	
	return panel

func _on_close_pressed() -> void:
	visible = false
	closed.emit()

func _on_achievement_unlocked(achievement: Dictionary) -> void:
	# Show notification
	_show_notification(achievement["name"])

func _show_notification(achievement_name: String) -> void:
	var notification = Label.new()
	notification.text = "Achievement Unlocked: %s" % achievement_name
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.set_anchors_preset(Control.PRESET_TOP_WIDE)
	notification.position = Vector2(0, 50)
	notification.add_theme_font_size_override("font_size", 20)
	notification.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	add_child(notification)
	
	# Auto-remove after 3 seconds
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(notification.queue_free)
