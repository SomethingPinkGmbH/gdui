## A radial menu item.
@tool
class_name RadialMenuItem extends Resource

@export_category("Radial menu")

## Label to show or read for screenreaders.
@export
var label: String
## Icon to show on the option.
@export
var icon: Texture2D

## Initialize the radial menu item with data.
func _init(new_label: String = "", new_icon: Texture2D = null):
	label = new_label
	icon = new_icon
