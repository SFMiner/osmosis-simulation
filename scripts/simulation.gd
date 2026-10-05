class_name OsmosisSimulation
extends Node

signal state_updated(radius: float, flow: float, inside: float, outside: float)

@export var profile: CellProfile
var setting: int = 0
var water: float = 1.0
var paused: bool = false
var flow: float = 0.0

func _ready() -> void:
	reset()

func _physics_process(delta: float) -> void:
	if paused:
		return
	var outside := outside_concentration()
	var inside := profile.solute_amount / water
	# Solute-free water has no finite equilibrium; retain the display safety bound.
	var target: float = clampf(profile.solute_amount / outside, profile.min_water, profile.max_water) if outside > 0.0 else profile.max_water
	flow = clampf(profile.transport_rate * (inside - outside), -profile.max_flow, profile.max_flow)
	var next := clampf(water + flow * minf(delta, 0.05), profile.min_water, profile.max_water)
	if (water - target) * (next - target) <= 0.0:
		next = target
	water = next
	if absf(profile.solute_amount / water - outside) < profile.balanced_tolerance:
		flow = 0.0
	publish()

func outside_concentration() -> float:
	# The dilute half reaches pure water while zero remains the starting match.
	var relative_concentration: float = 1.0 + (float(setting) / 5.0 if setting < 0 else profile.concentration_step * setting)
	return (profile.solute_amount / profile.initial_water) * relative_concentration

func set_external_setting(value: int) -> void:
	setting = clampi(value, -5, 5)
	publish()

func set_paused(value: bool) -> void:
	paused = value
	publish()

func reset() -> void:
	setting = 0
	water = profile.initial_water
	flow = 0.0
	paused = false
	publish()

func publish() -> void:
	# Exaggerate the departure from neutral so both directions are easier to compare.
	var radius_ratio: float = 1.0 + profile.size_change_scale * (pow(water / profile.initial_water, 1.0 / 3.0) - 1.0)
	state_updated.emit(profile.initial_radius * radius_ratio, flow, profile.solute_amount / water, outside_concentration())
