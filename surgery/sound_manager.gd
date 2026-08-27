extends Node

## SoundManager - Handles all OR sounds

var is_muted: bool = false
var master_volume: float = 1.0
var music_volume: float = 0.3
var sfx_volume: float = 0.8

# Audio players for different sound types
var heartbeat_player: AudioStreamPlayer = null
var ambient_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
var alert_player: AudioStreamPlayer = null

# Sound paths (placeholder - would load actual audio files)
var sounds: Dictionary = {
	"heartbeat_normal": "res://assets/sounds/heartbeat_normal.wav",
	"heartbeat_fast": "res://assets/sounds/heartbeat_fast.wav",
	"heartbeat_slow": "res://assets/sounds/heartbeat_slow.wav",
	"cut_tissue": "res://assets/sounds/cut_tissue.wav",
	"cut_skin": "res://assets/sounds/cut_skin.wav",
	"retract": "res://assets/sounds/retract.wav",
	"grasp": "res://assets/sounds/grasp.wav",
	"suture": "res://assets/sounds/suture.wav",
	"metal_clink": "res://assets/sounds/metal_clink.wav",
	"monitor_beep": "res://assets/sounds/monitor_beep.wav",
	"alert_warning": "res://assets/sounds/alert_warning.wav",
	"alert_critical": "res://assets/sounds/alert_critical.wav",
	"ambient_or": "res://assets/sounds/ambient_or.wav",
	"scalpel_scrape": "res://assets/sounds/scalpel_scrape.wav",
	"cauterize": "res://assets/sounds/cauterize.wav"
}

# Current heartbeat state
var current_heartbeat_speed: float = 1.0
var heartbeat_timer: float = 0.0

signal sound_played(sound_name: String)
signal volume_changed(bus: String, volume: float)

func _ready() -> void:
	_setup_audio_players()
	Events.patient_vitals_changed.connect(_on_vitals_changed)
	Events.cut_performed.connect(_on_cut_performed)

func _setup_audio_players() -> void:
	# Heartbeat player (loops)
	heartbeat_player = AudioStreamPlayer.new()
	heartbeat_player.name = "HeartbeatPlayer"
	heartbeat_player.bus = "Master"
	add_child(heartbeat_player)
	
	# Ambient player (loops)
	ambient_player = AudioStreamPlayer.new()
	ambient_player.name = "AmbientPlayer"
	ambient_player.bus = "Master"
	add_child(ambient_player)
	
	# Alert player
	alert_player = AudioStreamPlayer.new()
	alert_player.name = "AlertPlayer"
	alert_player.bus = "Master"
	add_child(alert_player)
	
	# SFX pool (8 players for concurrent sounds)
	for i in range(8):
		var player = AudioStreamPlayer.new()
		player.name = "SFXPlayer_" + str(i)
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

func _process(delta: float) -> void:
	if not is_muted:
		_update_heartbeat(delta)

func _update_heartbeat(delta: float) -> void:
	heartbeat_timer -= delta
	if heartbeat_timer <= 0:
		_play_heartbeat()
		heartbeat_timer = 1.0 / current_heartbeat_speed

func _play_heartbeat() -> void:
	if is_muted:
		return
	
	# Choose heartbeat sound based on speed
	var sound_key = "heartbeat_normal"
	if current_heartbeat_speed > 1.2:
		sound_key = "heartbeat_fast"
	elif current_heartbeat_speed < 0.8:
		sound_key = "heartbeat_slow"
	
	_play_sound(sound_key, 0.5)

func play_ambient() -> void:
	_play_sound("ambient_or", music_volume)

func stop_ambient() -> void:
	if ambient_player.playing:
		ambient_player.stop()

func play_cut_sound(tissue_type: String = "tissue") -> void:
	match tissue_type:
		"skin":
			_play_sound("cut_skin", sfx_volume)
		_:
			_play_sound("cut_tissue", sfx_volume)
	
	if OS.has_feature("android"):
		Input.vibrate_handheld(50)

func play_retract_sound() -> void:
	_play_sound("retract", sfx_volume * 0.7)
	if OS.has_feature("android"):
		Input.vibrate_handheld(30)

func play_grasp_sound() -> void:
	_play_sound("grasp", sfx_volume * 0.6)
	if OS.has_feature("android"):
		Input.vibrate_handheld(20)

func play_suture_sound() -> void:
	_play_sound("suture", sfx_volume * 0.7)
	if OS.has_feature("android"):
		Input.vibrate_handheld(40)

func play_metal_clink() -> void:
	_play_sound("metal_clink", sfx_volume * 0.5)

func play_scalpel_scrape() -> void:
	_play_sound("scalpel_scrape", sfx_volume * 0.6)
	if OS.has_feature("android"):
		Input.vibrate_handheld(15)

func play_cauterize_sound() -> void:
	_play_sound("cauterize", sfx_volume * 0.8)
	if OS.has_feature("android"):
		Input.vibrate_handheld(100)

func play_monitor_beep() -> void:
	_play_sound("monitor_beep", sfx_volume * 0.4)

func play_alert(severity: String = "warning") -> void:
	match severity:
		"critical":
			_play_sound("alert_critical", sfx_volume)
			if OS.has_feature("android"):
				Input.vibrate_handheld(200)
		_:
			_play_sound("alert_warning", sfx_volume * 0.8)
			if OS.has_feature("android"):
				Input.vibrate_handheld(100)

func _play_sound(sound_name: String, volume: float = 1.0) -> void:
	if is_muted:
		return
	
	# Find available player
	var player = _get_available_player()
	if not player:
		return
	
	# Load sound (placeholder - would load actual audio)
	# For now, just log the sound play
	sound_played.emit(sound_name)

func _get_available_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return sfx_players[0]  # Steal oldest sound

func _on_vitals_changed(vitals: Dictionary) -> void:
	var hr = vitals.get("heart_rate", 72)
	current_heartbeat_speed = hr / 72.0  # Normalize to 72 bpm baseline

func _on_cut_performed(_instrument: String, _target: String, result: String) -> void:
	if result == "SUCCESS":
		play_metal_clink()

func set_muted(muted: bool) -> void:
	is_muted = muted
	if muted:
		heartbeat_player.stop()
		ambient_player.stop()
		for player in sfx_players:
			player.stop()

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	volume_changed.emit("Master", master_volume)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)

func toggle_mute() -> void:
	set_muted(!is_muted)
