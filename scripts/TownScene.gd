extends Control

const TOWN_UI_SCENE: PackedScene = preload("res://scenes/TownUI.tscn")
const PRIMARY_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-003_Primary Button_trimmed.png")
const SECONDARY_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-004_Secondary Button_trimmed.png")

var town_name: String = ""
var embedded_in_map_view: bool = false

signal closed

var _economy: Node
var _primary_button_style: StyleBoxTexture
var _secondary_button_style: StyleBoxTexture
var _active_town_ui: Control

func _ready() -> void:
	_economy = get_node("/root/EconomyManager")
	_build_button_styles()
	_build_layout()

func _build_layout() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.05, 0.035, 0.02, 1.0 if embedded_in_map_view else 0.92)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var edge_margin := 32 if embedded_in_map_view else 64
	var top_margin := 28 if embedded_in_map_view else 96
	margin.add_theme_constant_override("margin_left", edge_margin)
	margin.add_theme_constant_override("margin_right", edge_margin)
	margin.add_theme_constant_override("margin_top", top_margin)
	margin.add_theme_constant_override("margin_bottom", edge_margin)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 18)
	margin.add_child(root)

	var header := HBoxContainer.new()
	root.add_child(header)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)

	var title := Label.new()
	title.text = town_name
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	title_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = _get_town_summary()
	subtitle.add_theme_color_override("font_color", Color(0.78, 0.66, 0.48))
	title_box.add_child(subtitle)

	var close_btn := Button.new()
	close_btn.text = "Back to Map"
	close_btn.pressed.connect(_on_close_pressed)
	_apply_secondary_button_style(close_btn)
	header.add_child(close_btn)

	root.add_child(HSeparator.new())

	var city_area := Control.new()
	city_area.custom_minimum_size = Vector2(920, 460)
	city_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(city_area)

	var ground := ColorRect.new()
	ground.color = Color(0.18, 0.13, 0.08, 1.0)
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	city_area.add_child(ground)

	_add_building_button(city_area, "Market Hall", "Trade goods and inspect the 14-day goods outlook.", Vector2(80, 90), Vector2(260, 136), _open_market_hall)
	_add_building_button(city_area, "Town Hall", "Contracts, town info, investments, upgrades and trading posts.", Vector2(390, 70), Vector2(300, 158), _open_town_hall)
	_add_building_button(city_area, "Harbor", "Coming later.", Vector2(760, 220), Vector2(220, 120), Callable())
	_add_building_button(city_area, "Warehouse", "Coming later.", Vector2(160, 290), Vector2(250, 118), Callable())

func _add_building_button(parent: Control, title: String, tooltip: String, pos: Vector2, size: Vector2, callback: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.tooltip_text = tooltip
	button.position = pos
	button.custom_minimum_size = size
	button.size = size
	button.add_theme_font_size_override("font_size", 18)
	if callback.is_valid():
		button.pressed.connect(callback)
		_apply_primary_button_style(button)
	else:
		button.disabled = true
		_apply_secondary_button_style(button)
	parent.add_child(button)

func _open_market_hall() -> void:
	var tabs: Array[String] = ["market"]
	_open_town_ui("market", tabs)

func _open_town_hall() -> void:
	var tabs: Array[String] = ["info", "contracts", "invest", "upgrade", "post", "npc"]
	_open_town_ui("info", tabs)

func _open_town_ui(initial_tab: String, visible_tabs: Array[String]) -> void:
	if _active_town_ui != null and is_instance_valid(_active_town_ui):
		return
	var town_ui: Node = TOWN_UI_SCENE.instantiate()
	town_ui.set("town_name", town_name)
	town_ui.set("initial_tab", initial_tab)
	town_ui.set("visible_tabs", visible_tabs)
	add_child(town_ui)
	_active_town_ui = town_ui as Control
	town_ui.connect("closed", Callable(self, "_on_town_ui_closed"))

func _on_town_ui_closed() -> void:
	_active_town_ui = null

func _on_close_pressed() -> void:
	if _active_town_ui != null and is_instance_valid(_active_town_ui):
		_active_town_ui.queue_free()
	_active_town_ui = null
	emit_signal("closed")
	queue_free()

func _get_town_summary() -> String:
	var town: Dictionary = _economy.get_town(town_name)
	var faction: String = String(town.get("faction", ""))
	var population: int = int(town.get("population", 0))
	var prosperity: int = int(_economy.get_prosperity(town_name))
	var prosperity_label: String = String(_economy.get_prosperity_label(town_name))
	return "%s | Population %d | %s %d" % [faction, population, prosperity_label, prosperity]

func _build_button_styles() -> void:
	_primary_button_style = _make_button_style(PRIMARY_BUTTON_TEXTURE)
	_secondary_button_style = _make_button_style(SECONDARY_BUTTON_TEXTURE)

func _make_button_style(texture: Texture2D) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.content_margin_left = 22.0
	style.content_margin_top = 14.0
	style.content_margin_right = 22.0
	style.content_margin_bottom = 14.0
	return style

func _apply_primary_button_style(button: Button) -> void:
	button.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.9, 0.55))
	button.add_theme_color_override("font_shadow_color", Color(0.06, 0.03, 0.012, 0.95))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.add_theme_stylebox_override("normal", _primary_button_style)
	button.add_theme_stylebox_override("hover", _primary_button_style)
	button.add_theme_stylebox_override("pressed", _primary_button_style)

func _apply_secondary_button_style(button: Button) -> void:
	button.add_theme_color_override("font_color", Color(0.82, 0.65, 0.36))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.82, 0.42))
	button.add_theme_color_override("font_disabled_color", Color(0.48, 0.42, 0.32, 0.85))
	button.add_theme_color_override("font_shadow_color", Color(0.06, 0.03, 0.012, 0.95))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.add_theme_stylebox_override("normal", _secondary_button_style)
	button.add_theme_stylebox_override("hover", _secondary_button_style)
	button.add_theme_stylebox_override("pressed", _secondary_button_style)
	button.add_theme_stylebox_override("disabled", _secondary_button_style)
