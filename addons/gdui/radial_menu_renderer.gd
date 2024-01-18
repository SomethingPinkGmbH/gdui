## Renderers are responsible for rendering the radial menu with given parameters. It is also
## responsible for determining which item is currently highlighted and communicate that back to
## the radial menu.
@tool
class_name RadialMenuRenderer extends Resource

## Set the radial menu this renderer is attached to. This is normally called by the radial menu
## itself and should not be called from elsewhere.
func set_radial_menu(radial_menu: RadialMenu):
	assert(false, "Please implement the set_radial_menu function.")
	pass

## Render the visual representation onto the attached radial menu
## (see [method RadialMenuRenderer.set_radial_menu]). This function should also compute which item
## is currently selected based on the mouse position and set [member RadialMenu.highlighted_item]
## accordingly to make the radial menu function correctly.
func render(mouse_angle: float, mouse_distance: float):
	assert(false, "Please implement the render function.")
	pass
