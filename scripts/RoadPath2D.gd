@tool
extends Path2D

@export var road_width: float = 3.0:
	set(value):
		road_width = value
		_update_preview()

@export var road_color: Color = Color(0.52, 0.388, 0.212, 0.68):
	set(value):
		road_color = value
		_update_preview()

@export var shadow_width: float = 7.0:
	set(value):
		shadow_width = value
		_update_preview()

@export var shadow_color: Color = Color(0.105882, 0.0745098, 0.0392157, 0.22):
	set(value):
		shadow_color = value
		_update_preview()

@export var bake_interval: float = 16.0:
	set(value):
		bake_interval = maxf(value, 2.0)
		_update_preview()

var _shadow_line: Line2D
var _road_line: Line2D

func _ready() -> void:
	_ensure_preview_lines()
	_update_preview()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_preview()

func _ensure_preview_lines() -> void:
	_shadow_line = get_node_or_null("Shadow") as Line2D
	if _shadow_line == null:
		_shadow_line = Line2D.new()
		_shadow_line.name = "Shadow"
		add_child(_shadow_line)
		_shadow_line.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else owner

	_road_line = get_node_or_null("Road") as Line2D
	if _road_line == null:
		_road_line = Line2D.new()
		_road_line.name = "Road"
		add_child(_road_line)
		_road_line.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else owner

func _update_preview() -> void:
	if not is_inside_tree():
		return
	_ensure_preview_lines()
	if curve == null:
		_shadow_line.points = PackedVector2Array()
		_road_line.points = PackedVector2Array()
		return

	curve.bake_interval = bake_interval
	var baked_points := curve.get_baked_points()
	_apply_line_style(_shadow_line, baked_points, shadow_width, shadow_color)
	_apply_line_style(_road_line, baked_points, road_width, road_color)

func _apply_line_style(line: Line2D, baked_points: PackedVector2Array, width: float, color: Color) -> void:
	line.points = baked_points
	line.width = width
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.antialiased = true
