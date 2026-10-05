class_name CellView
extends Node2D

var radius: float = 155.0
var neutral_radius: float = 0.0
var show_neutral: bool = false

func update_state(new_radius: float, _flow: float, _inside: float, _outside: float) -> void:
	radius = new_radius
	queue_redraw()

func set_neutral_size(value: float, visible: bool) -> void:
	neutral_radius = value
	show_neutral = visible
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.26, 0.72, 0.82, 0.16))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 96, Color(0.29, 0.84, 0.90), 7.0, true)
	# Draw the reference over the membrane so it stays visible at neutral size.
	if show_neutral:
		draw_arc(Vector2.ZERO, neutral_radius, 0, TAU, 96, Color(1.0, 0.79, 0.32, 0.75), 3.0, true)
	# Decorative organelles: no effect on simulation.
	draw_circle(Vector2(-27, -12) * radius / 155.0, radius * 0.21, Color(0.54, 0.43, 0.77, 0.8))
	for i in 5:
		var angle := i * TAU / 5.0 + 0.4
		var pos := Vector2(cos(angle), sin(angle)) * radius * 0.57
		draw_ellipse_shape(pos, radius * 0.11, radius * 0.045, angle)

func draw_ellipse_shape(center: Vector2, a: float, b: float, rotation_angle: float) -> void:
	var points := PackedVector2Array()
	for j in 17:
		var t := TAU * j / 16.0
		points.append(center + Vector2(a * cos(t), b * sin(t)).rotated(rotation_angle))
	draw_polyline(points, Color(0.94, 0.59, 0.49, 0.9), 3.0, true)
