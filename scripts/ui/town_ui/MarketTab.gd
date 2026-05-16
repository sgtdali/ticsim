extends TownTab

var selected_item: String = ""
var trade_qty: int = 1
var market_view: String = "trade"

const GOODS_PROJECTION_DAYS := 14
func build() -> void:
	panel.offset_right = 760.0
	panel.offset_bottom = -10.0

	var container: VBoxContainer = panel.get_node("ScrollContainer/ItemList") as VBoxContainer
	for child in container.get_children():
		child.queue_free()

	if selected_item == "" or not _economy.BASE_PRICES.has(selected_item):
		selected_item = _get_first_item()
	trade_qty = maxi(trade_qty, 1)

	var town: Dictionary = _economy.get_town(town_name)
	var prosperity: int = int(_economy.get_prosperity(town_name))
	var label: String = String(_economy.get_prosperity_label(town_name))
	var pop: int = int(town.get("population", 0))

	var status_lbl := Label.new()
	status_lbl.text = "%s | %s | Pop %d | Prosperity %d/%d | Gold %.1fg | Cargo %d/%d" % [
		town_name,
		label,
		pop,
		prosperity,
		int(_economy.PROSPERITY_LEVEL_3_THRESHOLD),
		float(_player.gold),
		int(_player.get_total_cargo()),
		int(_player.caravan_capacity),
	]
	status_lbl.add_theme_font_size_override("font_size", 13)
	status_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	container.add_child(status_lbl)
	container.add_child(HSeparator.new())

	_build_view_switch(container)
	if market_view == "goods":
		_build_goods_projection_view(container)
		return

	_build_trade_table(container)

	container.add_child(HSeparator.new())
	_build_trade_panel(container)

