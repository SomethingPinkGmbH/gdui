## The default renderer for the radial menu renders a ring of items and highlight the current item.
## You can set the inner and outer radius of the radial menu.
@tool
@icon("radial_menu.svg")
class_name RadialMenuDefaultRenderer extends RadialMenuRenderer

@export_category("Radial menu")

## Outer radius of the radial menu in percentage of the available screen space.
@export_range(0.0, 100.0)
var outer_radius: float = 40.0:
	set(new_outer_radius):
		if outer_radius == new_outer_radius:
			return
		outer_radius = new_outer_radius
		_on_resize()
		_update_icon_cache()
		if _radial_menu != null:
			_radial_menu.queue_redraw()

## Inner radius of the radial menu in percentage of the available screen space.
@export_range(0.0, 100.0)
var inner_radius: float = 20.0:
	set(new_inner_radius):
		if inner_radius == new_inner_radius:
			return
		inner_radius = new_inner_radius
		_on_resize()
		if _radial_menu != null:
			_radial_menu.queue_redraw()

## Background color of the disc where the items are located.
@export
var background_color: Color = Color(1.0, 1.0, 1.0, 0.5)

## Set the radial menu this renderer is attached to. This is normally called by the radial menu
## itself and should not be called from elsewhere.
func set_radial_menu(radial_menu: RadialMenu):
	_radial_menu = radial_menu
	radial_menu.items_updated.connect(_update_icon_cache)
	radial_menu.resize.connect(_on_resize)
	_update_icon_cache()
	_on_resize()

## Render the radial menu and determine the currently highlighted item.
func render(mouse_angle: float, mouse_distance: float):
	var background_radius = sqrt((_radial_menu.viewport_size.x/2)*(_radial_menu.viewport_size.x/2) + (_radial_menu.viewport_size.y/2)*(_radial_menu.viewport_size.y/2))
	var slice = 2*PI / _radial_menu.items.size()
	var highlighted_item := -1
	
	_radial_menu.draw_arc(
		_radial_menu.viewport_size/2,
		(background_radius - _real_inner_radius)/2 + _real_inner_radius,
		0,
		360,
		int(_real_outer_radius * 2 * PI),
		background_color,
		background_radius - _real_inner_radius,
		true
	)
	
	for i in range(0, _radial_menu.items.size()):
		var start = slice * i
		var end = slice * (i + 1)
		
		var start_point = _radial_menu.viewport_size/2 + Vector2(_real_inner_radius, 0).rotated(start)
		var end_point = _radial_menu.viewport_size/2 + Vector2(_real_outer_radius, 0).rotated(start)
		
		if mouse_angle > start and mouse_angle < end and mouse_distance < _real_outer_radius and mouse_distance > _real_inner_radius:
			highlighted_item = i
			_radial_menu.draw_arc(
				_radial_menu.viewport_size/2,
				mouse_distance,
				start,
				end,
				int(_real_outer_radius * 2 * PI),
				Color(0.5, 0.5, 1, 0.9),
				_real_outer_radius - _real_inner_radius,
				true
			)
		
		_radial_menu.draw_line(
			start_point,
			end_point,
			Color.WHITE,
			2.0,
			true
		)
		
		var center_point = Vector2(
			mouse_distance * cos(start + (end-start)/2),
			mouse_distance * sin(start + (end-start)/2)
		)
		_radial_menu.draw_texture(
			_icon_cache[i],
			_radial_menu.viewport_size/2 + center_point - _icon_cache[i].get_size()/2
		)
	
	_radial_menu.draw_arc(
		_radial_menu.viewport_size/2,
		_real_inner_radius,
		0, 360,
		int(_real_inner_radius * 2 * PI),
		Color.WHITE,
		10.0,
		true
	)
	
	_radial_menu.draw_arc(
		_radial_menu.viewport_size/2,
		_real_inner_radius - 30.0,
		0, 360,
		int(_real_inner_radius * 2 * PI),
		Color.WHITE,
		5.0,
		true
	)
	_radial_menu.highlighted_item = highlighted_item

var _real_outer_radius: float
var _real_inner_radius: float
var _radial_menu: RadialMenu
var _icon_cache: Array[Texture2D]

func _update_icon_cache():
	if _radial_menu == null:
		return
	var cache: Array[Texture2D] = []
	for item in _radial_menu.items:
		var icon: Image = item.icon.get_image()
		var width = icon.get_width()
		var height = icon.get_height()
		var diameter = sqrt(width*width + height*height)
		var resize_factor = (_real_outer_radius - _real_inner_radius)/diameter
		if resize_factor < 1:
			var new_width = width * resize_factor
			var new_height = height * resize_factor
			if new_width != 0 and new_height != 0:
				icon.resize(new_width, new_height)
		cache.append(ImageTexture.create_from_image(icon))
	_icon_cache = cache

func _on_resize():
	if _radial_menu == null:
		return
	var max_size: float = min(_radial_menu.viewport_size.x, _radial_menu.viewport_size.y)
	_real_outer_radius = max_size * outer_radius / 100
	_real_inner_radius = max_size * inner_radius / 100
