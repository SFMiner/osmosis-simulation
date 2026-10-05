extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func tick(cells: RedBloodCells, frames: int) -> void:
	for i: int in frames:
		cells._physics_process(1.0 / 60.0)

func verify() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.mode_button.pressed.emit()
	var cells: RedBloodCells = scene.red_cells
	assert(cells.active and cells.visible and not scene.cell.visible and not scene.field.visible)
	assert(not scene.simulation.is_physics_processing())
	tick(cells, 120)
	for c: Dictionary in cells.cells:
		assert(c.water == 1.0 and not c.burst)
	scene.slider.value = 5
	tick(cells, 1200)
	for c: Dictionary in cells.cells:
		assert(c.water < 1.0 and not c.burst)
	scene.slider.value = 0
	tick(cells, 2400)
	for c: Dictionary in cells.cells:
		assert(absf(c.water - 1.0) < 0.001)
	scene.slider.value = -5
	tick(cells, 60)
	scene.toggle_pause()
	var snapshot: Array[Dictionary] = cells.cells.duplicate(true)
	var stopped_time: float = cells.clock_time
	tick(cells, 120)
	assert(cells.cells == snapshot and cells.clock_time == stopped_time)
	scene.toggle_pause()
	tick(cells, 900)
	for c: Dictionary in cells.cells:
		assert(c.burst and is_equal_approx(c.fade, cells.FADE_SECONDS))
	assert(not scene.inside_bar.visible)
	scene.slider.value = 0
	tick(cells, 120)
	for c: Dictionary in cells.cells:
		assert(c.burst)
	scene.reset_all()
	assert(scene.red_cell_mode and scene.inside_bar.visible)
	for c: Dictionary in cells.cells:
		assert(c.water == 1.0 and not c.burst)
	scene.toggle_neutral_size()
	assert(cells.show_neutral)
	scene.mode_button.pressed.emit()
	assert(not cells.active and not cells.visible and scene.cell.visible and scene.field.visible)
	assert(scene.simulation.is_physics_processing() and scene.inside_bar.visible)
	assert(scene.simulation.setting == 0 and not scene.simulation.paused)
	print("PASS: mode buttons, neutral stability, hypertonic shrinking, reversal, pause, pure-water bursting/fade, no resurrection, reset and mode return")
	quit()
