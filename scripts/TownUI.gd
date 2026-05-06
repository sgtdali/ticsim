extends Control

const PRIMARY_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-003_Primary Button_trimmed.png")
const SECONDARY_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-004_Secondary Button_trimmed.png")
const DISABLED_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-005_Disabled Button_trimmed.png")

var town_name: String = ""

signal closed

var _player: Node
var _economy: Node
var _faction: Node

var _active_tab: String = "market"

var _primary_button_style: StyleBoxTexture
var _secondary_button_style: StyleBoxTexture
var _disabled_button_style: StyleBoxTexture

# -----------------------------------------------

func _ready() -> void:
	_build_button_styles()

	_player  = get_node("/root/PlayerData")
	_economy = get_node("/root/EconomyManager")
	_faction = get_node("/root/FactionManager")

	$TownName.text = town_name
	var town = _economy.get_town(town_name)
	$FactionLabel.text = town.get("faction", "")

	_show_tab("market")

	$TabBar/MarketBtn.pressed.connect(_show_tab.bind("market"))
	$TabBar/NPCBtn.pressed.connect(_show_tab.bind("npc"))
	$TabBar/InfoBtn.pressed.connect(_show_tab.bind("info"))
	$CloseBtn.pressed.connect(_on_close)

	_apply_secondary_button_style($CloseBtn)

func _show_tab(tab: String) -> void:
	_active_tab = tab
	$MarketPanel.visible = (tab == "market")
	$NPCPanel.visible    = (tab == "npc")
	$InfoPanel.visible   = (tab == "info")
	_update_tab_button_styles()

	match tab:
		"market": _build_market()
		"npc":    _build_npc()
		"info":   _build_info()

func _update_tab_button_styles() -> void:
	$TabBar.custom_minimum_size = Vector2(340, 42)
	$TabBar.size = Vector2(340, 42)
	_apply_tab_button_style($TabBar/MarketBtn, _active_tab == "market")
	_apply_tab_button_style($TabBar/NPCBtn, _active_tab == "npc")
	_apply_tab_button_style($TabBar/InfoBtn, _active_tab == "info")

func _apply_tab_button_style(button: Button, active: bool) -> void:
	if active:
		_apply_primary_button_style(button)
	else:
		_apply_secondary_button_style(button)
	button.custom_minimum_size = Vector2(104, 42)

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

func _apply_primary_button_style(button: Button) -> void:
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

func _apply_secondary_button_style(button: Button) -> void:
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

# ---- MARKET ----

func _build_market() -> void:
	var container = $MarketPanel/ScrollContainer/ItemList
	for child in container.get_children():
		child.queue_free()

	var town = _economy.get_town(town_name)
	var inventory = town.get("inventory", {})

	# Header
	var header = Label.new()
	header.text = "%-18s %6s %8s %8s %8s" % ["Item", "Stock", "Price", "Buy", "Sell"]
	header.add_theme_font_size_override("font_size", 12)
	container.add_child(header)

	var separator = HSeparator.new()
	container.add_child(separator)

	# Player gold info
	var gold_lbl = Label.new()
	gold_lbl.text = "Your gold: %.1f  |  Cargo: %d/%d" % [
		_player.gold, _player.get_total_cargo(), _player.caravan_capacity
	]
	container.add_child(gold_lbl)

	var sep2 = HSeparator.new()
	container.add_child(sep2)

	for item in _economy.BASE_PRICES:
		var town_stock = inventory.get(item, 0)
		var price = _economy.get_price(town_name, item)
		var player_has = _player.get_item_count(item)

		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)

		var name_lbl = Label.new()
		name_lbl.text = item.capitalize()
		name_lbl.custom_minimum_size.x = 110
		row.add_child(name_lbl)

		var stock_lbl = Label.new()
		stock_lbl.text = str(town_stock)
		stock_lbl.custom_minimum_size.x = 50
		row.add_child(stock_lbl)

		var price_lbl = Label.new()
		price_lbl.text = "%.1fg" % price
		price_lbl.custom_minimum_size.x = 60
		row.add_child(price_lbl)

		var buy_btn = Button.new()
		buy_btn.text = "Buy 1"
		buy_btn.disabled = (town_stock == 0 or _player.gold < price or _player.get_free_capacity() < 1)
		_apply_primary_button_style(buy_btn)
		buy_btn.pressed.connect(_on_buy.bind(item, 1))
		row.add_child(buy_btn)

		var sell_btn = Button.new()
		sell_btn.text = "Sell 1 (%d)" % player_has
		sell_btn.disabled = (player_has == 0)
		_apply_secondary_button_style(sell_btn)
		sell_btn.pressed.connect(_on_sell.bind(item, 1))
		row.add_child(sell_btn)

		container.add_child(row)

