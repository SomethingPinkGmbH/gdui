extends GutTest

func test_setting_renderer():
	var radial_menu: RadialMenu = RadialMenu.new()
	var renderer: RadialMenuRenderer = RadialMenuDefaultRenderer.new()
	radial_menu.renderer = renderer
	assert_eq(renderer._radial_menu, radial_menu)
