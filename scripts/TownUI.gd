extends Control

const PRIMARY_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-003_Primary Button_trimmed.png")
const SECONDARY_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-004_Secondary Button_trimmed.png")
const DISABLED_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-005_Disabled Button_trimmed.png")

var town_name: String = ""
var initial_tab: String = "market"
var visible_tabs: Array[String] = []

signal closed

var _active_tab: String = "market"
var _post_btn: Button

var _primary_button_style: StyleBoxTexture
var _secondary_button_style: StyleBoxTexture
var _disabled_button_style: StyleBoxTexture

var tabs: Dictionary = {}
var _invest_error: String = ""

func _ready() -> void:
	_build_button_styles()

	$TownName.text = town_name
	var _economy: Node = get_node("/root/EconomyManager")
	var town: Dictionary = _economy.get_town(town_name)
	$FactionLabel.text = String(town.get("faction", ""))

	# Initialize tab controllers
	tabs["market"] = preload("res://scripts/ui/town_ui/MarketTab.gd").new(self, $MarketPanel)
	tabs["npc"] = preload("res://scripts/ui/town_ui/NPCTab.gd").new(self, $NPCPanel)
	tabs["info"] = preload("res://scripts/ui/town_ui/InfoTab.gd").new(self, $InfoPanel)
	tabs["contracts"] = preload("res://scripts/ui/town_ui/ContractsTab.gd").new(self, $ContractsPanel)
	tabs["invest"] = preload("res://scripts/ui/town_ui/InvestTab.gd").new(self, $InvestPanel)
	tabs["upgrade"] = preload("res://scripts/ui/town_ui/UpgradeTab.gd").new(self, $UpgradePanel)

	var post_btn := Button.new()
	_post_btn = post_btn
	post_btn.name = "PostBtn"
	post_btn.text = "Post"
	$TabBar.add_child(post_btn)
	var post_panel := PanelContainer.new()
	post_panel.name = "PostPanel"
	post_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	post_panel.offset_top = 40.0
	post_panel.offset_bottom = -50.0
	post_panel.visible = false
	add_child(post_panel)
	
	tabs["post"] = preload("res://scripts/ui/town_ui/PostTab.gd").new(self, post_panel)

	var _contracts: Node = get_node("/root/ContractManager")
	if _contracts.has_signal("contracts_changed"):
		_contracts.connect("contracts_changed", _on_contracts_changed)

	$TabBar/MarketBtn.pressed.connect(_show_tab.bind("market"))
	$TabBar/NPCBtn.pressed.connect(_show_tab.bind("npc"))
	$TabBar/InfoBtn.pressed.connect(_show_tab.bind("info"))
	$TabBar/ContractsBtn.pressed.connect(_show_tab.bind("contracts"))
	$TabBar/InvestBtn.pressed.connect(_show_tab.bind("invest"))
	$TabBar/UpgradeBtn.pressed.connect(_show_tab.bind("upgrade"))
	post_btn.pressed.connect(_show_tab.bind("post"))
	$CloseBtn.pressed.connect(_on_close)

	apply_secondary_button_style($CloseBtn)
	_apply_visible_tabs()
	_show_tab(_get_initial_tab())

func _show_tab(tab: String) -> void:
	if not _is_tab_visible(tab):
		return
	_active_tab = tab
	for key in tabs:
		tabs[key].panel.visible = (key == tab)
	
	_update_tab_button_styles()

	if tabs.has(tab):
		tabs[tab].build()

func _update_tab_button_styles() -> void:
	$TabBar.custom_minimum_size = Vector2(664, 42)
	$TabBar.size = Vector2(664, 42)
	_apply_tab_button_style($TabBar/MarketBtn, _active_tab == "market")
	_apply_tab_button_style($TabBar/NPCBtn, _active_tab == "npc")
	_apply_tab_button_style($TabBar/InfoBtn, _active_tab == "info")
	_apply_tab_button_style($TabBar/ContractsBtn, _active_tab == "contracts")
	_apply_tab_button_style($TabBar/InvestBtn, _active_tab == "invest")
	_apply_tab_button_style($TabBar/UpgradeBtn, _active_tab == "upgrade")
	if _post_btn:
		_apply_tab_button_style(_post_btn, _active_tab == "post")

func _apply_tab_button_style(button: Button, active: bool) -> void:
	if button == null:
		return
	if active:
		apply_primary_button_style(button)
	else:
		apply_secondary_button_style(button)
	button.custom_minimum_size = Vector2(104, 42)

