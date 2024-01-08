# UI components for Godot

This library contains a collection of reusable UI components for Godot. This library requires the
[gdlogger](https://github.com/SomethingPinkGmbH/gdlogger) library.

---

## `Fadable`

The `Fadable` is a container control for user interfaces that fades in/out its child nodes. You can configure it
to automatically start the fade in when added to the tree and to automatically remove the node from the tree
when the fade out finishes.

<details>
<summary>Configuration options</summary>

### Configuration options

| Option            | Description                                                   | Default |
|-------------------|---------------------------------------------------------------|---------|
| `auto_fade_in`    | Automatically start fading in when added to the tree.         | `true`  |
| `auto_remove`     | Automatically remove from the tree when fade out is complete. | `true`  |
| `transition_time` | The time in seconds the fade should take.                     | `0.1`   |
| `debug_log`       | Enable debug logging.                                         | `false` |

---

</details>

<details>
<summary>Signals</summary>

### Signals

All signals have the following signature:

```gdscript
func _my_on_fadable_signal(new_state: Fadable.State, old_state: Fadable.State):
    pass
```

The `Fadable` has the following signals:

| Signal              | Description                                                                                            |
|---------------------|--------------------------------------------------------------------------------------------------------|
| `removed_from_tree` | The `Fadable` has been removed from the tree. Identical to `tree_exited` but has the state parameters. |
| `fading_in`         | The `Fadable` has started fading in.                                                                   |
| `fading_out`        | The `Fadable` has started fading out.                                                                  |
| `fully_visible`     | The `Fadable` has finished fading in or has been set to show immediately.                              |
| `fully_hidden`      | The `Fadable` has finished fading out or has been set to hide imediately.                              |
| `state_change`      | The `Fadable` has changed its state to any of the above.                                               |

---

</details>

<details>
<summary>API</summary>

### API

The `Fadable` has a simple API to manipulate, for example:

```gdscript
$your_fadable.fade_in()
```

The `Fadable` has the following functions available:

| Function             | Description                                                                      |
|----------------------|----------------------------------------------------------------------------------|
| `fade_in()`          | Starts the fade in process.                                                      |
| `fade_out()`         | Starts the fade out process.                                                     |
| `show_immediately()` | Shows the `Fadable` without a fade. Equivalent to the `show()` default behavior. |
| `hide_immediately()` | Hides the `Fadable` without a fade. Equivalent to the `hide()` default behavior. |



---

</details>

<details>
<summary>States</summary>

### States

You can query the state of the `Fadable` by accessing the `state` variable. You can also change the state by changing its
value.

| State                         | Description                                                                                                                                          |
|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Fadable.State.NOT_IN_TREE`   | The `Fadable` is currently not in a tree. When added to the tree, the `Fadable` will enter the next state.                                           |
| `Fadable.State.FULLY_HIDDEN`  | The `Fadable` is fully hidden. If `auto_fade_in` is enabled and the previous state was `NOT_IN_TREE`, the state will automatically advance.          |
| `Fadable.State.FADING_IN`     | The `Fadable` is fading in. When full opacity is reached, the state will advance.                                                                    |
| `Fadable.State.FULLY_VISIBLE` | The `Fadable` is fully visible.                                                                                                                      |
| `Fadable.State.FADING_OUT`    | The `Fadable` is fading out. When no opacity is reached, the state will advance.                                                                     |
| `Fadable.State.FULLY_HIDDEN`  | The `Fadable` is fully hidden. If `auto_remove` is enabled, the state will advance to `NOT_IN_TREE` and the `Fadable` will be removed from the tree. |

---

</details>

> [!IMPORTANT]
> Do not use the `show()` and `hide()` functions or set the `visible` variable manually! This will not trigger the
> fading behavior.

> [!TIP]
> You can set the state of the `Fadable` before adding it to the tree. In this case the `Fadable` will stay in that state
> until it is added to the tree and continue from there.
