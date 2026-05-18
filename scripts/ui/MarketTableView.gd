@tool
extends VBoxContainer
class_name MarketTableView

signal row_selected(item_id: String)

const TABLE_BG := Color(0.086, 0.083, 0.072)
const TABLE_HEADER := Color(0.710, 0.665, 0.555)
const TABLE_SELECTED := Color(0.315, 0.225, 0.122)
const SEPARATOR_DARK := Color(0.110, 0.080, 0.046)
const SEPARATOR_HIGHLIGHT := Color(0.64, 0.43, 0.17, 0.18)
const OUTER_BORDER_DARK := Color(0.040, 0.026, 0.014)
const INNER_BORDER_BRASS := Color(0.50, 0.34, 0.14, 0.68)
const TABLE_TEXT := Color(0.858, 0.788, 0.560)
const DATA_ROW_HEIGHT := 80.0
const HEADER_ROW_HEIGHT := 50.0
const ROW_FONT_SIZE := 23
const HEADER_FONT_SIZE := 21
const ROW_TEXT_COLOR := Color(0.858, 0.788, 0.560)
const SELECTED_TEXT_COLOR := Color(0.925, 0.840, 0.600)
const HEADER_TEXT_COLOR := Color(0.10, 0.07, 0.04)
const TEXT_OUTLINE_COLOR := Color(0.062745, 0.043137, 0.023529)
const HEADER_OUTLINE_COLOR := Color(0.62, 0.52, 0.35, 0.60)
const TEXT_SHADOW_COLOR := Color(0.0, 0.0, 0.0, 0.72)
const HEADER_SHADOW_COLOR := Color(1.0, 0.86, 0.52, 0.16)
const TEXT_SHADOW_OFFSET := Vector2(1.5, 1.5)
const MUTED_TREND_GREEN := Color(0.560784, 0.682353, 0.333333)
const MUTED_TREND_RED := Color(0.65098, 0.352941, 0.227451)
const MUTED_TREND_GOLD := Color(0.701961, 0.541176, 0.243137)
const FIRST_COLUMN_LEFT_PADDING := 14
const CELL_HORIZONTAL_PADDING := 10
const ITEM_ICON_SIZE := 40
const ITEM_ICON_TEXT_GAP := 10

const COLUMNS := [
	{"title": "Good", "key": "good", "width": 190, "align": HORIZONTAL_ALIGNMENT_LEFT},
	{"title": "Trend", "key": "trend", "width": 78, "align": HORIZONTAL_ALIGNMENT_CENTER},
	{"title": "City Stock", "key": "city_stock", "width": 108, "align": HORIZONTAL_ALIGNMENT_CENTER},
	{"title": "Cargo", "key": "cargo", "width": 78, "align": HORIZONTAL_ALIGNMENT_CENTER},
	{"title": "Ref", "key": "ref", "width": 78, "align": HORIZONTAL_ALIGNMENT_CENTER},
	{"title": "Buy", "key": "buy", "width": 78, "align": HORIZONTAL_ALIGNMENT_CENTER},
	{"title": "Sell", "key": "sell", "width": 78, "align": HORIZONTAL_ALIGNMENT_CENTER},
]

@export var table_noise_material: ShaderMaterial = preload("res://assets/ui/table_noise_material.tres"):
	set(value):
		table_noise_material = value
		_apply_noise_material_to_backgrounds()

@export var header_noise_material: ShaderMaterial = preload("res://assets/ui/table_header_noise_material.tres"):
	set(value):
		header_noise_material = value
		_apply_noise_material_to_backgrounds()

@export var selected_noise_material: ShaderMaterial = preload("res://assets/ui/table_selected_noise_material.tres"):
	set(value):
		selected_noise_material = value
		_apply_noise_material_to_backgrounds()

@export var selected_border_material: ShaderMaterial = preload("res://assets/ui/selected_row_border_material.tres"):
	set(value):
		selected_border_material = value
		_refresh_selected_borders()

var _rows: Array[Dictionary] = []
var _selected_id := ""
var _header_label_settings: LabelSettings
var _row_label_settings: LabelSettings
var _selected_row_label_settings: LabelSettings

