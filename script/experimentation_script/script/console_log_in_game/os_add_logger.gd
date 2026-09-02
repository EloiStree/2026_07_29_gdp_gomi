class_name OsAddLogger
extends Label

signal on_logger_print_found(message: String)
signal on_logger_warning_found(message: String)
signal on_logger_error_found(message: String)
signal on_logger_any_found(message: String)

static var _instance_in_scene: OsAddLogger
@export var _max_lines: int = 100
@export var _use_colors: bool = false


var _logger_callable: CustomLogger
var _pending_messages: PackedStringArray = []
var _update_timer: float = 0.0

func _ready() -> void:
	_instance_in_scene = self
	autowrap_mode = TextServer.AUTOWRAP_OFF
	
	# Create callable and register logger
	_logger_callable = CustomLogger.new()
	OS.add_logger(_logger_callable)


func _on_log_message(message: String, is_error: bool = false, is_warning: bool = false) -> void:
	# Format message with optional colors
	var formatted := message
	if _use_colors:
		if is_error:
			formatted = "[color=red]%s[/color]" % message
		elif is_warning:
			formatted = "[color=yellow]%s[/color]" % message
	
	# Buffer message (UI updates happen in _process for thread safety)
	_pending_messages.append(formatted)
	
	# Emit signal for external handling
	if is_error:
		on_logger_error_found.emit(message)
	elif is_warning:
		on_logger_warning_found.emit(message)
	else:
		on_logger_print_found.emit(message)
	on_logger_any_found.emit(message)


func _process(delta: float) -> void:
	if _pending_messages.is_empty():
		return
	
	# Batch UI updates every ~50ms for performance
	_update_timer += delta
	if _update_timer >= 0.05:
		_update_timer = 0.0
		_flush_messages()


func _flush_messages() -> void:
	var lines := text.split("\n")
	
	for msg in _pending_messages:
		lines.append(msg)
	_pending_messages.clear()
	
	# Trim old lines
	if lines.size() > _max_lines:
		lines = lines.slice(lines.size() - _max_lines)
	
	text = "\n".join(lines)
	

func clear_log() -> void:
	text = ""
	_pending_messages.clear()


func _exit_tree() -> void:
	# Clean up to prevent dangling references
	if _logger_callable != null:
		OS.remove_logger(_logger_callable)



class CustomLogger extends Logger:
	func _log_info(message: String, code: String, stack: Array[ScriptBacktrace], thread_id: int) -> void:
		OsAddLogger._instance_in_scene._on_log_message(message, false, false)
	
	func _log_warning(message: String, code: String, stack: Array[ScriptBacktrace], thread_id: int) -> void:
		OsAddLogger._instance_in_scene._on_log_message(message, false, true)
	
	func _log_error(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
		OsAddLogger._instance_in_scene._on_log_message(rationale, true, false)
