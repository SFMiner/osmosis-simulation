extends Control

signal slider_changed(value: int)

var simulation: OsmosisSimulation
var cell: CellView
var field: ParticleField
var slider: HSlider
var setting_label: Label
var live_label: Label
var explanation: Label
var flow_label: Label
var size_label: Label
var inside_bar: ProgressBar
var outside_bar: ProgressBar
var neutral_label: Label
var pause_button: Button
var neutral_button: Button
var neutral_visible: bool = false
var red_cells: RedBloodCells
var red_cell_mode: bool = false
var mode_button: Button
var title_label: Label
var legend_label: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("101d30")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	field = ParticleField.new()
	add_child(field)
	cell = CellView.new()
	cell.position = ParticleField.CENTER
	add_child(cell)
	red_cells = RedBloodCells.new()
	red_cells.visible = false
	add_child(red_cells)
	title_label = label_at("OSMOSIS LAB  •  Animal cell", Vector2(75, 18), 25)
	title_label.modulate = Color("bce7f2")
	mode_button = Button.new()
	mode_button.text = "Red blood cell mode"
	mode_button.position = Vector2(930, 18)
	mode_button.custom_minimum_size = Vector2(270, 38)
	mode_button.pressed.connect(toggle_mode)
	add_child(mode_button)
	var panel := PanelContainer.new()
	panel.position = Vector2(55, 585)
	panel.custom_minimum_size = Vector2(1170, 195)
	add_child(panel)
	var inner := VBoxContainer.new()
	panel.add_child(inner)
	var heading := Label.new()
	heading.text = "Outside solution setting (compared with the starting cell)"
	inner.add_child(heading)
	slider = HSlider.new()
	slider.min_value = -5
	slider.max_value = 5
	slider.step = 1
	slider.value = 0
	slider.custom_minimum_size = Vector2(1080, 32)
	inner.add_child(slider)
	var markers := Label.new()
	markers.text = "Distilled water / lower solute                         Plasma / starting match                         Seawater / higher solute     → Saturated salt: off scale"
	markers.add_theme_font_size_override("font_size", 13)
	markers.tooltip_text = "Examples, not measurements of this model. Distilled water has essentially no solute; blood plasma contains many solutes; seawater averages about 35 parts per thousand dissolved salts. Saturation is the maximum NaCl dissolvable at a specified temperature and is beyond this scale."
	inner.add_child(markers)
	setting_label = Label.new()
	inner.add_child(setting_label)
	live_label = Label.new()
	inner.add_child(live_label)
	explanation = Label.new()
	inner.add_child(explanation)
	var controls := HBoxContainer.new()
	controls.position = Vector2(75, 524)
	controls.add_theme_constant_override("separation", 16)
	add_child(controls)
	pause_button = Button.new()
	pause_button.text = "Pause"
	controls.add_child(pause_button)
	var reset_button := Button.new()
	reset_button.text = "Reset"
	controls.add_child(reset_button)
	neutral_button = Button.new()
	neutral_button.text = "Show Neutral size"
	controls.add_child(neutral_button)
	neutral_label = label_at("", Vector2(700, 528), 16)
	flow_label = label_at("", Vector2(78, 95), 19)
	size_label = label_at("", Vector2(78, 125), 16)
	legend_label = label_at("● Water      ■ Solute     • Organelles are decorative", Vector2(800, 95), 16)
	label_at("Relative concentration (model units)", Vector2(860, 132), 16)
	inside_bar = make_bar(Vector2(860, 164))
	outside_bar = make_bar(Vector2(860, 210))
	field.reset()
	simulation = OsmosisSimulation.new()
	simulation.profile = load("res://resources/animal_cell.tres")
	red_cells.profile = simulation.profile
	add_child(simulation)
	slider_changed.connect(simulation.set_external_setting)
	simulation.state_updated.connect(cell.update_state)
	simulation.state_updated.connect(field.update_state)
	simulation.state_updated.connect(update_readouts)
	slider.value_changed.connect(func(value: float) -> void: slider_changed.emit(int(value)))
	pause_button.pressed.connect(toggle_pause)
	reset_button.pressed.connect(reset_all)
	neutral_button.pressed.connect(toggle_neutral_size)
	red_cells.population_updated.connect(update_red_cell_readouts)
	red_cells.reset()
	simulation.publish()

