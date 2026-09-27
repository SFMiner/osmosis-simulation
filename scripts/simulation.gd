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
	var target := profile.solute_amount / outside
	flow = clampf(profile.transport_rate * (inside - outside), -profile.max_flow, profile.max_flow)
	var next := clampf(water + flow * minf(delta, 0.05), profile.min_water, profile.max_water)
	if (water - target) * (next - target) <= 0.0:
		next = target
	water = next
	if absf(profile.solute_amount / water - outside) < profile.balanced_tolerance:
		flow = 0.0
	publish()

func outside_concentration() -> float:
	return (profile.solute_amount / profile.initial_water) * (1.0 + profile.concentration_step * setting)

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
	state_updated.emit(profile.initial_radius * pow(water / profile.initial_water, 1.0 / 3.0), flow, profile.solute_amount / water, outside_concentration())