func _build_view_switch(container: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	container.add_child(row)

	var trade_btn := Button.new()
	trade_btn.text = "Trade"
	trade_btn.toggle_mode = true
	trade_btn.button_pressed = market_view == "trade"
	trade_btn.pressed.connect(_set_market_view.bind("trade"))
	if market_view == "trade":
		ui.apply_primary_button_style(trade_btn)
	else:
		ui.apply_secondary_button_style(trade_btn)
	row.add_child(trade_btn)

	var goods_btn := Button.new()
	goods_btn.text = "Goods"
	goods_btn.toggle_mode = true
	goods_btn.button_pressed = market_view == "goods"
	goods_btn.pressed.connect(_set_market_view.bind("goods"))
	if market_view == "goods":
		ui.apply_primary_button_style(goods_btn)
	else:
		ui.apply_secondary_button_style(goods_btn)
	row.add_child(goods_btn)

	container.add_child(HSeparator.new())

func _build_trade_table(container: VBoxContainer) -> void:
	var table := MarketTableView.new()
	table.custom_minimum_size.x = 720
	table.row_selected.connect(_select_item)
	container.add_child(table)

	var rows: Array[Dictionary] = []
	for item in _economy.BASE_PRICES:
		rows.append(_get_trade_table_row_data(String(item)))
	table.set_rows(rows, selected_item)

func _get_trade_table_row_data(item: String) -> Dictionary:
	var town: Dictionary = _economy.get_town(town_name)
	var town_stock := int(town.get("inventory", {}).get(item, 0))
	var cargo := int(_player.get_item_count(item))
	var ref_price := float(_economy.get_price(town_name, item))
	var buy_avg: float = float(_economy.get_buy_quote_average(town_name, item, 1))
	var sell_avg: float = float(_economy.get_sell_quote_average(town_name, item, 1))

	return {
		"id": item,
		"good": _get_item_name(item),
		"trend": _get_price_trend_arrow(item),
		"trend_color": _get_price_signal_color(item),
		"city_stock": "%d" % town_stock,
		"cargo": "%d" % cargo,
		"ref": "%.1f" % ref_price,
		"buy": _format_quote_cell(buy_avg).replace("g", ""),
		"sell": _format_quote_cell(sell_avg).replace("g", ""),
	}

func _get_price_trend_arrow(item: String) -> String:
	var base: float = float(_economy.BASE_PRICES.get(item, 0.0))
	if base <= 0.0:
		return "-"
	var ratio: float = float(_economy.get_price(town_name, item)) / base
	if ratio >= 1.15:
		return "^"
	if ratio <= 0.85:
		return "v"
	return "->"

func _build_goods_projection_view(container: VBoxContainer) -> void:
	var explain := Label.new()
	explain.text = "%d-day demand and production outlook for %s." % [GOODS_PROJECTION_DAYS, town_name]
	explain.add_theme_color_override("font_color", Color(0.74, 0.65, 0.48))
	container.add_child(explain)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	container.add_child(header)

	_add_header_label(header, "Goods", 150)
	_add_header_label(header, "Signal", 70)
	_add_header_label(header, "Stock", 76)
	_add_header_label(header, "Need", 76)
	_add_header_label(header, "Prod", 76)
	_add_header_label(header, "Net", 86)

	for item in _economy.BASE_PRICES:
		_build_goods_projection_row(container, String(item))

func _build_goods_projection_row(container: VBoxContainer, item: String) -> void:
	var town: Dictionary = _economy.get_town(town_name)
	var stock: int = int(town.get("inventory", {}).get(item, 0))
	var daily_need: float = float(_economy.simulation.estimate_daily_consumption(town, item))
	var daily_prod: float = float(_economy.simulation.estimate_effective_daily_supply(town, item))
	var need: int = int(round(daily_need * float(GOODS_PROJECTION_DAYS)))
	var prod: int = int(round(daily_prod * float(GOODS_PROJECTION_DAYS)))
	var net: int = stock + prod - need
	var prod_text: String = "%d" % prod if prod > 0 else "-"

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	container.add_child(row)

	var item_btn := Button.new()
	item_btn.text = _get_item_name(item)
	item_btn.custom_minimum_size = Vector2(150, 34)
	item_btn.pressed.connect(_select_item_and_open_trade.bind(item))
	ui.apply_secondary_button_style(item_btn)
	item_btn.custom_minimum_size = Vector2(150, 34)
	row.add_child(item_btn)

	var signal_lbl := Label.new()
	signal_lbl.text = _get_projection_signal_text(net, need)
	signal_lbl.custom_minimum_size.x = 70
	signal_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	signal_lbl.add_theme_color_override("font_color", _get_projection_signal_color(net, need))
	row.add_child(signal_lbl)

	_add_value_label(row, "%d" % stock, 76)
	_add_projection_value_label(row, "%d" % need, 76, need > 0 and stock <= 0)
	_add_projection_value_label(row, prod_text, 76, false)
	_add_projection_value_label(row, "%+d" % net, 86, net < 0)

func _build_trade_panel(container: VBoxContainer) -> void:
	if selected_item == "":
		return

	var item: String = selected_item
	var player_has: int = int(_player.get_item_count(item))
	var town: Dictionary = _economy.get_town(town_name)
	var town_stock: int = int(town.get("inventory", {}).get(item, 0))
	var town_free_stock: int = int(_economy.get_town_free_stock(town_name, item))
	var free_cap: int = int(_player.get_free_capacity())
	var max_buy: int = _get_max_affordable_buy(item, mini(town_stock, free_cap))
	var max_sell: int = mini(player_has, town_free_stock)
	var max_qty: int = maxi(1, maxi(max_buy, max_sell))
	trade_qty = clampi(trade_qty, 1, max_qty)

	var title := Label.new()
	title.text = "%s  |  Cargo %d  |  City %d  |  Ref %.1fg" % [
		_get_item_name(item),
		player_has,
		town_stock,
		float(_economy.get_price(town_name, item)),
	]
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	container.add_child(title)

	var qty_row := HBoxContainer.new()
	qty_row.add_theme_constant_override("separation", 8)
	container.add_child(qty_row)

	var qty_lbl := Label.new()
	qty_lbl.text = "Qty"
	qty_lbl.custom_minimum_size.x = 44
	qty_row.add_child(qty_lbl)

	var slider := HSlider.new()
	slider.min_value = 1
	slider.max_value = max_qty
	slider.step = 1
	slider.value = trade_qty
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_qty_changed)
	qty_row.add_child(slider)

	var spin := SpinBox.new()
	spin.min_value = 1
	spin.max_value = max_qty
	spin.step = 1
	spin.value = trade_qty
	spin.custom_minimum_size.x = 80
	spin.value_changed.connect(_on_qty_changed)
	qty_row.add_child(spin)

	var max_buy_btn := Button.new()
	max_buy_btn.text = "Max Buy"
	max_buy_btn.disabled = max_buy <= 0
	max_buy_btn.pressed.connect(_set_qty_and_rebuild.bind(max_buy))
	ui.apply_secondary_button_style(max_buy_btn)
	qty_row.add_child(max_buy_btn)

	var max_sell_btn := Button.new()
	max_sell_btn.text = "Max Sell"
	max_sell_btn.disabled = max_sell <= 0
	max_sell_btn.pressed.connect(_set_qty_and_rebuild.bind(max_sell))
	ui.apply_secondary_button_style(max_sell_btn)
	qty_row.add_child(max_sell_btn)

	var quote_row := HBoxContainer.new()
	quote_row.add_theme_constant_override("separation", 16)
	container.add_child(quote_row)

	var buy_total: float = float(_economy.get_buy_quote_total(town_name, item, trade_qty))
	var sell_total: float = float(_economy.get_sell_quote_total(town_name, item, trade_qty))
	var buy_avg: float = buy_total / float(trade_qty) if trade_qty > 0 else 0.0
	var sell_avg: float = sell_total / float(trade_qty) if trade_qty > 0 else 0.0
	var stored_avg: float = float(_player.purchase_prices.get(item, 0.0))

	_add_quote_block(quote_row, "Buy", buy_total, buy_avg, max_buy)
	_add_quote_block(quote_row, "Sell", sell_total, sell_avg, max_sell)
	if player_has > 0 and stored_avg > 0.0:
		var diff: float = sell_avg - stored_avg
		var profit: float = diff * float(mini(trade_qty, max_sell))
		_add_plain_info(quote_row, "Held avg\n%.1fg\n%+.1fg" % [stored_avg, profit], _profit_color(diff))

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	container.add_child(action_row)

	var buy_btn := Button.new()
	buy_btn.text = "Buy"
	buy_btn.disabled = trade_qty <= 0 or trade_qty > max_buy
	buy_btn.tooltip_text = _format_trade_quote_tooltip("Buy", trade_qty, buy_total)
	buy_btn.pressed.connect(_on_buy.bind(item, trade_qty))
	ui.apply_primary_button_style(buy_btn)
	action_row.add_child(buy_btn)

	var sell_btn := Button.new()
	sell_btn.text = "Sell"
	sell_btn.disabled = trade_qty <= 0 or trade_qty > max_sell
	sell_btn.tooltip_text = _format_trade_quote_tooltip("Sell", trade_qty, sell_total)
	sell_btn.pressed.connect(_on_sell.bind(item, trade_qty))
	ui.apply_secondary_button_style(sell_btn)
	action_row.add_child(sell_btn)

	var note := Label.new()
	note.text = "Reference price is not the transaction price; buy/sell quotes include spread and stock movement."
	note.add_theme_font_size_override("font_size", 11)
	note.add_theme_color_override("font_color", Color(0.62, 0.55, 0.42))
	container.add_child(note)