func label_at(value: String, at: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label

func make_bar(at: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = at
	bar.custom_minimum_size = Vector2(330, 27)
	bar.min_value = 0
	bar.max_value = 1.6
	bar.show_percentage = false
	add_child(bar)
	return bar

func update_readouts(radius: float, flow: float, inside: float, outside: float) -> void:
	setting_label.text = "Setting: %+d  •  %s compared with the starting cell" % [simulation.setting, "lower solute" if simulation.setting < 0 else ("higher solute" if simulation.setting > 0 else "starting match")]
	if red_cell_mode:
		red_cells.outside = outside
		red_cells.publish()
		red_cells.queue_redraw()
		return
	inside_bar.visible = true
	var gap := inside - outside
	var state := "balanced" if absf(gap) < simulation.profile.balanced_tolerance else ("hypotonic" if gap > 0.0 else "hypertonic")
	live_label.text = "Right now: outside %s relative to the current cell" % state
	flow_label.text = "Net water movement: %s" % ("balanced" if state == "balanced" else ("into the cell" if flow > 0.0 or gap > 0.0 else "out of the cell"))
	size_label.text = "Cell size: %d%% of starting radius" % roundi(radius / simulation.profile.initial_radius * 100.0)
	explanation.text = "The outside setting stayed the same; water changed the inside concentration." if simulation.setting != 0 and state == "balanced" else "Water crosses in both directions. The concentration difference changes the net direction."
	if simulation.water >= simulation.profile.max_water and gap > simulation.profile.balanced_tolerance:
		flow_label.text = "Size limit reached (outside still hypotonic)"
		explanation.text = "The model stops swelling at its display limit; the concentrations are not balanced."
	inside_bar.value = inside
	outside_bar.value = outside
	inside_bar.tooltip_text = "Inside: %.2f relative model units" % inside
	outside_bar.tooltip_text = "Outside: %.2f relative model units" % outside

func toggle_pause() -> void:
	simulation.set_paused(not simulation.paused)
	field.set_stopped(simulation.paused or red_cell_mode)
	red_cells.paused = simulation.paused
	pause_button.text = "Play" if simulation.paused else "Pause"

func reset_all() -> void:
	slider.value = 0
	simulation.reset()
	field.reset()
	field.set_stopped(red_cell_mode)
	red_cells.reset()
	pause_button.text = "Pause"
	neutral_visible = false
	cell.set_neutral_size(0.0, false)
	neutral_button.text = "Show Neutral size"
	neutral_label.text = ""

func toggle_neutral_size() -> void:
	neutral_visible = not neutral_visible
	# Keep the starting size fixed so swelling and shrinking share a neutral reference.
	cell.set_neutral_size(simulation.profile.initial_radius, neutral_visible)
	red_cells.show_neutral = neutral_visible
	red_cells.queue_redraw()
	neutral_button.text = "Hide Neutral size" if neutral_visible else "Show Neutral size"
	neutral_label.text = "Gold outline: neutral cell size (setting 0)" if neutral_visible else ""

func toggle_mode() -> void:
	red_cell_mode = not red_cell_mode
	red_cells.active = red_cell_mode
	red_cells.visible = red_cell_mode
	cell.visible = not red_cell_mode
	field.visible = not red_cell_mode
	simulation.set_physics_process(not red_cell_mode)
	mode_button.text = "Single-cell mode" if red_cell_mode else "Red blood cell mode"
	title_label.text = "OSMOSIS LAB  •  Red blood cells" if red_cell_mode else "OSMOSIS LAB  •  Animal cell"
	legend_label.text = "● Water      ■ Solute     • Red blood cells" if red_cell_mode else "● Water      ■ Solute     • Organelles are decorative"
	reset_all()

func update_red_cell_readouts(alive: int, mean_size: float, mean_inside: float) -> void:
	if not red_cell_mode:
		return
	outside_bar.value = red_cells.outside
	outside_bar.tooltip_text = "Outside: %.2f relative model units" % red_cells.outside
	inside_bar.visible = alive > 0
	inside_bar.value = mean_inside
	inside_bar.tooltip_text = "Mean inside intact cells: %.2f relative model units" % mean_inside
	size_label.text = "Intact cells: %d / %d  •  Mean size: %d%%" % [alive, RedBloodCells.CELL_COUNT, roundi(mean_size * 100.0)]
	if alive == 0:
		live_label.text = "All red blood cells have burst (hemolysis). Press Reset for new cells."
		flow_label.text = "No intact cells remain"
		explanation.text = "Ruptured membranes cannot recover by changing the solution. Size and timing are illustrative."
		return
	var gap: float = mean_inside - red_cells.outside
	var state: String = "balanced" if absf(gap) < simulation.profile.balanced_tolerance else ("hypotonic" if gap > 0.0 else "hypertonic")
	live_label.text = "Right now: outside %s relative to the intact cells" % state
	flow_label.text = "Net water movement: %s" % ("balanced" if state == "balanced" else ("into cells" if gap > 0.0 else "out of cells"))
	explanation.text = "Hypotonic: swelling; sufficiently dilute: bursting. Hypertonic: shrinking. Size and timing are illustrative."
