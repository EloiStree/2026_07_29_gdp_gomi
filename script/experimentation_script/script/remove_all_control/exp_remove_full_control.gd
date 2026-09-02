class_name ExpRemoveFullControl
extends Node

@export var _target_parent: Node

func _ready() -> void:
	_remove_focus_from_controls(_target_parent)
	get_viewport().gui_release_focus()


func _remove_focus_from_controls(node: Node) -> void:
	if node is Control:
		if node is LineEdit:
			node.focus_mode = Control.FOCUS_CLICK
		else:
			node.focus_mode = Control.FOCUS_NONE

	for child in node.get_children():
		_remove_focus_from_controls(child)