func _add_quote_block(parent: HBoxContainer, title: String, total: float, avg: float, max_qty: int) -> void:
	var box := VBoxContainer.new()
	box.custom_minimum_size.x = 150
	parent.add_child(box)

	var title_lbl := Label.new()
	title_lbl.text = "%s quote" % title
	title_lbl.add_theme_color_override("font_color", Color(0.94, 0.78, 0.45))
	box.add_child(title_lbl)

	var total_lbl := Label.new()
	total_lbl.text = "Total %.1fg" % total
	box.add_child(total_lbl)

	var avg_lbl := Label.new()
	avg_lbl.text = "Avg %.1fg  |  Max %d" % [avg, max_qty]
	avg_lbl.add_theme_font_size_override("font_size", 11)
	box.add_child(avg_lbl)

func _add_plain_info(parent: HBoxContainer, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = 130
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)

func _select_item(item: String) -> void:
	selected_item = item
	trade_qty = 1
	build()

func _select_item_and_open_trade(item: String) -> void:
	selected_item = item
	market_view = "trade"
	trade_qty = 1
	build()

func _set_market_view(view: String) -> void:
	market_view = view
	build()

func _set_qty_and_rebuild(qty: int) -> void:
	trade_qty = maxi(qty, 1)
	build()

func _on_qty_changed(value: float) -> void:
	trade_qty = maxi(1, int(round(value)))
	build()