func _on_buy(item: String, qty: int) -> void:
	_economy.player_buy(town_name, item, qty)
	_faction.apply_trade_reputation(_economy.get_town(town_name).get("faction", ""), _economy.get_price(town_name, item) * qty)
	_build_market()

func _on_sell(item: String, qty: int) -> void:
	_economy.player_sell(town_name, item, qty)
	_faction.apply_trade_reputation(_economy.get_town(town_name).get("faction", ""), _economy.get_price(town_name, item) * qty)
	_build_market()

# ---- NPC ----

func _build_npc() -> void:
	var container = $NPCPanel/NPCList
	for child in container.get_children():
		child.queue_free()

	var npcs = _faction.get_npcs_in_town(town_name)
	if npcs.is_empty():
		var lbl = Label.new()
		lbl.text = "No notable persons here."
		container.add_child(lbl)
		return

	for entry in npcs:
		var data = entry["data"]
		var npc_id = entry["id"]
		var relation = _player.get_npc_relation(npc_id)
		var rel_desc = _faction.get_relation_description(relation)

		var card = VBoxContainer.new()
		card.add_theme_constant_override("separation", 2)

		var name_lbl = Label.new()
		name_lbl.text = "%s — %s" % [data["name"], data["role"]]
		card.add_child(name_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = data["description"]
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(desc_lbl)

		var rel_lbl = Label.new()
		rel_lbl.text = "Relation: %s (%.0f)" % [rel_desc, relation]
		card.add_child(rel_lbl)

		var sep = HSeparator.new()
		container.add_child(card)
		container.add_child(sep)

# ---- INFO ----

func _build_info() -> void:
	var town = _economy.get_town(town_name)
	var faction_name = town.get("faction", "")
	var faction_data = _faction.get_faction_data(faction_name)
	var rep = _player.get_faction_rep(faction_name)
	var tax = _faction.get_tax_rate(faction_name)

	var lbl = $InfoPanel/InfoLabel
	lbl.text = """Town: %s
Faction: %s
Population: %d

%s

Your reputation: %s (%.0f)
Travel tax rate: %.0f%%

Produces: %s
Consumes: %s

Last production report:
%s""" % [
		town_name,
		faction_name,
		town.get("population", 0),
		faction_data.get("description", ""),
		_faction.get_relation_description(rep), rep,
		tax * 100.0,
		", ".join(town.get("production_plan", {}).keys()),
		", ".join(town.get("consumption_rules", {}).keys()),
		_format_town_report(_economy.get_town_report(town_name)),
	]

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
			var eff = report.get("missing_input_efficiency", {}).get(item, 1.0)
			var blocked = report.get("stock_blocked", {}).get(item, 0)
			lines.append("- %s: +%d (eff %.0f%%, blocked %d)" % [item, final_prod[item], eff * 100.0, blocked])
	var issues = report.get("critical_consumption_issues", [])
	if not issues.is_empty():
		lines.append("Critical shortages: %s" % ", ".join(issues))
	return "\n".join(lines)
