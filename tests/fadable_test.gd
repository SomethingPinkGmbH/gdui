extends GutTest

func test_add_remove_tree() -> void:
	var logger: Logger = Logger.new()
	logger.debug("Starting test_add_remove_tree")
	
	var fadable: Fadable = Fadable.new()
	fadable.logger = logger
	
	# Set the transition time high so the state is deterministic.
	fadable.transition_time = 100
	
	assert_eq(fadable.state, Fadable.State.NOT_IN_TREE)
	
	add_child(fadable)
	
	assert_eq(fadable.state, Fadable.State.FADING_IN)
	
	remove_child(fadable)
	
	assert_eq(fadable.state, Fadable.State.NOT_IN_TREE)
	wait_seconds(1)
	assert_null(fadable.get_parent())
	fadable.free()
	logger.debug("Finished test_add_remove_tree")
	logger.free()

func test_fade_in_out() -> void:
	var logger: Logger = Logger.new()
	logger.debug("Starting test_fade_in_out")
	
	var fadable: Fadable = Fadable.new()
	fadable.logger = logger
	fadable.transition_time = 1
	fadable.auto_fade_in = false
	fadable.auto_remove = false
	
	add_child(fadable)
	assert_eq(fadable.state, Fadable.State.FULLY_HIDDEN)
	
	logger.debug("Setting state to FADING_IN")
	fadable.fade_in()
	assert_eq(fadable.state, Fadable.State.FADING_IN)
	
	logger.debug("Waiting for 5 seconds...")
	await get_tree().create_timer(5).timeout
	
	logger.debug("Checking if fadable is visible...")
	assert_eq(fadable.state, Fadable.State.FULLY_VISIBLE)
	
	logger.debug("Setting state to FADING_OUT")
	fadable.fade_out()
	assert_eq(fadable.state, Fadable.State.FADING_OUT)
	
	logger.debug("Waiting for 5 seconds...")
	await get_tree().create_timer(5).timeout
	assert_eq(fadable.state, Fadable.State.FULLY_HIDDEN)

	logger.debug("Setting state to NOT_IN_TREE")
	watch_signals(fadable)
	fadable.state = Fadable.State.NOT_IN_TREE
	wait_for_signal(fadable.tree_exited, 5.0)
	
	fadable.free()

	logger.debug("Finished test_fade_in_out")
	logger.free()