func _apply_visible_tabs() -> void:
	if visible_tabs.is_empty():
		return
	_set_tab_button_visible($TabBar/MarketBtn, "market")
	_set_tab_button_visible($TabBar/NPCBtn, "npc")
	_set_tab_button_visible($TabBar/InfoBtn, "info")
	_set_tab_button_visible($TabBar/ContractsBtn, "contracts")
	_set_tab_button_visible($TabBar/InvestBtn, "invest")
	_set_tab_button_visible($TabBar/UpgradeBtn, "upgrade")
	_set_tab_button_visible(_post_btn, "post")

func _set_tab_button_visible(button: Button, tab: String) -> void:
	if button:
		button.visible = _is_tab_visible(tab)

func _is_tab_visible(tab: String) -> bool:
	return visible_tabs.is_empty() or visible_tabs.has(tab)

func _get_initial_tab() -> String:
	if _is_tab_visible(initial_tab):
		return initial_tab
	if visible_tabs.is_empty():
		return "market"
	return String(visible_tabs[0])

func _build_button_styles() -> void:
	_primary_button_style = _make_button_style(PRIMARY_BUTTON_TEXTURE)
	_secondary_button_style = _make_button_style(SECONDARY_BUTTON_TEXTURE)
	_disabled_button_style = _make_button_style(DISABLED_BUTTON_TEXTURE)

func _make_button_style(texture: Texture2D) -> StyleBoxTexture:
	var style = StyleBoxTexture.new()
	style.texture = texture
	style.content_margin_left = 18.0
	style.content_margin_top = 10.0
	style.content_margin_right = 18.0
	style.content_margin_bottom = 10.0
	return style

func apply_primary_button_style(button: Button) -> void:
	button.custom_minimum_size = Vector2(96, 42)
	button.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.9, 0.55))
	button.add_theme_color_override("font_pressed_color", Color(0.78, 0.55, 0.2))
	button.add_theme_color_override("font_disabled_color", Color(0.48, 0.42, 0.32, 0.85))
	button.add_theme_color_override("font_shadow_color", Color(0.06, 0.03, 0.012, 0.95))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_stylebox_override("normal", _primary_button_style)
	button.add_theme_stylebox_override("hover", _primary_button_style)
	button.add_theme_stylebox_override("pressed", _primary_button_style)
	button.add_theme_stylebox_override("disabled", _disabled_button_style)

func apply_secondary_button_style(button: Button) -> void:
	button.custom_minimum_size = Vector2(96, 42)
	button.add_theme_color_override("font_color", Color(0.82, 0.65, 0.36))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.82, 0.42))
	button.add_theme_color_override("font_pressed_color", Color(0.68, 0.48, 0.2))
	button.add_theme_color_override("font_disabled_color", Color(0.48, 0.42, 0.32, 0.85))
	button.add_theme_color_override("font_shadow_color", Color(0.06, 0.03, 0.012, 0.95))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_stylebox_override("normal", _secondary_button_style)
	button.add_theme_stylebox_override("hover", _secondary_button_style)
	button.add_theme_stylebox_override("pressed", _secondary_button_style)
	button.add_theme_stylebox_override("disabled", _disabled_button_style)

func _on_contracts_changed() -> void:
	if _active_tab == "contracts" and tabs.has("contracts"):
		tabs["contracts"].build()

func _on_close() -> void:
	emit_signal("closed")
	queue_free()

func _format_town_report(report: Dictionary) -> String:
	if report.is_empty():
		return "No report yet."
	var lines: Array[String] = []
	lines.append("Season: %s" % report.get("season", "unknown"))
	var final_prod: Dictionary = report.get("final_production", {})
	if final_prod.is_empty():
		lines.append("No production in this period.")
	else:
		for item in final_prod:
			var eff: float = float(report.get("missing_input_efficiency", {}).get(item, 1.0))
			var blocked: int = int(report.get("stock_blocked", {}).get(item, 0))
			lines.append("- %s: +%d (eff %.0f%%, blocked %d)" % [item, final_prod[item], eff * 100.0, blocked])
	var issues: Array = report.get("critical_consumption_issues", [])
	if not issues.is_empty():
		lines.append("Critical shortages: %s" % ", ".join(issues))
	return "\n".join(lines)