func _ready() -> void:
	add_theme_constant_override("separation", 0)
	_ensure_label_settings()
	if Engine.is_editor_hint() and _rows.is_empty():
		set_rows(_get_preview_rows(), "bread")
	queue_redraw()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	if _rows.is_empty():
		set_rows(_get_preview_rows(), "bread")
		return
	_ensure_selected_preview_border()

func set_rows(rows: Array[Dictionary], selected_id: String) -> void:
	_rows = rows
	_selected_id = selected_id
	_rebuild()

func _rebuild() -> void:
	_ensure_label_settings()
	for child in get_children():
		child.queue_free()

	_add_header()
	for row_data in _rows:
		_add_row(row_data)
	queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	draw_rect(Rect2(Vector2.ZERO, size), OUTER_BORDER_DARK, false, 3.0)
	draw_rect(Rect2(Vector2(3, 3), size - Vector2(6, 6)), INNER_BORDER_BRASS, false, 1.0)

func _add_header() -> void:
	var row := _make_table_row(TABLE_HEADER, HEADER_ROW_HEIGHT)
	add_child(row)
	for column in COLUMNS:
		_add_table_cell(
			row,
			str(column["title"]),
			int(column["width"]),
			int(column["align"]),
			true,
			HEADER_TEXT_COLOR,
			false,
			str(column["key"])
		)

func _add_row(row_data: Dictionary) -> void:
	var item_id := str(row_data.get("id", ""))
	var is_selected := item_id == _selected_id
	var row := _make_table_row(TABLE_SELECTED if is_selected else TABLE_BG, DATA_ROW_HEIGHT)
	if is_selected:
		_add_selected_border(row)
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.gui_input.connect(_on_row_input.bind(item_id))
	add_child(row)

	for column in COLUMNS:
		var key := str(column["key"])
		var color_key := "%s_color" % key
		var cell_color: Color = TABLE_TEXT
		if row_data.has(color_key):
			cell_color = row_data[color_key]
		_add_table_cell(
			row,
			str(row_data.get(key, "")),
			int(column["width"]),
			int(column["align"]),
			false,
			cell_color,
			is_selected,
			key,
			str(row_data.get("icon_path", ""))
		)

func _make_table_row(bg_color: Color, height: float) -> Control:
	var row := Control.new()
	row.custom_minimum_size.y = height
	row.clip_contents = true

	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = bg_color
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bg_color == TABLE_HEADER and header_noise_material != null:
		bg.material = header_noise_material if Engine.is_editor_hint() else header_noise_material.duplicate()
	elif bg_color == TABLE_BG and table_noise_material != null:
		bg.material = table_noise_material if Engine.is_editor_hint() else table_noise_material.duplicate()
	elif bg_color == TABLE_SELECTED and selected_noise_material != null:
		bg.material = selected_noise_material if Engine.is_editor_hint() else selected_noise_material.duplicate()
	row.add_child(bg)

	var hbox := HBoxContainer.new()
	hbox.name = "Cells"
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	row.add_child(hbox)

	_add_border(row, "TopLineDark", SEPARATOR_DARK, 0.0, 0.0, 1.0, 0.0, Vector2(0, 0), Vector2(0, 1))
	_add_border(row, "TopLineHighlight", SEPARATOR_HIGHLIGHT, 0.0, 0.0, 1.0, 0.0, Vector2(0, 1), Vector2(0, 2))
	_add_border(row, "BottomLineShade", Color(0.0, 0.0, 0.0, 0.24), 0.0, 1.0, 1.0, 1.0, Vector2(0, -1), Vector2(0, 0))
	_add_border(row, "LeftLine", SEPARATOR_DARK, 0.0, 0.0, 0.0, 1.0, Vector2(0, 0), Vector2(1, 0))
	_add_border(row, "RightLine", SEPARATOR_DARK, 1.0, 0.0, 1.0, 1.0, Vector2(-1, 0), Vector2(0, 0))
	return row

