class_name Selectable extends Node

var selection_highlight_material = preload("res://shaders/material_canvas_item_outline.tres")
var selected: bool = false:
	get:
		return selected
	set(value):
		selected = value
		if get_parent() is CanvasItem:
			if value:
				get_parent().material = selection_highlight_material
			else:
				get_parent().material = null
