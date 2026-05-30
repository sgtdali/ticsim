extends Control

signal closed

const RoadData := preload("res://scripts/systems/RoadData.gd")
const MAP_SIZE := Vector2(2688.0, 1536.0)
const MARKER_SIZE := Vector2(116.0, 34.0)

@onready var close_button: TextureButton = $CloseButton
@onready var map_viewport: Control = $RouteFrame/RouteRoot/Body/BodyMargin/BodyColumns/MapFrame/MapMargin/MapViewport
@onready var road_layer: Control = $RouteFrame/RouteRoot/Body/BodyMargin/BodyColumns/MapFrame/MapMargin/MapViewport/RoadLayer
@onready var marker_layer: Control = $RouteFrame/RouteRoot/Body/BodyMargin/BodyColumns/MapFrame/MapMargin/MapViewport/MarkerLayer

var _economy: Node
var _roads: Array[Dictionary] = []

func _ready() -> void:
	_economy = get_node_or_null("/root/EconomyManager")
	_roads = RoadData.load_roads()
	close_button.pressed.connect(_on_close_pressed)
	map_viewport.resized.connect(_layout_map_overlay)
	_build_roads()
	_build_city_markers()
	call_deferred("_layout_map_overlay")

func _on_close_pressed() -> void:
	closed.emit()
	queue_free()

func _build_city_markers() -> void:
	for child in marker_layer.get_children():
		child.queue_free()
	if _economy == null:
		return
	for town_name in _economy.towns.keys():
		var marker := Button.new()
		marker.name = "Town_%s" % str(town_name)
		marker.text = str(town_name)
		marker.custom_minimum_size = MARKER_SIZE
		marker.size = MARKER_SIZE
		marker.tooltip_text = "Route stop: %s" % str(town_name)
		marker_layer.add_child(marker)

func _build_roads() -> void:
	for child in road_layer.get_children():
		child.queue_free()
	for road_data in _roads:
		var road_name: String = str(road_data.get("id", "Road"))
		var shadow := Line2D.new()
		shadow.name = "RoadShadow_%s" % road_name
		shadow.width = 7.0
		shadow.default_color = Color(0.06, 0.04, 0.02, 0.55)
		shadow.begin_cap_mode = Line2D.LINE_CAP_ROUND
		shadow.end_cap_mode = Line2D.LINE_CAP_ROUND
		shadow.joint_mode = Line2D.LINE_JOINT_ROUND
		shadow.antialiased = true
		road_layer.add_child(shadow)

		var road := Line2D.new()
		road.name = "Road_%s" % road_name
		road.width = 3.0
		road.default_color = road_data.get("color", Color(0.55, 0.40, 0.20, 0.95))
		road.begin_cap_mode = Line2D.LINE_CAP_ROUND
		road.end_cap_mode = Line2D.LINE_CAP_ROUND
		road.joint_mode = Line2D.LINE_JOINT_ROUND
		road.antialiased = true
		road_layer.add_child(road)

func _layout_map_overlay() -> void:
	if _economy == null or marker_layer == null:
		return
	var image_rect := _get_map_image_rect()
	_layout_roads(image_rect)
	for town_name in _economy.towns.keys():
		var marker := marker_layer.get_node_or_null("Town_%s" % str(town_name)) as Control
		if marker == null:
			continue
		var town: Dictionary = _economy.get_town(str(town_name))
		var map_pos: Vector2 = town.get("position", Vector2.ZERO)
		var normalized := Vector2(map_pos.x / MAP_SIZE.x, map_pos.y / MAP_SIZE.y)
		var screen_pos := image_rect.position + normalized * image_rect.size
		marker.position = screen_pos - MARKER_SIZE * 0.5

func _layout_roads(image_rect: Rect2) -> void:
	for road_data in _roads:
		var road_name: String = str(road_data.get("id", "Road"))
		var source_points: PackedVector2Array = road_data.get("points", PackedVector2Array())
		var points: PackedVector2Array = RoadData.points_to_rect(source_points, MAP_SIZE, image_rect)
		points = RoadData.smooth_points(points, 10)
		var shadow := road_layer.get_node_or_null("RoadShadow_%s" % road_name) as Line2D
		if shadow:
			shadow.points = points
		var road := road_layer.get_node_or_null("Road_%s" % road_name) as Line2D
		if road:
			road.points = points

func _town_to_minimap_pos(town_name: String, image_rect: Rect2) -> Vector2:
	var town: Dictionary = _economy.get_town(town_name)
	var map_pos: Vector2 = town.get("position", Vector2.ZERO)
	return RoadData.points_to_rect(PackedVector2Array([map_pos]), MAP_SIZE, image_rect)[0]

func _get_map_image_rect() -> Rect2:
	var viewport_size := map_viewport.size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return Rect2(Vector2.ZERO, Vector2.ONE)
	var scale := minf(viewport_size.x / MAP_SIZE.x, viewport_size.y / MAP_SIZE.y)
	var image_size := MAP_SIZE * scale
	var image_offset := (viewport_size - image_size) * 0.5
	return Rect2(image_offset, image_size)