func _add_border(parent: Control, node_name: String, color: Color, left: float, top: float, right: float, bottom: float, offset_start: Vector2, offset_end: Vector2) -> void:
	var line := ColorRect.new()
	line.name = node_name
	line.color = color
	line.anchor_left = left
	line.anchor_top = top
	line.anchor_right = right
	line.anchor_bottom = bottom
	line.offset_left = offset_start.x
	line.offset_top = offset_start.y
	line.offset_right = offset_end.x
	line.offset_bottom = offset_end.y
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(line)

func _add_selected_border(row: Control) -> void:
	_clear_selected_border(row)
	var overlay := Control.new()
	overlay.name = "SelectedBorder"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_child(overlay)

	_add_selected_border_rect(overlay, "Top", 0, 0.0, 0.0, 1.0, 0.0, 0, 0, 0, 3)
	_add_selected_border_rect(overlay, "Bottom", 1, 0.0, 1.0, 1.0, 1.0, 0, -3, 0, 0)
	_add_selected_border_rect(overlay, "Left", 2, 0.0, 0.0, 0.0, 1.0, 0, 0, 3, 0)
	_add_selected_border_rect(overlay, "Right", 3, 1.0, 0.0, 1.0, 1.0, -3, 0, 0, 0)
	_add_selected_highlight_line(overlay, "SelectedTopGlow", 0.0, 0.0, 1.0, 0.0, 3, 3, -3, 4, Color(0.84, 0.56, 0.24, 0.26))
	_add_selected_highlight_line(overlay, "SelectedBottomShade", 0.0, 1.0, 1.0, 1.0, 3, -4, -3, -3, Color(0.055, 0.030, 0.014, 0.48))

func _clear_selected_border(row: Control) -> void:
	for child in row.get_children():
		if str(child.name).begins_with("Selected"):
			child.queue_free()

func _add_selected_border_rect(parent: Control, node_name: String, edge_side: int, anchor_left: float, anchor_top: float, anchor_right: float, anchor_bottom: float, offset_left: float, offset_top: float, offset_right: float, offset_bottom: float) -> void:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.color = Color.WHITE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if selected_border_material != null:
		var material := selected_border_material.duplicate() as ShaderMaterial
		material.set_shader_parameter("edge_side", edge_side)
		rect.material = material
	rect.anchor_left = anchor_left
	rect.anchor_top = anchor_top
	rect.anchor_right = anchor_right
	rect.anchor_bottom = anchor_bottom
	rect.offset_left = offset_left
	rect.offset_top = offset_top
	rect.offset_right = offset_right
	rect.offset_bottom = offset_bottom
	parent.add_child(rect)

func _add_selected_highlight_line(parent: Control, node_name: String, anchor_left: float, anchor_top: float, anchor_right: float, anchor_bottom: float, offset_left: float, offset_top: float, offset_right: float, offset_bottom: float, color: Color) -> void:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.anchor_left = anchor_left
	rect.anchor_top = anchor_top
	rect.anchor_right = anchor_right
	rect.anchor_bottom = anchor_bottom
	rect.offset_left = offset_left
	rect.offset_top = offset_top
	rect.offset_right = offset_right
	rect.offset_bottom = offset_bottom
	parent.add_child(rect)

func _ensure_selected_preview_border() -> void:
	for child in get_children():
		var bg := child.get_node_or_null("Background") as ColorRect
		if bg == null:
			continue
		if bg.color == TABLE_SELECTED and not child.has_node("SelectedBorder"):
			_add_selected_border(child as Control)

func _refresh_selected_borders() -> void:
	if not is_inside_tree():
		return
	for child in get_children():
		var bg := child.get_node_or_null("Background") as ColorRect
		if bg != null and bg.color == TABLE_SELECTED:
			_add_selected_border(child as Control)

func _add_table_cell(row: Control, text: String, width: int, align := HORIZONTAL_ALIGNMENT_CENTER, header := false, color := TABLE_TEXT, selected := false, key := "", icon_path := "") -> void:
	var hbox := row.get_node("Cells") as HBoxContainer
	var cell := MarginContainer.new()
	cell.custom_minimum_size = Vector2(width, 0)
	cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var column_index := _get_column_index(key)
	if header:
		apply_header_style(cell, column_index)
	else:
		apply_cell_style(cell, column_index, selected)
	hbox.add_child(cell)

	if key == "good":
		_add_good_cell_content(cell, text, header, selected, icon_path)
	else:
		var label := _make_table_label(text, align, header, color, selected, key)
		cell.add_child(label)

	_add_cell_separator(hbox)

