extends Node

## CommunicationSystem - Quick chat and team communication

var message_history: Array[Dictionary] = []
var max_history: int = 50

# Quick chat categories
var quick_chat_commands: Dictionary = {
	"instruments": [
		{"id": "scalpel", "text": "Scalpel please", "icon": " scalpel"},
		{"id": "forceps", "text": "Forceps", "icon": " forceps"},
		{"id": "retractor", "text": "Retractor", "icon": " retractor"},
		{"id": "suture", "text": "Suture", "icon": " suture"}
	],
	"actions": [
		{"id": "retract", "text": "Retract here", "icon": " retract"},
		{"id": "hold", "text": "Hold this", "icon": " hold"},
		{"id": "cut", "text": "Making cut", "icon": " cut"},
		{"id": "stop", "text": "Wait/Stop", "icon": " stop"}
	],
	"alerts": [
		{"id": "bleeding", "text": "Bleeding!", "icon": " bleed"},
		{"id": "vitals", "text": "Check vitals", "icon": " pulse"},
		{"id": "help", "text": "Need help!", "icon": " help"},
		{"id": "complication", "text": "Complication!", "icon": " alert"}
	],
	"feedback": [
		{"id": "good", "text": "Good job!", "icon": " good"},
		{"id": "slow", "text": "Slow down", "icon": " slow"},
		{"id": "faster", "text": "Faster", "icon": " fast"},
		{"id": "perfect", "text": "Perfect!", "icon": " star"}
	]
}

signal message_sent(message: Dictionary)
signal message_received(message: Dictionary)
signal quick_chat_sent(command_id: String, sender_id: int)

func _ready() -> void:
	pass

func send_message(text: String, sender_id: int = 1, sender_name: String = "Player") -> void:
	var message = {
		"id": message_history.size(),
		"text": text,
		"sender_id": sender_id,
		"sender_name": sender_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"type": "custom"
	}
	
	_add_message(message)
	message_sent.emit(message)
	
	# Send to network if multiplayer
	if NetworkManager.is_multiplayer_active():
		_sync_message.rpc(text, sender_id, sender_name)

func send_quick_chat(command_id: String, sender_id: int = 1, sender_name: String = "Player") -> void:
	var command = _find_command(command_id)
	if not command:
		return
	
	var message = {
		"id": message_history.size(),
		"text": command["text"],
		"icon": command["icon"],
		"sender_id": sender_id,
		"sender_name": sender_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"type": "quick_chat",
		"command_id": command_id
	}
	
	_add_message(message)
	quick_chat_sent.emit(command_id, sender_id)
	message_sent.emit(message)
	
	# Play sound based on command type
	_play_chat_sound(command_id)
	
	# Send to network if multiplayer
	if NetworkManager.is_multiplayer_active():
		_sync_quick_chat.rpc(command_id, sender_id, sender_name)

func send_instruction(text: String, from_role: int, sender_id: int = 1, sender_name: String = "Lead Surgeon") -> void:
	var message = {
		"id": message_history.size(),
		"text": text,
		"sender_id": sender_id,
		"sender_name": sender_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"type": "instruction",
		"from_role": from_role
	}
	
	_add_message(message)
	message_sent.emit(message)
	
	# Instructions are prioritized
	Events.log_event("instruction_sent", {"from": sender_name, "text": text})
	
	if NetworkManager.is_multiplayer_active():
		_sync_instruction.rpc(text, from_role, sender_id, sender_name)

func _add_message(message: Dictionary) -> void:
	message_history.append(message)
	if message_history.size() > max_history:
		message_history.pop_front()

func _find_command(command_id: String) -> Dictionary:
	for category in quick_chat_commands.values():
		for command in category:
			if command["id"] == command_id:
				return command
	return {}

func _play_chat_sound(command_id: String) -> void:
	match command_id:
		"bleeding", "help", "complication":
			SoundManager.play_alert("warning")
		"scalpel", "forceps", "retractor", "suture":
			SoundManager.play_metal_clink()
		_:
			pass

func get_quick_chat_commands() -> Dictionary:
	return quick_chat_commands

func get_message_history() -> Array[Dictionary]:
	return message_history

func get_recent_messages(count: int = 10) -> Array[Dictionary]:
	return message_history.slice(-count)

func clear_history() -> void:
	message_history.clear()

@rpc("any_peer", "reliable")
func _sync_message(text: String, sender_id: int, sender_name: String) -> void:
	var message = {
		"id": message_history.size(),
		"text": text,
		"sender_id": sender_id,
		"sender_name": sender_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"type": "custom"
	}
	_add_message(message)
	message_received.emit(message)

@rpc("any_peer", "reliable")
func _sync_quick_chat(command_id: String, sender_id: int, sender_name: String) -> void:
	var command = _find_command(command_id)
	if not command:
		return
	
	var message = {
		"id": message_history.size(),
		"text": command["text"],
		"icon": command.get("icon", ""),
		"sender_id": sender_id,
		"sender_name": sender_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"type": "quick_chat",
		"command_id": command_id
	}
	_add_message(message)
	quick_chat_sent.emit(command_id, sender_id)
	message_received.emit(message)

@rpc("any_peer", "reliable")
func _sync_instruction(text: String, from_role: int, sender_id: int, sender_name: String) -> void:
	var message = {
		"id": message_history.size(),
		"text": text,
		"sender_id": sender_id,
		"sender_name": sender_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"type": "instruction",
		"from_role": from_role
	}
	_add_message(message)
	message_received.emit(message)
