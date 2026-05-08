extends Control

const PRIMARY_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-003_Primary Button_trimmed.png")
const SECONDARY_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-004_Secondary Button_trimmed.png")
const DISABLED_BUTTON_TEXTURE: Texture2D = preload("res://assets/ui_kit/UI-005_Disabled Button_trimmed.png")

var town_name: String = ""

signal closed

var _player: Node
var _economy: Node
var _faction: Node
var _contracts: Node
var _events: Node

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
	_contracts = get_node("/root/ContractManager")
	_events = get_node_or_null("/root/EventManager")
	if _contracts.has_signal("contracts_changed"):
		_contracts.connect("contracts_changed", _on_contracts_changed)

	$TownName.text = town_name
	var town = _economy.get_town(town_name)
	$FactionLabel.text = town.get("faction", "")

	_show_tab("market")

	$TabBar/MarketBtn.pressed.connect(_show_tab.bind("market"))
	$TabBar/NPCBtn.pressed.connect(_show_tab.bind("npc"))
	$TabBar/InfoBtn.pressed.connect(_show_tab.bind("info"))
	$TabBar/ContractsBtn.pressed.connect(_show_tab.bind("contracts"))
	$TabBar/InvestBtn.pressed.connect(_show_tab.bind("invest"))
	$CloseBtn.pressed.connect(_on_close)

	_apply_secondary_button_style($CloseBtn)

func _show_tab(tab: String) -> void:
	_active_tab = tab
	$MarketPanel.visible = (tab == "market")
	$NPCPanel.visible    = (tab == "npc")
	$InfoPanel.visible   = (tab == "info")
	$ContractsPanel.visible = (tab == "contracts")
	$InvestPanel.visible = (tab == "invest")
	_update_tab_button_styles()

	match tab:
		"market": _build_market()
		"npc":    _build_npc()
		"info":   _build_info()
		"contracts": _build_contracts()
		"invest": _build_invest()

func _update_tab_button_styles() -> void:
	$TabBar.custom_minimum_size = Vector2(560, 42)
	$TabBar.size = Vector2(560, 42)
	_apply_tab_button_style($TabBar/MarketBtn, _active_tab == "market")
	_apply_tab_button_style($TabBar/NPCBtn, _active_tab == "npc")
	_apply_tab_button_style($TabBar/InfoBtn, _active_tab == "info")
	_apply_tab_button_style($TabBar/ContractsBtn, _active_tab == "contracts")
	_apply_tab_button_style($TabBar/InvestBtn, _active_tab == "invest")

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
		var town_free_stock = _economy.get_town_free_stock(town_name, item)

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
		sell_btn.disabled = (player_has == 0 or town_free_stock < 1)
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

# ---- CONTRACTS ----

func _build_contracts() -> void:
	var container = $ContractsPanel/ScrollContainer/ContractList
	for child in container.get_children():
		child.queue_free()

	var active_contracts: Array = _contracts.get_active_contracts()
	var town_contracts: Array = _contracts.get_available_contracts(town_name)

	var summary = Label.new()
	summary.text = "Cargo: %d/%d  |  Gold: %.1f" % [_player.get_total_cargo(), _player.caravan_capacity, _player.gold]
	container.add_child(summary)
	container.add_child(HSeparator.new())

	_add_contract_section_title(container, "Available in %s" % town_name)
	if town_contracts.is_empty():
		_add_muted_label(container, "No local contracts available right now.")
	else:
		for contract in town_contracts:
			_add_contract_card(container, contract, "available")

	container.add_child(HSeparator.new())
	_add_contract_section_title(container, "Active Contracts")
	if active_contracts.is_empty():
		_add_muted_label(container, "No active contracts.")
	else:
		for contract in active_contracts:
			_add_contract_card(container, contract, "active")

func _add_contract_section_title(container: VBoxContainer, text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	container.add_child(label)

func _add_muted_label(container: VBoxContainer, text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.68, 0.58, 0.42))
	container.add_child(label)

func _add_contract_card(container: VBoxContainer, contract: Dictionary, mode: String) -> void:
	var card = VBoxContainer.new()
	card.add_theme_constant_override("separation", 4)

	var title = Label.new()
	title.text = "%s  [%s]" % [contract.get("title", "Contract"), str(contract.get("difficulty_tier", "basic")).capitalize()]
	title.add_theme_color_override("font_color", Color(0.94, 0.78, 0.45))
	card.add_child(title)

	var desc = Label.new()
	desc.text = contract.get("description", "")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(desc)

	var issuer_text: String = _format_contract_issuer(contract)
	var days_left: int = int(_contracts.get_days_remaining(contract))
	var time_label: String = "Time after accept" if mode == "available" else "Days left"
	var held: int = int(_player.get_item_count(str(contract.get("required_item", ""))))
	var details = Label.new()
	details.text = "Need: %d/%d %s  |  Target: %s  |  %s: %d  |  Reward: %dg, +%.1f rep  |  Issuer: %s" % [
		held,
		int(contract.get("required_quantity", 0)),
		str(contract.get("required_item", "")).capitalize(),
		contract.get("target_town", ""),
		time_label,
		days_left,
		int(contract.get("reward_gold", 0)),
		float(contract.get("reward_faction_rep", 0.0)),
		issuer_text,
	]
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(details)

	var actions = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)

	if mode == "available":
		var accept_btn = Button.new()
		accept_btn.text = "Accept"
		_apply_primary_button_style(accept_btn)
		accept_btn.pressed.connect(_on_accept_contract.bind(str(contract.get("id", ""))))
		actions.add_child(accept_btn)
	else:
		var complete_btn = Button.new()
		complete_btn.text = "Complete"
		complete_btn.disabled = not _contracts.can_complete_contract(str(contract.get("id", "")))
		_apply_primary_button_style(complete_btn)
		complete_btn.pressed.connect(_on_complete_contract.bind(str(contract.get("id", ""))))
		actions.add_child(complete_btn)

		var status = Label.new()
		status.text = _format_contract_progress(contract)
		status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		actions.add_child(status)

	card.add_child(actions)
	container.add_child(card)
	container.add_child(HSeparator.new())

