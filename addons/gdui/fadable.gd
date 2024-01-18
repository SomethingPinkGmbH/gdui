## A fadable is a control container element that fades in either automatically or manually
## when added to the tree. If fade_out is called, it fades out and automatically removes 
## the node from the tree if desired.
@tool
@icon("fadable.svg")
class_name Fadable extends Control

## The UI element has been removed from the tree.
signal removed_from_tree
## The UI element is fading in.
signal fading_in
## The UI element is fading out.
signal fading_out
## The UI element is fully visible.
signal fully_visible
## The UI element is fully hidden.
signal fully_hidden
## The UI element has changed state. The event will have the current and the old state as parameters.
signal state_change

## Automatically fade in when added to the tree.
@export
var auto_fade_in: bool = true

## Automatically remove from the tree when the fade out has finished.
@export
var auto_remove: bool = true

## Time to fade in/out in seconds.
@export
var transition_time: float = 0.1

## Enable debug logging to print state changes of this fadable. This is normally not needed and
## should not be enabled for production.
@export
var debug_log: bool = false:
	set(new_debug_log):
		if new_debug_log == debug_log:
			return
		debug_log = new_debug_log
		if !debug_log:
			logger = null
		elif logger == null:
			logger = Logger.get_service(self)

## Logger for this control used for debug logging.
var logger: Logger = null

## The current state the fadable element is in. Setting this will immediately change the fadable
## to that state. It is valid to set the state even though the fadable is not in a tree.
var state: State = State.NOT_IN_TREE:
	set(new_state):
		if state == new_state:
			return
		var old_state: State = state
		
		match new_state:
			State.NOT_IN_TREE:
				_write_debug_log("Fadable state is now NOT_IN_TREE.")
				state = new_state
				removed_from_tree.emit(new_state, old_state)
				_remove_from_parent.call_deferred()
			State.FADING_IN:
				_write_debug_log("Fadable state is now FADING_IN.")
				visible = true
				state = new_state
				fading_in.emit(new_state, old_state)
			State.FADING_OUT:
				_write_debug_log("Fadable state is now FADING_OUT.")
				visible = true
				state = new_state
				fading_out.emit(new_state, old_state)
			State.FULLY_VISIBLE:
				_write_debug_log("Fadable state is now FULLY_VISIBLE.")
				visible = true
				modulate.a = 1.0
				state = new_state
				fully_visible.emit(new_state, old_state)
			State.FULLY_HIDDEN:
				_write_debug_log("Fadable state is now FULLY_HIDDEN.")
				visible = false
				modulate.a = 0.0
				state = new_state
				fully_hidden.emit(new_state, old_state)
		state_change.emit(new_state, old_state)
		
		if old_state == State.NOT_IN_TREE and new_state == State.FULLY_HIDDEN and auto_fade_in:
			_write_debug_log("Automatically fading in.")
			_write_debug_log("Fadable state is now FADING_IN.")
			old_state = state
			new_state = State.FADING_IN
			state = new_state
			fading_in.emit(new_state, old_state)
			state_change.emit(new_state, old_state)
		elif new_state == State.FULLY_HIDDEN and auto_remove:
			_write_debug_log("Automatically removing fadable from tree.")
			_write_debug_log("Fadable state is now NOT_IN_TREE.")
			old_state = state
			new_state = State.NOT_IN_TREE
			_remove_from_parent.call_deferred()
			state = new_state
			removed_from_tree.emit(new_state, old_state)
			state_change.emit(new_state, old_state)

## This function immediately shows the control without fade.
func show_immediately() -> void:
	state = State.FULLY_VISIBLE

## This function immediately hides the control without fade.
func hide_immediately() -> void:
	state = State.FULLY_HIDDEN

## This function starts the process of fading in.
func fade_in() -> void:
	state = State.FADING_IN

## This function starts the process of fading out.
func fade_out() -> void:
	state = State.FADING_OUT

func _process(delta: float) -> void:
	match state:
		State.FADING_IN:
			modulate.a += min(1.0, delta / transition_time)
			_write_debug_log("Fadable opacity is now %f"%[modulate.a])
			if modulate.a > 0.99:
				state = State.FULLY_VISIBLE
		State.FADING_OUT:
			modulate.a -= max(0.0, delta / transition_time)
			_write_debug_log("Fadable opacity is now %s"%[modulate.a])
			if modulate.a < 0.01:
				state = State.FULLY_HIDDEN

func _write_debug_log(message: String) -> void:
	if !logger:
		return
	if !debug_log:
		return
	logger.debug(message)

func _remove_from_parent() -> void:
	var parent: Node = get_parent()
	if parent != null:
		parent.remove_child(self)

func _enter_tree() -> void:
	if debug_log and logger == null:
		logger = Logger.get_service(self)
	_write_debug_log("Fadable has been added to tree.")
	
	if state == State.NOT_IN_TREE:
		if auto_fade_in:
			state = State.FADING_IN
		else:
			state = State.FULLY_HIDDEN

func _exit_tree() -> void:
	_write_debug_log("Fadable has been removed from tree.")
	state = State.NOT_IN_TREE

## Collects the states the fadable can be in.
enum State{
	## The fadable is currently not part of the tree.
	NOT_IN_TREE,
	## The fadable is currently in the process of fading in. Once the fade in is complete, the 
	## fadable will transition into the fully visible state.
	FADING_IN,
	## The fadable is currently fully visible.
	FULLY_VISIBLE,
	## The fadable is currently fading out. Once the fade out is complete, the fadable will
	## transition into the fully hidden state.
	FADING_OUT,
	## The fadable is currently in the process of fading out. If auto_remove is enabled, the state
	## will immediately transition into NOT_IN_TREE and the fadable will be removed from the tree.
	FULLY_HIDDEN
}
