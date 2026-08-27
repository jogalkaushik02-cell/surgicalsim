extends Control

## SurgeryCatalogUI - Browse available and upcoming surgeries

var surgery_list: VBoxContainer
var scroll_container: ScrollContainer
var category_list: HBoxContainer
var title_label: Label
var info_panel: PanelContainer
var info_label: RichTextLabel

var selected_category: String = "all"

signal surgery_selected(surgery_id: String)
signal closed()

func _ready() -> void:
	hide()
	_setup_ui()

func _setup_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Main panel
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(800, 600)
	panel.position = Vector2(-400, -300)
	add_child(panel)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.12, 0.15)
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
	title_label.text = "SURGERY CATALOG"
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.4))
	header.add_child(title_label)
	
	var close_button = Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(40, 40)
	close_button.pressed.connect(_on_close_pressed)
	header.add_child(close_button)
	
	# Category tabs
	category_list = HBoxContainer.new()
	category_list.add_theme_constant_override("separation", 10)
	main_container.add_child(category_list)
	
	_add_category_button("All", "all")
	_add_category_button("Available", "available")
	_add_category_button("Coming Soon", "upcoming")
	
	# Content area
	var content = HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 15)
	main_container.add_child(content)
	
	# Surgery list
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll_container)
	
	surgery_list = VBoxContainer.new()
	surgery_list.add_theme_constant_override("separation", 10)
	scroll_container.add_child(surgery_list)
	
	# Info panel
	info_panel = PanelContainer.new()
	info_panel.custom_minimum_size = Vector2(250, 0)
	content.add_child(info_panel)
	
	var info_style = StyleBoxFlat.new()
	info_style.bg_color = Color(0.15, 0.15, 0.18)
	info_style.corner_radius_top_left = 8
	info_style.corner_radius_top_right = 8
	info_style.corner_radius_bottom_left = 8
	info_style.corner_radius_bottom_right = 8
	info_panel.add_theme_stylebox_override("panel", info_style)
	
	info_label = RichTextLabel.new()
	info_label.bbcode_enabled = true
	info_label.fit_content = true
	info_panel.add_child(info_label)
	
	_update_surgery_list()
	visible = false

func _add_category_button(text: String, category: String) -> void:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(100, 35)
	button.pressed.connect(_on_category_selected.bind(category))
	category_list.add_child(button)

func _on_category_selected(category: String) -> void:
	selected_category = category
	_update_surgery_list()

func _update_surgery_list() -> void:
	# Clear list
	for child in surgery_list.get_children():
		child.queue_free()
	
	# Get surgeries
	var surgeries = []
	match selected_category:
		"all":
			surgeries = SurgeryCatalog.get_all_surgeries()
		"available":
			surgeries = SurgeryCatalog.get_available_surgeries()
		"upcoming":
			surgeries = SurgeryCatalog.get_upcoming_surgeries()
	
	# Add surgery cards
	for surgery in surgeries:
		var card = _create_surgery_card(surgery)
		surgery_list.add_child(card)
	
	# Show default info
	if surgeries.size() > 0:
		_show_surgery_info(surgeries[0])

func _create_surgery_card(surgery: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 100)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.18, 0.22) if surgery["status"] == "available" else Color(0.15, 0.15, 0.18)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 3
	style.border_color = Color(0.2, 0.8, 0.4) if surgery["status"] == "available" else Color(0.5, 0.5, 0.5)
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	panel.add_child(hbox)
	
	# Icon placeholder
	var icon_rect = ColorRect.new()
	icon_rect.custom_minimum_size = Vector2(60, 60)
	icon_rect.color = Color(0.2, 0.8, 0.4) if surgery["status"] == "available" else Color(0.5, 0.5, 0.5)
	hbox.add_child(icon_rect)
	
	# Info
	var info = VBoxContainer.new()
	info.add_theme_constant_override("separation", 5)
	hbox.add_child(info)
	
	var name_label = Label.new()
	name_label.text = surgery["name"]
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1) if surgery["status"] == "available" else Color(0.6, 0.6, 0.6))
	info.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = surgery["description"]
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info.add_child(desc_label)
	
	# Status
	var status_label = Label.new()
	status_label.text = surgery["status"].to_upper().replace("_", " ")
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.4) if surgery["status"] == "available" else Color(0.5, 0.5, 0.5))
	hbox.add_child(status_label)
	
	# Make clickable
	panel.gui_input.connect(_on_surgery_card_input.bind(surgery))
	
	return panel

func _on_surgery_card_input(event: InputEvent, surgery: Dictionary) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_surgery_info(surgery)
		if surgery["status"] == "available":
			surgery_selected.emit(surgery["id"])

func _show_surgery_info(surgery: Dictionary) -> void:
	var text = "[center][b]%s[/b][/center]\n\n" % surgery["name"]
	text += "[color=gray]%s[/color]\n\n" % surgery["description"]
	text += "[b]Difficulty:[/b] %s\n" % surgery["difficulty"]
	text += "[b]Duration:[/b] %s\n" % surgery["duration"]
	text += "[b]Status:[/b] %s\n" % surgery["status"].to_upper().replace("_", " ")
	
	if surgery.has("instruments"):
		text += "\n[b]Instruments:[/b]\n"
		for instrument in surgery["instruments"]:
			text += "• %s\n" % instrument
	
	if surgery.has("release_date"):
		text += "\n[b]Release:[/b] %s" % surgery["release_date"]
	
	info_label.text = text

func show_catalog() -> void:
	visible = true
	_update_surgery_list()

func _on_close_pressed() -> void:
	visible = false
	closed.emit()
