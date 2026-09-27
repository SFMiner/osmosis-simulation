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
var target_label: Label
var pause_button: Button
var challenge_button: Button
var target_radius: float = 0.0
var target_elapsed: float = 0.0
var challenge_active: bool = false
var challenge_complete: bool = false
var current_radius: float = 155.0

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
	var title := label_at("OSMOSIS LAB  •  Animal cell", Vector2(75, 18), 25)
	title.modulate = Color("bce7f2")
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
	challenge_button = Button.new()
	challenge_button.text = "Show target size"
	controls.add_child(challenge_button)
	target_label = label_at("", Vector2(700, 528), 16)
	flow_label = label_at("", Vector2(78, 95), 19)
	size_label = label_at("", Vector2(78, 125), 16)
	label_at("● Water      ■ Solute     • Organelles are decorative", Vector2(800, 95), 16)
	label_at("Relative concentration (model units)", Vector2(860, 132), 16)
	inside_bar = make_bar(Vector2(860, 164))
	outside_bar = make_bar(Vector2(860, 210))
	field.reset()
	simulation = OsmosisSimulation.new()
	simulation.profile = load("res://resources/animal_cell.tres")
	add_child(simulation)
	slider_changed.connect(simulation.set_external_setting)
	simulation.state_updated.connect(cell.update_state)
	simulation.state_updated.connect(field.update_state)
	simulation.state_updated.connect(update_readouts)
	slider.value_changed.connect(func(value: float) -> void: slider_changed.emit(int(value)))
	pause_button.pressed.connect(toggle_pause)
	reset_button.pressed.connect(reset_all)
	challenge_button.pressed.connect(toggle_challenge)
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
	current_radius = radius
	setting_label.text = "Setting: %+d  •  %s compared with the starting cell" % [simulation.setting, "lower solute" if simulation.setting < 0 else ("higher solute" if simulation.setting > 0 else "starting match")]
	var gap := inside - outside
	var state := "balanced" if absf(gap) < simulation.profile.balanced_tolerance else ("hypotonic" if gap > 0.0 else "hypertonic")
	live_label.text = "Right now: outside %s relative to the current cell" % state
	flow_label.text = "Net water movement: %s" % ("balanced" if state == "balanced" else ("into the cell" if flow > 0.0 or gap > 0.0 else "out of the cell"))
	size_label.text = "Cell size: %d%% of starting radius" % roundi(radius / simulation.profile.initial_radius * 100.0)
	explanation.text = "The outside setting stayed the same; water changed the inside concentration." if simulation.setting != 0 and state == "balanced" else "Water crosses in both directions. The concentration difference changes the net direction."
	inside_bar.value = inside
	outside_bar.value = outside
	inside_bar.tooltip_text = "Inside: %.2f relative model units" % inside
	outside_bar.tooltip_text = "Outside: %.2f relative model units" % outside

func _process(delta: float) -> void:
	if not challenge_active or challenge_complete or simulation.paused:
		return
	if absf(current_radius - target_radius) <= target_radius * 0.02:
		target_elapsed += delta
		if target_elapsed >= 1.0:
			challenge_complete = true
			target_label.text = "Target matched! Keep experimenting."
	else:
		target_elapsed = 0.0
		target_label.text = "Match the gold outline: difference %d px" % roundi(absf(current_radius - target_radius))

func toggle_pause() -> void:
	simulation.set_paused(not simulation.paused)
	field.set_stopped(simulation.paused)
	pause_button.text = "Play" if simulation.paused else "Pause"

func reset_all() -> void:
	slider.value = 0
	simulation.reset()
	field.reset()
	field.set_stopped(false)
	pause_button.text = "Pause"
	challenge_active = false
	challenge_complete = false
	target_elapsed = 0.0
	cell.set_target(0.0, false)
	challenge_button.text = "Show target size"
	target_label.text = ""

func toggle_challenge() -> void:
	challenge_active = not challenge_active
	challenge_complete = false
	target_elapsed = 0.0
	# A shrinking target reachable at a sufficiently hypertonic setting.
	target_radius = simulation.profile.initial_radius * pow(1.0 / 1.24, 1.0 / 3.0)
	cell.set_target(target_radius, challenge_active)
	challenge_button.text = "Hide target size" if challenge_active else "Show target size"
	target_label.text = "Match the gold outline" if challenge_active else ""
