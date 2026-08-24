## GOMI is supposed to be a simple interface.
## Godot Open Macro Input
## This class is a singleton that allows modders to hook at the GOMI manager.
class_name GOMI
extends Node

static var _singleton:GOMI

signal on_command_line_requested(command_line: String)
signal on_shortcut_line_requested(shortcut_line: String)
signal on_boolean_set_requested(boolean_name: String, value: bool)
signal on_boolean_toggle_requested(boolean_name: String)
signal on_analog_set_requested(analog_name: String, value: float)

signal on_execute_one_time_gdscript_request(gdscript: String, auto_destroy_milliseconds: int)
signal on_execute_named_gdscript_request(unique_name: String, gdscript: String)
signal on_remove_named_gdscript_request(unique_name: String)

signal on_text_in_to_process_request(text_to_process: String)
signal on_bytes_in_to_process_request(bytes_to_process:PackedByteArray)

signal on_text_out_to_broadcast_request(text_to_broadcast: String)
signal on_bytes_out_to_broadcast_request(bytes_to_broadcast:PackedByteArray)


signal on_text_in_game_telemetry(game_telemetry: String)
signal on_bytes_in_game_telemetry(game_telemetry:PackedByteArray)

func _ready() -> void:
	_singleton= self

func _exit_tree() -> void:
	_singleton= null


## Notify the user that the app received game telemetry on the websocket
func push_in_text_game_telemetry(text_game_telemetry:String):
	GOMI.game_text_telemetry(text_game_telemetry)

## Notify the user that the app received game telemetry on the websocket
func push_in_bytes_game_telemetry(bytes_game_telemetry:PackedByteArray):
	GOMI.game_byte_telemetry(bytes_game_telemetry)

func push_in_text_to_process(text_to_process:String):
	GOMI.text_in(text_to_process)

func push_in_bytes_to_process(bytes_to_process:PackedByteArray):
	GOMI.bytes_in(bytes_to_process)

func push_out_text_to_broadcast_(text_to_broadcast:String):
	GOMI.text_out(text_to_broadcast)

func push_out_bytes_to_broadcast(bytes_to_broadcast:PackedByteArray):
	GOMI.bytes_out(bytes_to_broadcast)


func push_in_command_line(command_line:String):
	GOMI.cmd(command_line)

func push_in_shortcut_line(shortcut_line:String):
	GOMI.sc(shortcut_line)

func push_in_boolean_set(boolean_name:String, value:bool):
	GOMI.bool(boolean_name, value)

func push_in_boolean_toggle(boolean_name:String):
	GOMI.toggle(boolean_name)

func push_in_analog_set(analog_name:String, value:float):
	GOMI.analog(analog_name, value)

func push_in_execute_one_time_gdscript(gdscript:String, auto_destroy_milliseconds:int=100):
	GOMI.execute_one_time_gdscript(gdscript, auto_destroy_milliseconds)

func push_in_execute_named_gdscript(unique_name:String, gdscript:String):
	GOMI.execute_named_gdscript(unique_name, gdscript)

func push_in_remove_named_gdscript(unique_name:String):
	GOMI.remove_named_gdscript(unique_name)


## Request to process the text in the app.
## Give an abstract layer for developer to hook in the text processing.
## Any text in is considered a command line or a shortcut line.
static func text_in(text:String):
	if _singleton==null:
		return
	var lines: Array[String] = text.split("\n")
	for line in lines:
		if len(line) > 0:
			line= line.strip_edges()
			if line.begins_with("#"):
				continue
			if len(line) > 0:
				if line.to_lower().begins_with("sc:"):
					sc(line.substr(3, len(line) - 3).strip_edges())
				elif line.to_lower().begins_with("cmd:"):
					cmd(line.substr(4, len(line) - 4).strip_edges())
				else:
					cmd(line)


## Request to send the text to all outputs setup in the app what ever what it is.
## It braodcast the text without asking questions.
static func text_out(text:String):
	if _singleton==null:
		return
	if text.is_empty():
		return
	_singleton.on_text_out_to_broadcast_request.emit(text)


## Request the code in the app to process in the incoming bytes.
## Give an abstract layer for developer to hook in the bytes processing.
static func bytes_in(bytes:PackedByteArray):
	if _singleton==null:
		return
	if bytes.size() == 0:
		return
	_singleton.on_bytes_in_to_process_request.emit(bytes)

## Request to send the bytes to all outputs setup in the app what ever what it is.
## It braodcast the bytes without asking questions.
static func bytes_out(bytes:PackedByteArray):
	if _singleton==null:
		return
	if bytes.size() == 0:
		return
	_singleton.on_bytes_out_to_broadcast_request.emit(bytes)


