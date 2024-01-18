## A radial menu is a menu where the user can select an item by moving the mouse in the direction of
## the option.
@tool
@icon("radial_menu.svg")
class_name RadialMenu extends Control

@export_category("Radial menu")

## Items in this radial menu. When the list of items is updated, [signal RadialMenu.items_updated]
## is emitted. The renderer can use this to update a rendered cache of the items.
@export
var items: Array[RadialMenuItem]:
	set(new_items):
		items = new_items
		items_updated.emit()
		queue_redraw()

## Renderer to draw out the radial menu. Use a renderer to select the visual style of the radial
## menu. When the renderer is set, [method RadialMenuRenderer.set_radial_menu] is called to set up
## the connection to the radial menu.
@export
var renderer: RadialMenuRenderer = RadialMenuDefaultRenderer.new():
	set(new_renderer):
		renderer = new_renderer
		if renderer != null:
			renderer.set_radial_menu(self)
			queue_redraw()

## Set the currently highlighted item. This should only be used by the renderer to give feedback
## on the currently highlighted item. It has no effect on the visual appearance of the radial menu.
## When the highlighted item is updated, either [signal RadialMenu.highlighted] or
## [signal RadialMenu.unhighlighted] is emitted.
var highlighted_item: int = -1:
	set(new_highlighted_item):
		if highlighted_item == new_highlighted_item:
			return
		highlighted_item = new_highlighted_item
		if highlighted_item > -1:
			highlighted.emit(self, highlighted_item)
		else:
			unhighlighted.emit(self)

## Current size of the radial menu on the screen. This variable is updated before
## [signal RadialMenu.resize] is emitted.
var viewport_size: Vector2

## The list of items have been updated. You can use this in the renderer to update an item cache.
signal items_updated()

## The radial menu has been resized. You can use this in the renderer to recompute internal sizes.
## The radial menu will call the render() function on the renderer after this signal.
signal resize()

## An item has been highlighted.
signal highlighted(radial_menu: RadialMenu, item: int)

## No item is highlighted.
signal unhighlighted(radial_menu: RadialMenu)

## An item has been selected.
signal selected(radial_menu: RadialMenu, item: int)

## A click has been registered to discard the menu.
signal discard(radial_menu: RadialMenu)

var _direction: Vector2
var _window_in_focus: bool = true

var _mouse_position: Vector2 = Vector2.ZERO
var _joypad_position: Vector2 = Vector2.ZERO
var _last_input_joypad: bool = false
var _last_mouse_mode: Input.MouseMode

func _enter_tree():
	_last_mouse_mode = Input.mouse_mode

func _exit_tree():
	Input.mouse_mode = _last_mouse_mode

func _input(event):
	if !is_visible_in_tree():
		return
	if event is InputEventMouseMotion:
		var mouseMotionEvent: InputEventMouseMotion = event
		_mouse_position = mouseMotionEvent.position
		_last_input_joypad = false
		queue_redraw()
	elif event is InputEventJoypadMotion:
		var joypadMotionEvent: InputEventJoypadMotion = event
		_last_input_joypad = true
		if event.axis == 0:
			_joypad_position.x = joypadMotionEvent.axis_value
		else:
			_joypad_position.y = joypadMotionEvent.axis_value
		queue_redraw()
	elif event is InputEventMouseButton:
		var mouseButtonEvent: InputEventMouseButton = event
		if mouseButtonEvent.button_index == 1 and mouseButtonEvent.pressed:
			if highlighted_item != -1:
				selected.emit(self, highlighted_item)
			else:
				discard.emit(self)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			_window_in_focus = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			_window_in_focus = true
		NOTIFICATION_WM_SIZE_CHANGED:
			viewport_size = get_viewport().get_visible_rect().size
			resize.emit()
			queue_redraw()

func _draw():
	if renderer == null:
		return
	
	# TODO: calculate and pass on joy direction.
	var mouse_y_offset = _mouse_position.y - viewport_size.y/2
	var mouse_x_offset = _mouse_position.x - viewport_size.x/2
	var mouse_distance = sqrt(mouse_x_offset * mouse_x_offset + mouse_y_offset * mouse_y_offset)
	var mouse_angle = deg_to_rad((360 + int(rad_to_deg(atan2(mouse_y_offset, mouse_x_offset)))) % 360)
	renderer.render(mouse_angle, mouse_distance)
