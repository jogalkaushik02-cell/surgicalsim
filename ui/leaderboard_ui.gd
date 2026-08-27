extends CanvasLayer

## LeaderboardUI - Local leaderboard screen

var is_visible: bool = false

# UI elements
var panel: PanelContainer = null
var title_label: Label = null
var scores_container: VBoxContainer = null
var close_button: Button = null
var tab_container: TabContainer = null

# Current view
var current_surgery_type: String = "appendicectomy"

func _ready() -> void:
	_create_ui()
	hide()

func _create_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "LeaderboardPanel"
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 150
	panel.offset_top = 80
	panel.offset_right = -150
	panel.offset_bottom = -80
	add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Header
	var header = HBoxContainer.new()
	vbox.add_child(header)
	
	title_label = Label.new()
	title_label.text = "LEADERBOARD"
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)
	
	close_button = Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(40, 40)
	close_button.pressed.connect(_on_close_pressed)
	header.add_child(close_button)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	# Tab container for different surgery types
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(tab_container)
	
	# Create tabs
	_create_tab("appendicectomy", "Appendicectomy")
	_create_tab("cholecystectomy", "Cholecystectomy")
	_create_tab("hernia", "Hernia Repair")
	
	# Update display
	_update_leaderboard()

func _create_tab(tab_id: String, tab_name: String) -> void:
	var tab = VBoxContainer.new()
	tab.name = tab_name
	tab_container.add_child(tab)
	
	# Column headers
	var headers = HBoxContainer.new()
	tab.add_child(headers)
	
	var rank_header = Label.new()
	rank_header.text = "Rank"
	rank_header.custom_minimum_size = Vector2(60, 0)
	rank_header.add_theme_font_size_override("font_size", 14)
	rank_header.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	headers.add_child(rank_header)
	
	var name_header = Label.new()
	name_header.text = "Player"
	name_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_header.add_theme_font_size_override("font_size", 14)
	name_header.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	headers.add_child(name_header)
	
	var score_header = Label.new()
	score_header.text = "Score"
	score_header.custom_minimum_size = Vector2(80, 0)
	score_header.add_theme_font_size_override("font_size", 14)
	score_header.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	headers.add_child(score_header)
	
	var time_header = Label.new()
	time_header.text = "Time"
	time_header.custom_minimum_size = Vector2(80, 0)
	time_header.add_theme_font_size_override("font_size", 14)
	time_header.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	headers.add_child(time_header)
	
	# Scores container
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab.add_child(scroll)
	
	var scores_vbox = VBoxContainer.new()
	scores_vbox.name = "ScoresContainer"
	scores_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(scores_vbox)

func _update_leaderboard() -> void:
	var scores = LocalSaveManager.get_top_scores(20)
	
	# Clear existing scores
	for tab in tab_container.get_children():
		var container = tab.get_node_or_null("ScoresContainer")
		if container:
			for child in container.get_children():
				child.queue_free()
	
	# Add scores to appropriate tabs
	for i in range(scores.size()):
		var score = scores[i]
		var surgery_type = score.get("surgeryType", "appendicectomy")
		
		var tab = tab_container.get_node_or_null(surgery_type.capitalize())
		if tab:
			var container = tab.get_node_or_null("ScoresContainer")
			if container:
				_add_score_row(container, i + 1, score)

func _add_score_row(parent: Control, rank: int, score_data: Dictionary) -> void:
	var row = HBoxContainer.new()
	parent.add_child(row)
	
	# Rank
	var rank_label = Label.new()
	rank_label.text = "#" + str(rank)
	rank_label.custom_minimum_size = Vector2(60, 0)
	rank_label.add_theme_font_size_override("font_size", 14)
	if rank <= 3:
		rank_label.add_theme_color_override("font_color", _get_rank_color(rank))
	row.add_child(rank_label)
	
	# Player name
	var name_label = Label.new()
	name_label.text = score_data.get("displayName", "Unknown")
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 14)
	row.add_child(name_label)
	
	# Score
	var score_label = Label.new()
	score_label.text = str(score_data.get("score", 0))
	score_label.custom_minimum_size = Vector2(80, 0)
	score_label.add_theme_font_size_override("font_size", 14)
	score_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	row.add_child(score_label)
	
	# Time
	var time_label = Label.new()
	var time_secs = score_data.get("time", 0)
	var minutes = int(time_secs) / 60
	var seconds = int(time_secs) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	time_label.custom_minimum_size = Vector2(80, 0)
	time_label.add_theme_font_size_override("font_size", 14)
	row.add_child(time_label)

func _get_rank_color(rank: int) -> Color:
	match rank:
		1:
			return Color(1.0, 0.84, 0.0)  # Gold
		2:
			return Color(0.75, 0.75, 0.75)  # Silver
		3:
			return Color(0.8, 0.5, 0.2)  # Bronze
		_:
			return Color(1, 1, 1)

func _on_close_pressed() -> void:
	hide()

func show() -> void:
	visible = true
	is_visible = true
	_update_leaderboard()

func hide() -> void:
	visible = false
	is_visible = false
