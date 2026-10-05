class_name RedBloodCells
extends Node2D

signal population_updated(alive: int, mean_size: float, mean_inside: float)

const CELL_COUNT: int = 16
const FADE_SECONDS: float = 1.6
const AREA: Rect2 = Rect2(90, 255, 1100, 250)
var profile: CellProfile
var cells: Array[Dictionary] = []
var active: bool = false
var paused: bool = false
var outside: float = 1.0
var show_neutral: bool = false
var clock_time: float = 0.0

func reset() -> void:
	cells.clear()
	clock_time = 0.0
	paused = false
	show_neutral = false
	for i: int in CELL_COUNT:
		# Small illustrative variations prevent every membrane rupturing at once.
		cells.append({"origin": Vector2(160 + (i % 8) * 137, 322 + (i / 8) * 112),
			"water": 1.0, "radius": 25.0 + float(i % 4) * 1.5,
			"rate": 0.26 + float(i % 5) * 0.025,
			"rupture": 1.55 + float(i % 6) * 0.03,
			"burst": false, "fade": 0.0, "phase": float(i) * 2.4})
	publish()
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not active or paused:
		return
	var step: float = minf(delta, 0.05)
	clock_time += step
	for cell_data: Dictionary in cells:
		if cell_data.burst:
			cell_data.fade = minf(FADE_SECONDS, cell_data.fade + step)
			continue
		var water: float = cell_data.water
		var flow: float = clampf(cell_data.rate * (1.0 / water - outside), -profile.max_flow, profile.max_flow)
		var next_water: float = maxf(profile.min_water, water + flow * step)
		if outside > 0.0:
			var equilibrium: float = 1.0 / outside
			if (water - equilibrium) * (next_water - equilibrium) <= 0.0:
				next_water = equilibrium
		cell_data.water = next_water
		# Rupture replaces the single-cell mode's display cap; it cannot be reversed.
		if next_water >= cell_data.rupture:
			cell_data.burst = true
	publish()
	queue_redraw()

func size_ratio(water: float) -> float:
	return 1.0 + profile.size_change_scale * (pow(water, 1.0 / 3.0) - 1.0)

func publish() -> void:
	var alive: int = 0
	var sizes: float = 0.0
	var concentrations: float = 0.0
	for cell_data: Dictionary in cells:
		if not cell_data.burst:
			alive += 1
			sizes += size_ratio(cell_data.water)
			concentrations += 1.0 / cell_data.water
	population_updated.emit(alive, sizes / maxi(alive, 1), concentrations / maxi(alive, 1))

func cell_position(cell_data: Dictionary) -> Vector2:
	return cell_data.origin + Vector2(sin(clock_time * 0.32 + cell_data.phase) * 18.0, cos(clock_time * 0.42 + cell_data.phase) * 12.0)

func _draw() -> void:
	if profile == null:
		return
	# Reservoir particles illustrate the chosen solution, not molecules to scale.
	for i: int in 95:
		var point: Vector2 = AREA.position + Vector2(fposmod(i * 79.0 + clock_time * 3.0, AREA.size.x), fposmod(i * 43.0, AREA.size.y))
		var covered: bool = false
		for cell_data: Dictionary in cells:
			if not cell_data.burst and point.distance_to(cell_position(cell_data)) < cell_data.radius * size_ratio(cell_data.water) + 6.0:
				covered = true
				break
		if covered:
			continue
		if i < roundi(20.0 * outside):
			draw_rect(Rect2(point - Vector2(3, 3), Vector2(6, 6)), Color(1.0, 0.70, 0.32, 0.65))
		else:
			draw_circle(point, 2.0, Color(0.40, 0.84, 1.0, 0.35))
	for cell_data: Dictionary in cells:
		var center: Vector2 = cell_position(cell_data)
		var radius: float = cell_data.radius * size_ratio(cell_data.water)
		if cell_data.burst:
			var progress: float = cell_data.fade / FADE_SECONDS
			if progress >= 1.0:
				continue
			for segment: int in 8:
				var angle: float = float(segment) * TAU / 8.0
				var offset: Vector2 = Vector2.from_angle(angle) * progress * 20.0
				draw_arc(center + offset, radius, angle, angle + 0.42, 8, Color(0.95, 0.30, 0.38, 1.0 - progress), 3.0, true)
			draw_circle(center, radius * (1.0 + progress * 0.5), Color(0.85, 0.18, 0.28, (1.0 - progress) * 0.18))
			continue
		var outline: PackedVector2Array = PackedVector2Array()
		var shrink: float = clampf((1.0 - cell_data.water) * 2.0, 0.0, 0.65)
		for vertex: int in 65:
			var angle: float = TAU * float(vertex) / 64.0
			var edge: float = radius * (1.0 + shrink * 0.14 * cos(angle * 12.0))
			var roundness: float = 0.82 + 0.18 * clampf((cell_data.water - 1.0) / 0.55, 0.0, 1.0)
			outline.append(center + Vector2(cos(angle), sin(angle) * roundness) * edge)
		draw_colored_polygon(outline, Color("bb344b"))
		draw_polyline(outline, Color("f87683"), 2.0, true)
		# Pale centers suggest biconcavity; swelling progressively rounds it out.
		var pallor: float = clampf(0.46 - (cell_data.water - 1.0) * 0.55, 0.08, 0.52)
		draw_circle(center, radius * pallor, Color("e98790"))
		if show_neutral:
			draw_set_transform(center, 0.0, Vector2(1.0, 0.82))
			draw_arc(Vector2.ZERO, cell_data.radius, 0.0, TAU, 48, Color(1.0, 0.79, 0.32, 0.8), 1.5, true)
			draw_set_transform(Vector2.ZERO)