func _add_good_cell_content(cell: MarginContainer, text: String, header: bool, selected: bool, icon_path: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", ITEM_ICON_TEXT_GAP)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cell.add_child(row)

	var icon_slot := CenterContainer.new()
	icon_slot.custom_minimum_size = Vector2(ITEM_ICON_SIZE, 0)
	icon_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(icon_slot)

	if not header and icon_path != "":
		var texture := load(icon_path) as Texture2D
		if texture != null:
			icon_slot.add_child(_make_item_icon_stack(texture, ITEM_ICON_SIZE))

	var label := _make_table_label(text, HORIZONTAL_ALIGNMENT_LEFT, header, TABLE_TEXT, selected, "good")
	row.add_child(label)

func _make_item_icon_stack(texture: Texture2D, icon_size: int) -> Control:
	var stack := Control.new()
	stack.custom_minimum_size = Vector2(icon_size + 8, icon_size + 8)

	var shadow := TextureRect.new()
	shadow.modulate = Color(0.0, 0.0, 0.0, 0.34)
	shadow.texture = texture
	shadow.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shadow.offset_left = 2
	shadow.offset_top = 3
	shadow.offset_right = 2
	shadow.offset_bottom = 3
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(shadow)

	var icon := TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 4
	icon.offset_top = 3
	icon.offset_right = -4
	icon.offset_bottom = -5
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(icon)
	return stack

func _make_table_label(text: String, align: int, header: bool, color: Color, selected: bool, key: String) -> Label:
	var label := Label.new()
	label.text = text
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = align
	label.clip_text = true
	if header:
		label.label_settings = _header_label_settings
	elif key == "trend":
		label.label_settings = _make_label_settings(
			ROW_FONT_SIZE,
			_get_trend_display_color(text, color),
			2,
			TEXT_OUTLINE_COLOR,
			TEXT_SHADOW_COLOR,
			TEXT_SHADOW_OFFSET
		)
	else:
		label.label_settings = _selected_row_label_settings if selected else _row_label_settings
	return label

func _add_cell_separator(parent: HBoxContainer) -> void:
	var sep := Control.new()
	sep.custom_minimum_size = Vector2(3, 0)
	sep.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(sep)

	var dark := ColorRect.new()
	dark.color = SEPARATOR_DARK
	dark.anchor_bottom = 1.0
	dark.offset_right = 1.0
	dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sep.add_child(dark)

	var highlight := ColorRect.new()
	highlight.color = SEPARATOR_HIGHLIGHT
	highlight.anchor_left = 0.0
	highlight.anchor_right = 0.0
	highlight.anchor_bottom = 1.0
	highlight.offset_left = 1.0
	highlight.offset_right = 2.0
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sep.add_child(highlight)

	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.22)
	shade.anchor_left = 0.0
	shade.anchor_right = 0.0
	shade.anchor_bottom = 1.0
	shade.offset_left = 2.0
	shade.offset_right = 3.0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sep.add_child(shade)

func apply_cell_style(cell: MarginContainer, column_index: int, selected: bool) -> void:
	var left_padding := FIRST_COLUMN_LEFT_PADDING if column_index == 0 else CELL_HORIZONTAL_PADDING
	var right_padding := 12 if column_index == 0 else CELL_HORIZONTAL_PADDING
	cell.add_theme_constant_override("margin_left", left_padding)
	cell.add_theme_constant_override("margin_right", right_padding)
	cell.add_theme_constant_override("margin_top", 5 if selected else 4)
	cell.add_theme_constant_override("margin_bottom", 5 if selected else 4)

func apply_header_style(cell: MarginContainer, column_index: int) -> void:
	var left_padding := FIRST_COLUMN_LEFT_PADDING if column_index == 0 else CELL_HORIZONTAL_PADDING
	cell.add_theme_constant_override("margin_left", left_padding)
	cell.add_theme_constant_override("margin_right", CELL_HORIZONTAL_PADDING)
	cell.add_theme_constant_override("margin_top", 4)
	cell.add_theme_constant_override("margin_bottom", 4)

