@tool
extends Node

const ROAD_DATA_PATH := "res://data/world_roads.json"

@export var export_roads_to_json := false:
	set(value):
		if value:
			export_roads_to_json = false
			_export_roads()

@export var import_roads_from_json := false:
	set(value):
		if value:
			import_roads_from_json = false
			_import_roads()

func _export_roads() -> void:
	var roads_node := get_parent()
	if roads_node == null:
		push_error("RoadDataExporter must be a child of the Roads node.")
		return

	var roads: Array = []
	for child in roads_node.get_children():
		var line := child as Line2D
		if line == null:
			continue
		if str(line.name).ends_with("Shadow"):
			continue

		var points: Array = []
		for point in line.points:
			points.append([roundf(point.x * 1000.0) / 1000.0, roundf(point.y * 1000.0) / 1000.0])

		roads.append({
			"id": str(line.name),
			"color": [
				line.default_color.r,
				line.default_color.g,
				line.default_color.b,
				line.default_color.a,
			],
			"points": points,
		})

	var file := FileAccess.open(ROAD_DATA_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not write %s" % ROAD_DATA_PATH)
		return
	file.store_string(JSON.stringify({"roads": roads}, "\t"))
	file.close()
	print("Exported %d road(s) to %s" % [roads.size(), ROAD_DATA_PATH])

func _import_roads() -> void:
	var roads_node := get_parent()
	if roads_node == null:
		push_error("RoadDataExporter must be a child of the Roads node.")
		return
	if not FileAccess.file_exists(ROAD_DATA_PATH):
		push_error("Missing %s" % ROAD_DATA_PATH)
		return

	for child in roads_node.get_children():
		if child is Line2D:
			child.queue_free()

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ROAD_DATA_PATH))
	if not parsed is Dictionary:
		push_error("Invalid road JSON.")
		return

	for entry in (parsed as Dictionary).get("roads", []):
		if not entry is Dictionary:
			continue
		var data := entry as Dictionary
		var line := Line2D.new()
		line.name = str(data.get("id", "Road"))
		line.width = 3.0
		line.default_color = _color_from_array(data.get("color", [0.55, 0.40, 0.20, 0.95]))
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.antialiased = true
		for raw_point in data.get("points", []):
			if raw_point is Array and raw_point.size() >= 2:
				line.add_point(Vector2(float(raw_point[0]), float(raw_point[1])))
		roads_node.add_child(line)
		line.owner = get_tree().edited_scene_root

	print("Imported road editor lines from %s" % ROAD_DATA_PATH)

func _color_from_array(value: Variant) -> Color:
	if not value is Array or value.size() < 4:
		return Color(0.55, 0.40, 0.20, 0.95)
	return Color(float(value[0]), float(value[1]), float(value[2]), float(value[3]))
