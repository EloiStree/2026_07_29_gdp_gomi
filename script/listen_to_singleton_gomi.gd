class_name ListenToSingletonGomi
extends Node

signal on_analog_set_requested(analog_name: String, value: float)
signal on_boolean_set_requested(boolean_name: String, value: bool)
signal on_bytes_game_telemetry_received(bytes_game_telemetry: PackedByteArray)
signal on_text_game_telemetry_received(text_game_telemetry: String)

@export var _delay_to_listen_to_singleton_gomi: float = 0.1

func _ready() -> void:
    await get_tree().create_timer(_delay_to_listen_to_singleton_gomi).timeout
    GOMI.hook_analog_changed(_on_analog_key_value_changed)
    GOMI.hook_boolean_changed(_on_boolean_key_value_changed)
    GOMI.hook_to_byte_game_telemetry(_on_byte_game_telemetry_received)
    GOMI.hook_to_text_game_telemetry(_on_text_game_telemetry_received)

func _on_analog_key_value_changed(analog_name:String, value:float) -> void:
    on_analog_set_requested.emit(analog_name, value)

func _on_boolean_key_value_changed(boolean_name:String, value:bool) -> void:
    on_boolean_set_requested.emit(boolean_name, value)

func _on_byte_game_telemetry_received(bytes_game_telemetry:PackedByteArray) -> void:
    on_bytes_game_telemetry_received.emit(bytes_game_telemetry)

func _on_text_game_telemetry_received(text_game_telemetry:String) -> void:
    on_text_game_telemetry_received.emit(text_game_telemetry)