func _on_buy(item: String, qty: int) -> void:
	_economy.player_buy(town_name, item, qty)
	var faction: String = String(_economy.get_town(town_name).get("faction", ""))
	_faction.apply_trade_reputation(faction, _economy.get_price(town_name, item) * qty)
	build()

func _on_sell(item: String, qty: int) -> void:
	_economy.player_sell(town_name, item, qty)
	var faction: String = String(_economy.get_town(town_name).get("faction", ""))
	_faction.apply_trade_reputation(faction, _economy.get_price(town_name, item) * qty)
	build()

func _get_first_item() -> String:
	var keys: Array = _economy.BASE_PRICES.keys()
	if keys.is_empty():
		return ""
	return String(keys[0])

func _get_item_name(item: String) -> String:
	if _economy.items_data.has(item):
		var display: String = String(_economy.items_data[item].display_name)
		if display != "":
			return display
	return item.capitalize()

func _get_price_signal_text(item: String) -> String:
	var base: float = float(_economy.BASE_PRICES.get(item, 0.0))
	if base <= 0.0:
		return "...."
	var ratio: float = float(_economy.get_price(town_name, item)) / base
	if ratio >= 1.6:
		return "++++"
	if ratio >= 1.15:
		return "+++."
	if ratio >= 0.85:
		return "...."
	if ratio >= 0.55:
		return "---."
	return "----"

func _get_price_signal_color(item: String) -> Color:
	var base: float = float(_economy.BASE_PRICES.get(item, 0.0))
	if base <= 0.0:
		return Color(0.7, 0.7, 0.7)
	var ratio: float = float(_economy.get_price(town_name, item)) / base
	if ratio >= 1.15:
		return Color(0.45, 1.0, 0.45)
	if ratio <= 0.85:
		return Color(1.0, 0.45, 0.35)
	return Color(0.72, 0.66, 0.52)

func _profit_color(value: float) -> Color:
	if value > 0.1:
		return Color(0.4, 1.0, 0.4)
	if value < -0.1:
		return Color(1.0, 0.4, 0.4)
	return Color(0.7, 0.7, 0.7)

func _get_projection_signal_text(net: int, need: int) -> String:
	if need <= 0:
		return "...."
	var ratio: float = float(net) / float(maxi(need, 1))
	if ratio < -0.75:
		return "----"
	if ratio < -0.25:
		return "---."
	if ratio < 0.25:
		return "...."
	if ratio < 0.75:
		return "+++."
	return "++++"

func _get_projection_signal_color(net: int, need: int) -> Color:
	if need <= 0:
		return Color(0.72, 0.66, 0.52)
	if net < 0:
		return Color(1.0, 0.45, 0.35)
	if net > need:
		return Color(0.45, 1.0, 0.45)
	return Color(0.94, 0.78, 0.45)

func _format_quote_cell(value: float) -> String:
	if value <= 0.0:
		return "-"
	return "%.1fg" % value

func _get_max_affordable_buy(item: String, max_qty: int) -> int:
	for qty in range(max_qty, 0, -1):
		if _economy.get_buy_quote_total(town_name, item, qty) <= _player.gold:
			return qty
	return 0

func _format_trade_quote_tooltip(action: String, qty: int, total: float) -> String:
	if qty <= 0:
		return "%s 0 units" % action
	return "%s %d units\nTotal: %.1fg\nAverage: %.1fg" % [
		action,
		qty,
		total,
		total / float(qty),
	]

func _add_header_label(parent: HBoxContainer, text: String, width: int) -> void:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = width
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5))
	parent.add_child(label)

func _add_value_label(parent: HBoxContainer, text: String, width: int) -> void:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = width
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	parent.add_child(label)

func _add_projection_value_label(parent: HBoxContainer, text: String, width: int, danger: bool) -> void:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = width
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if danger:
		label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	else:
		label.add_theme_color_override("font_color", Color(0.9, 0.82, 0.62))
	parent.add_child(label)