func _format_contract_issuer(contract: Dictionary) -> String:
	var npc_id: String = String(contract.get("issuing_npc_id", ""))
	if npc_id != "":
		var npc = _faction.get_npc(npc_id)
		if not npc.is_empty():
			return "%s, %s" % [npc.get("name", npc_id), npc.get("faction", contract.get("issuing_faction", ""))]
	return String(contract.get("issuing_faction", "Unknown"))

func _format_contract_progress(contract: Dictionary) -> String:
	if town_name != contract.get("target_town", ""):
		return "Travel to %s" % contract.get("target_town", "")
	var held: int = int(_player.get_item_count(str(contract.get("required_item", ""))))
	var needed: int = int(contract.get("required_quantity", 0))
	if held < needed:
		return "Need %d more" % (needed - held)
	return "Ready to deliver"

func _on_accept_contract(contract_id: String) -> void:
	_contracts.accept_contract(contract_id)
	_build_contracts()

func _on_complete_contract(contract_id: String) -> void:
	_contracts.complete_contract(contract_id)
	_build_contracts()
	_build_market()

func _on_contracts_changed() -> void:
	if _active_tab == "contracts":
		_build_contracts()

# ---- INFO ----

func _build_info() -> void:
	# --- Aktif olay kartı ---
	if _events != null and _events.has_event(town_name):
		var event: Dictionary = _events.get_event(town_name)
		var event_color: Color = event.get("color", Color.WHITE)
		var days_left: int = int(event.get("ends_day", 0)) - int(_economy.current_day)

		var event_card = Label.new()
		event_card.text = "[%s] %s\n%s\nEnds in %d day(s)." % [
			str(event.get("name", "")),
			str(event.get("icon", "")),
			str(event.get("description", "")),
			max(days_left, 0),
		]
		event_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		event_card.add_theme_color_override("font_color", event_color)
		event_card.add_theme_font_size_override("font_size", 15)
		$InfoPanel.add_child(event_card)
		$InfoPanel.move_child(event_card, 0)

	# --- Mevcut info ---
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

# ---- INVEST ----

func _build_invest() -> void:
	var container = $InvestPanel/ScrollContainer/InvestList
	for child in container.get_children():
		child.queue_free()

	var prosperity := int(_economy.get_prosperity(town_name))
	var level := int(_economy.get_prosperity_level(town_name))
	var label := String(_economy.get_prosperity_label(town_name))

	# Header
	var title = Label.new()
	title.text = "Invest in %s" % town_name
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	container.add_child(title)

	var status = Label.new()
	status.text = "Status: %s (Level %d)  |  Prosperity: %d / %d" % [label, level, prosperity, _economy.PROSPERITY_MAX]
	status.add_theme_color_override("font_color", Color(0.94, 0.78, 0.45))
	container.add_child(status)

	var explain = Label.new()
	explain.text = "Invest gold into the town. Each %d gold raises prosperity by 1 point.\nA prosperous town produces more goods and pays better prices." % int(_economy.GOLD_PER_PROSPERITY_POINT)
	explain.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explain.add_theme_color_override("font_color", Color(0.76, 0.62, 0.36))
	container.add_child(explain)

	# Mevcut prosperity bonusu
	var multiplier := float(_economy.get_prosperity_multiplier(town_name))
	var production_bonus := int(round((multiplier - 1.0) * 100.0))
	var sell_bonus := int(round((multiplier - 1.0) * 30.0))
	var effects = Label.new()
	effects.text = "Current effects:\n  • Production: +%d%%\n  • Sell prices: +%d%%\n  • Demand: +%d%%" % [production_bonus, sell_bonus, production_bonus]
	effects.add_theme_color_override("font_color", Color(0.7, 0.95, 0.7))
	container.add_child(effects)

	container.add_child(HSeparator.new())

	var gold_lbl = Label.new()
	gold_lbl.text = "Your gold: %.1f" % _player.gold
	container.add_child(gold_lbl)

	var amounts := [50, 100, 250, 500]
	for amount in amounts:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var amount_lbl = Label.new()
		amount_lbl.text = "%d gold  →  +%d prosperity" % [amount, int(amount / _economy.GOLD_PER_PROSPERITY_POINT)]
		amount_lbl.custom_minimum_size.x = 240
		row.add_child(amount_lbl)

		var btn = Button.new()
		btn.text = "Invest"
		btn.disabled = (_player.gold < amount or prosperity >= _economy.PROSPERITY_MAX)
		_apply_primary_button_style(btn)
		btn.pressed.connect(_on_invest.bind(amount))
		row.add_child(btn)

		container.add_child(row)

func _on_invest(amount: int) -> void:
	var gained := int(_economy.invest_gold(town_name, float(amount)))
	if gained > 0:
		print("Invested %d gold in %s. +%d prosperity." % [amount, town_name, gained])
	_build_invest()

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
