class_name PushToSingletonGOMI
extends Node



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