func _get_column_index(key: String) -> int:
	for i in range(COLUMNS.size()):
		if str(COLUMNS[i].get("key", "")) == key:
			return i
	return -1

func _ensure_label_settings() -> void:
	if _header_label_settings == null:
		_header_label_settings = create_header_label_settings()
	if _row_label_settings == null:
		_row_label_settings = create_body_label_settings(false)
	if _selected_row_label_settings == null:
		_selected_row_label_settings = create_body_label_settings(true)

func create_header_label_settings() -> LabelSettings:
	return _make_label_settings(
		HEADER_FONT_SIZE,
		HEADER_TEXT_COLOR,
		1,
		HEADER_OUTLINE_COLOR,
		HEADER_SHADOW_COLOR,
		Vector2(1.0, 1.0)
	)

func create_body_label_settings(selected: bool) -> LabelSettings:
	return _make_label_settings(
		ROW_FONT_SIZE,
		SELECTED_TEXT_COLOR if selected else ROW_TEXT_COLOR,
		2 if selected else 1,
		TEXT_OUTLINE_COLOR,
		TEXT_SHADOW_COLOR,
		TEXT_SHADOW_OFFSET
	)

func _make_label_settings(font_size: int, font_color: Color, outline_size := 2, outline_color := TEXT_OUTLINE_COLOR, shadow_color := TEXT_SHADOW_COLOR, shadow_offset := TEXT_SHADOW_OFFSET) -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = font_color
	settings.outline_size = outline_size
	settings.outline_color = outline_color
	settings.shadow_color = shadow_color
	settings.shadow_offset = shadow_offset
	return settings

func _get_trend_display_color(text: String, fallback: Color) -> Color:
	match text:
		"^":
			return MUTED_TREND_GREEN
		"v":
			return MUTED_TREND_RED
		"->":
			return MUTED_TREND_GOLD
		_:
			return fallback

func _on_row_input(event: InputEvent, item_id: String) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		row_selected.emit(item_id)

func _apply_noise_material_to_backgrounds() -> void:
	if not is_inside_tree():
		return
	for child in get_children():
		var bg := child.get_node_or_null("Background") as ColorRect
		if bg == null:
			continue
		if bg.color == TABLE_HEADER and header_noise_material != null:
			bg.material = header_noise_material if Engine.is_editor_hint() else header_noise_material.duplicate()
		elif bg.color == TABLE_BG and table_noise_material != null:
			bg.material = table_noise_material if Engine.is_editor_hint() else table_noise_material.duplicate()
		elif bg.color == TABLE_SELECTED and selected_noise_material != null:
			bg.material = selected_noise_material if Engine.is_editor_hint() else selected_noise_material.duplicate()
		else:
			bg.material = null
		bg.queue_redraw()

func _get_preview_rows() -> Array[Dictionary]:
	return [
		{"id": "bread", "good": "Bread", "icon_path": "res://assets/Icons/bread.png", "trend": "^", "trend_color": Color(0.58, 0.78, 0.32), "city_stock": "162", "cargo": "8", "ref": "14", "buy": "11", "sell": "9"},
		{"id": "grain", "good": "Grain", "trend": "^", "trend_color": Color(0.58, 0.78, 0.32), "city_stock": "248", "cargo": "15", "ref": "10", "buy": "8", "sell": "6"},
		{"id": "fish", "good": "Fish", "trend": "v", "trend_color": Color(0.73, 0.35, 0.24), "city_stock": "74", "cargo": "6", "ref": "16", "buy": "13", "sell": "11"},
		{"id": "ale", "good": "Ale", "trend": "^", "trend_color": Color(0.58, 0.78, 0.32), "city_stock": "126", "cargo": "10", "ref": "18", "buy": "15", "sell": "12"},
		{"id": "iron", "good": "Iron Ore", "trend": "->", "trend_color": Color(0.78, 0.62, 0.28), "city_stock": "310", "cargo": "12", "ref": "22", "buy": "19", "sell": "16"},
	]
