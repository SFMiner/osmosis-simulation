class_name ParticleField
extends Node2D

const CENTER := Vector2(640, 300)
const AREA := Rect2(75, 75, 1130, 485)
var rng := RandomNumberGenerator.new()
var particles: Array[Dictionary] = []
var radius: float = 155.0
var flow: float = 0.0
var inside: float = 1.0
var outside: float = 1.0
var stopped: bool = false
var inward_budget: float = 0.0
var outward_budget: float = 0.0

func _ready() -> void:
	rng.randomize()
	reset()

func reset() -> void:
	particles.clear()
	inward_budget = 0.0
	outward_budget = 0.0
	for side in 2:
		for i in 58:
			var is_inside := side == 0
			particles.append({"pos": random_position(is_inside), "inside": is_inside, "solute": i < 13, "angle": rng.randf_range(0.0, TAU), "cross": 0.0, "from": Vector2.ZERO, "to": Vector2.ZERO})
	update_outside_solute()
	queue_redraw()

func random_position(is_inside: bool) -> Vector2:
	for attempt in 200:
		var p := Vector2(rng.randf_range(AREA.position.x, AREA.end.x), rng.randf_range(AREA.position.y, AREA.end.y))
		if (p.distance_to(CENTER) < radius - 12.0) == is_inside:
			return p
	return CENTER + Vector2.RIGHT * (0.0 if is_inside else radius + 20.0)

func update_state(new_radius: float, new_flow: float, c_in: float, c_out: float) -> void:
	radius = new_radius
	flow = new_flow
	inside = c_in
	outside = c_out
	update_outside_solute()
	queue_redraw()

func update_outside_solute() -> void:
	# Change the reservoir mix without changing internal solute or crossing water.
	var desired: int = maxi(0, roundi(13.0 * outside))
	var current: int = 0
	for p: Dictionary in particles:
		if not p.inside and p.solute:
			current += 1
	for p: Dictionary in particles:
		if p.inside or p.cross > 0.0:
			continue
		if p.solute and current > desired:
			p.solute = false
			current -= 1
		elif not p.solute and current < desired:
			p.solute = true
			current += 1

func set_stopped(value: bool) -> void:
	stopped = value

func _process(delta: float) -> void:
	if stopped:
		return
	var step := minf(delta, 0.05)
	inward_budget += step * (1.5 + maxf(flow, 0.0) * 46.0)
	outward_budget += step * (1.5 + maxf(-flow, 0.0) * 46.0)
	for direction in 2:
		var budget := inward_budget if direction == 0 else outward_budget
		if budget >= 1.0:
			if start_crossing(direction == 0):
				budget -= 1.0
			else:
				budget = minf(budget, 2.0)
		if direction == 0:
			inward_budget = budget
		else:
			outward_budget = budget
	for i in particles.size():
		var p := particles[i]
		if p.cross > 0.0:
			p.cross = maxf(0.0, p.cross - step * 2.2)
			p.pos = p.from.lerp(p.to, 1.0 - p.cross)
			if p.cross <= 0.0:
				p.inside = not p.inside
				p.pos = p.to
		else:
			p.angle += rng.randf_range(-1.3, 1.3) * step
			var next: Vector2 = p.pos + Vector2.from_angle(p.angle) * step * 28.0
			if AREA.has_point(next) and ((next.distance_to(CENTER) < radius - 8.0) == p.inside):
				p.pos = next
			else:
				p.angle += PI
		particles[i] = p
	queue_redraw()

func start_crossing(inward: bool) -> bool:
	var best := -1
	var best_distance := 100000.0
	for i in particles.size():
		var p := particles[i]
		if p.solute or p.cross > 0.0 or p.inside == inward:
			continue
		var gap: float = absf(p.pos.distance_to(CENTER) - radius)
		if gap < best_distance:
			best_distance = gap
			best = i
	if best < 0 or best_distance > 42.0:
		return false
	var p := particles[best]
	var direction: Vector2 = (p.pos - CENTER).normalized()
	p.from = p.pos
	p.to = CENTER + direction * (radius - 20.0 if inward else radius + 20.0)
	p.cross = 1.0
	particles[best] = p
	return true

func _draw() -> void:
	for p in particles:
		var pos: Vector2 = p.pos
		if p.solute:
			draw_rect(Rect2(pos - Vector2(5, 5), Vector2(10, 10)), Color(1.0, 0.70, 0.32))
		else:
			draw_circle(pos, 4.0, Color(0.40, 0.84, 1.0))
