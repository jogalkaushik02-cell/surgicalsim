extends Node

## HapticFeedback - Mobile vibration feedback

var is_enabled: bool = true
var intensity_multiplier: float = 1.0

# Haptic patterns (duration in ms)
var patterns: Dictionary = {
	"light_touch": 20,
	"medium_touch": 40,
	"heavy_touch": 80,
	"cut": 60,
	"grasp": 30,
	"retract": 50,
	"suture": 45,
	"alert_warning": 100,
	"alert_critical": 200,
	"success": 50,
	"complication": 150
}

signal haptic_triggered(pattern: String, duration: int)

func _ready() -> void:
	pass

func vibrate(pattern: String = "light_touch", custom_duration: int = 0) -> void:
	if not is_enabled:
		return
	
	if not OS.has_feature("android"):
		return
	
	var duration = custom_duration if custom_duration > 0 else patterns.get(pattern, 20)
	duration = int(duration * intensity_multiplier)
	
	Input.vibrate_handheld(duration)
	haptic_triggered.emit(pattern, duration)

func vibrate_cut() -> void:
	vibrate("cut")

func vibrate_grasp() -> void:
	vibrate("grasp")

func vibrate_retract() -> void:
	vibrate("retract")

func vibrate_suture() -> void:
	vibrate("suture")

func vibrate_alert(severity: String = "warning") -> void:
	match severity:
		"critical":
			vibrate("alert_critical")
		_:
			vibrate("alert_warning")

func vibrate_success() -> void:
	vibrate("success")

func vibrate_complication() -> void:
	vibrate("complication")

func vibrate_custom(duration_ms: int) -> void:
	vibrate("light_touch", duration_ms)

func set_enabled(enabled: bool) -> void:
	is_enabled = enabled

func set_intensity(multiplier: float) -> void:
	intensity_multiplier = clamp(multiplier, 0.1, 2.0)
