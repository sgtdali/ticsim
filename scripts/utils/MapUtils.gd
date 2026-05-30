class_name MapUtils
extends RefCounted

static func clear_container(container: Container) -> void:
	for child in container.get_children():
		child.queue_free()

static func add_muted_label(parent: Container, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color(0.72, 0.66, 0.54))
	parent.add_child(label)
	return label

static func format_gold(value: float) -> String:
	return "%.1fg" % value

static func contract_status_color(status: String) -> Color:
	if status == "completed":
		return Color(0.45, 1.0, 0.35)
	if status == "failed":
		return Color(1.0, 0.35, 0.25)
	if status == "accepted":
		return Color(1.0, 0.82, 0.36)
	return Color(0.82, 0.65, 0.36)

static func catmull_rom_points(source: PackedVector2Array, steps_per_segment: int) -> PackedVector2Array:
	var smoothed := PackedVector2Array()
	for i in range(source.size() - 1):
		var p0 := source[maxi(i - 1, 0)]
		var p1 := source[i]
		var p2 := source[i + 1]
		var p3 := source[mini(i + 2, source.size() - 1)]
		for step in range(steps_per_segment):
			var t := float(step) / float(steps_per_segment)
			smoothed.append(catmull_rom_point(p0, p1, p2, p3, t))
	smoothed.append(source[source.size() - 1])
	return smoothed

static func catmull_rom_point(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
	)