## Request to execute this command line.
## if it start by # that s comment and should be ignored.
## if it start by sc: it should be shortcut and is redirected.
static func cmd(command_line:String):
	
	if _singleton==null:
		return
	for line in command_line.split("\n"):
		line= line.strip_edges()
		if line.to_lower().begins_with("sc:"):
			sc(line)
			return
		if line.is_empty():
			return
		if line.begins_with("#"):
			return
		_singleton.on_command_line_requested.emit(line)


## Request to execute this shortcut line.
## if it start by # that s comment and should be ignored.
## if it start by cmd: it should be command and is redirected.
static func sc(shortcut_line:String):
	if _singleton==null:
		return
	for line in shortcut_line.split("\n"):
		line = line.strip_edges()
		if line.to_lower().begins_with("cmd:"):
			cmd(line)
		if line.is_empty():
			return
		if line.begins_with("#"):
			return 
		_singleton.on_shortcut_line_requested.emit(line)

## Request to set a boolean value.
## if the boolean_name is empty, it is ignored.

static func bool(boolean_name:String, value:bool):
	if _singleton==null:
		return
	if boolean_name.is_empty():
		return
	_singleton.on_boolean_set_requested.emit(boolean_name, value)


## Request to set an analog/float value.
## if the analog_name is empty, it is ignored.
static func analog(analog_name:String, value:float):
	if _singleton==null:
		return
	if analog_name.is_empty():
		return
	_singleton.on_analog_set_requested.emit(analog_name, value)

## Request to toggle a boolean value.
## if the boolean_name is empty, it is ignored.
static func toggle(boolean_name:String):
	if _singleton==null:
		return
	if boolean_name.is_empty():
		return
	_singleton.on_boolean_toggle_requested.emit(boolean_name)


## Execute a gdscript that is suppose to be executed only once.
## You should autodestroy it.
static func execute_one_time_gdscript(gdscript:String, auto_destroy_milliseconds:int=100):
	if _singleton==null:
		return
	if gdscript.is_empty():
		return
	_singleton.on_execute_one_time_gdscript_request.emit(gdscript, auto_destroy_milliseconds)


static func execute_named_gdscript(unique_name:String, gdscript:String):
	if _singleton==null:
		return
	if gdscript.is_empty():
		return
	if unique_name.is_empty():
		return
	_singleton.on_execute_named_gdscript_request.emit(unique_name, gdscript)

static func remove_named_gdscript(unique_name:String):
	if _singleton==null:
		return
	if unique_name.is_empty():
		return
	_singleton.on_remove_named_gdscript_request.emit(unique_name)



## Allows modder to be notified when any boolean value changed.
static func hook_boolean_changed(callable_boolean_name_with_value:Callable):	
	_listeners_to_any_boolean.append(callable_boolean_name_with_value)

## Allows modder to be notified when any analog value changed.
static func hook_analog_changed(callable_analog_name_with_value:Callable):	
	_listeners_to_any_analog.append(callable_analog_name_with_value)




## Notify the user that the app received game telemetry on the websocket
static func game_text_telemetry(text_game_telemetry:String):
	if _singleton==null:
		return
	if text_game_telemetry.is_empty():
		return
	_singleton.on_text_in_game_telemetry.emit(text_game_telemetry)
	for callable in _listeners_text_game_telemetry:
		callable.call(text_game_telemetry)

## Notify the user that the app received game telemetry on the websocket
static func game_byte_telemetry(bytes_game_telemetry:PackedByteArray):
	if _singleton==null:
		return
	if bytes_game_telemetry.size() == 0:
		return
	_singleton.on_bytes_in_game_telemetry.emit(bytes_game_telemetry)
	for callable in _listeners_byte_game_telemetry:
		callable.call(bytes_game_telemetry)

static var _listeners_to_any_analog: Array[Callable] = []
static var _listeners_to_any_boolean: Array[Callable] = []

static func for_dev_static_notify_to_hook_listeners_boolean_changed(boolean_name:String, value:bool):
	for callable in _listeners_to_any_boolean:
		callable.call(boolean_name, value)

static func for_dev_static_notify_to_hook_listeners_analog_changed(analog_name:String, value:float):
	for callable in _listeners_to_any_analog:
		callable.call(analog_name, value)

func for_dev_local_notify_to_hook_listeners_analog_changed(analog_name:String, value:float):
	for_dev_static_notify_to_hook_listeners_analog_changed(analog_name, value)

func for_dev_local_notify_to_hook_listeners_boolean_changed(boolean_name:String, value:bool):
	for_dev_static_notify_to_hook_listeners_boolean_changed(boolean_name, value)



static var _listeners_text_game_telemetry: Array[Callable] = []
static var _listeners_byte_game_telemetry: Array[Callable] = []

static func hook_to_text_game_telemetry(callback:Callable):
	_listeners_text_game_telemetry.append(callback)
	
	
static func hook_to_byte_game_telemetry(callback:Callable):
	_listeners_byte_game_telemetry.append(callback)
	
	
