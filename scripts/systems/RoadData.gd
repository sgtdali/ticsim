extends RefCounted
class_name RoadData

const ROAD_DATA_PATH := "res://data/world_roads.json"

static func load_roads() -> Array[Dictionary]:
	if not FileAccess.file_exists(ROAD_DATA_PATH):
		return []
	var text := FileAccess.get_file_as_string(ROAD_DATA_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		return []

	var roads: Array[Dictionary] = []
	for entry in (parsed as Dictionary).get("roads", []):
		if not entry is Dictionary:
			continue
		var data := entry as Dictionary
		var points := PackedVector2Array()
		for raw_point in data.get("points", []):
			if raw_point is Array and raw_point.size() >= 2:
				points.append(Vector2(float(raw_point[0]), float(raw_point[1])))
		if points.size() < 2:
			continue
		roads.append({
			"id": str(data.get("id", "Road%d" % roads.size())),
			"points": points,
			"color": _color_from_array(data.get("color", [0.55, 0.40, 0.20, 0.95])),
		})
	return roads

static func points_to_rect(points: PackedVector2Array, map_size: Vector2, target_rect: Rect2) -> PackedVector2Array:
	var transformed := PackedVector2Array()
	for point in points:
		var normalized := Vector2(point.x / map_size.x, point.y / map_size.y)
		transformed.append(target_rect.position + normalized * target_rect.size)
	return transformed

static func smooth_points(source: PackedVector2Array, steps_per_segment: int) -> PackedVector2Array:
	if source.size() < 3:
		return source
	var smoothed := PackedVector2Array()
	for i in range(source.size() - 1):
		var p0 := source[maxi(i - 1, 0)]
		var p1 := source[i]
		var p2 := source[i + 1]
		var p3 := source[mini(i + 2, source.size() - 1)]
		for step in range(steps_per_segment):
			var t := float(step) / float(steps_per_segment)
			smoothed.append(_catmull_rom_point(p0, p1, p2, p3, t))
	smoothed.append(source[source.size() - 1])
	return smoothed

static func _catmull_rom_point(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * (
		(2.0 * p1)
		+ (-p0 + p2) * t
		+ (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2
		+ (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
	)

static func _color_from_array(value: Variant) -> Color:
	if not value is Array or value.size() < 4:
		return Color(0.55, 0.40, 0.20, 0.95)
	return Color(float(value[0]), float(value[1]), float(value[2]), float(value[3]))
