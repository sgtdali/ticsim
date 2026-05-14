extends TownTab

func build() -> void:
	var container = panel.get_node("ScrollContainer/ItemList")
	for child in container.get_children():
		child.queue_free()

	var town = _economy.get_town(town_name)
	var inventory = town.get("inventory", {})

	var prosperity = _economy.get_prosperity(town_name)
	var label = _economy.get_prosperity_label(town_name)
	var pop = town.get("population", 0)
	var threshold = _economy.PROSPERITY_LEVEL_3_THRESHOLD

	var status_lbl = Label.new()
	status_lbl.text = "%s — %s | Pop: %d | Prosperity: %d/%d" % [town_name, label, pop, prosperity, threshold]
	status_lbl.add_theme_font_size_override("font_size", 13)
	status_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	container.add_child(status_lbl)

	container.add_child(HSeparator.new())

	# Header
	var header = Label.new()
	header.text = "   %-14s %6s %10s %28s %28s" % ["Item", "Stock", "Ref", "Buy Options", "Sell Options"]
	header.add_theme_font_size_override("font_size", 12)
	header.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5))
	container.add_child(header)

	var separator = HSeparator.new()
	container.add_child(separator)

	# Player gold info
	var gold_lbl = Label.new()
	gold_lbl.text = "Your gold: %.1f  |  Cargo: %d/%d" % [
		_player.gold, _player.get_total_cargo(), _player.caravan_capacity
	]
	gold_lbl.add_theme_color_override("font_color", Color(0.9, 0.82, 0.4))
	container.add_child(gold_lbl)

	var sep2 = HSeparator.new()
	container.add_child(sep2)

	for item in _economy.BASE_PRICES:
		var town_stock = inventory.get(item, 0)
		var price = _economy.get_price(town_name, item)
		var player_has = _player.get_item_count(item)
		var town_free_stock = _economy.get_town_free_stock(town_name, item)
		
		var free_cap = _player.get_free_capacity()

		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)

		var name_lbl = Label.new()
		name_lbl.text = item.capitalize()
		name_lbl.custom_minimum_size.x = 100
		row.add_child(name_lbl)

		var stock_lbl = Label.new()
		stock_lbl.text = str(town_stock)
		stock_lbl.custom_minimum_size.x = 40
		row.add_child(stock_lbl)

		var price_lbl = Label.new()
		price_lbl.text = "Ref %.1fg" % price
		price_lbl.tooltip_text = "Reference price. Actual buy/sell uses spread and marginal stock quotes."
		price_lbl.custom_minimum_size.x = 76
		row.add_child(price_lbl)

		# --- Buy Buttons ---
		var buy_container = HBoxContainer.new()
		buy_container.add_theme_constant_override("separation", 4)
		row.add_child(buy_container)

		for qty in [1, 5, -1]:
			var btn = Button.new()
			var b_qty = qty
			if qty == -1:
				b_qty = _get_max_affordable_buy(item, mini(town_stock, free_cap))
				btn.text = "Buy MAX"
			else:
				btn.text = "Buy %d" % qty
			
			var buy_total: float = _economy.get_buy_quote_total(town_name, item, b_qty)
			btn.tooltip_text = _format_trade_quote_tooltip("Buy", b_qty, buy_total)
			btn.disabled = (b_qty <= 0 or town_stock < b_qty or _player.gold < buy_total or free_cap < b_qty)
				
			ui.apply_primary_button_style(btn)
			btn.custom_minimum_size = Vector2(72, 34)
			btn.add_theme_font_size_override("font_size", 11)
			btn.pressed.connect(_on_buy.bind(item, b_qty))
			buy_container.add_child(btn)

		# --- Sell Buttons ---
		var sell_container = HBoxContainer.new()
		sell_container.add_theme_constant_override("separation", 4)
		row.add_child(sell_container)

		for qty in [1, 5, -1]:
			var btn = Button.new()
			var s_qty = qty
			if qty == -1:
				s_qty = clampi(int(min(player_has, town_free_stock)), 0, 999)
				btn.text = "Sell MAX"
			else:
				btn.text = "Sell %d" % qty
			
			var sell_total: float = _economy.get_sell_quote_total(town_name, item, s_qty)
			btn.tooltip_text = _format_trade_quote_tooltip("Sell", s_qty, sell_total)
			btn.disabled = (s_qty <= 0 or player_has < s_qty or town_free_stock < s_qty)
			if qty == 5 and (player_has < 5 or town_free_stock < 5):
				btn.disabled = true
				
			ui.apply_secondary_button_style(btn)
			btn.custom_minimum_size = Vector2(72, 34)
			btn.add_theme_font_size_override("font_size", 11)
			btn.pressed.connect(_on_sell.bind(item, s_qty))
			sell_container.add_child(btn)

		var info_box = HBoxContainer.new()
		info_box.add_theme_constant_override("separation", 6)
		row.add_child(info_box)

		var has_lbl = Label.new()
		has_lbl.text = "x%d" % player_has
		has_lbl.add_theme_font_size_override("font_size", 11)
		has_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		info_box.add_child(has_lbl)

		if player_has > 0 and _player.purchase_prices.has(item):
			var buy_avg: float = _player.purchase_prices[item]
			var quote_qty: int = mini(player_has, town_free_stock)
			if quote_qty <= 0:
				container.add_child(row)
				continue
			var current_sell_price: float = _economy.get_sell_quote_average(town_name, item, quote_qty)
			var diff := float(current_sell_price - buy_avg)
			
			var profit_lbl = Label.new()
			profit_lbl.text = " | buy avg: %.1fg | sell avg: %.1fg | %+.1fg" % [buy_avg, current_sell_price, diff]
			profit_lbl.tooltip_text = "Sell avg is the average quote for selling your current stack here, not the reference price."
			profit_lbl.add_theme_font_size_override("font_size", 10)
			
			if diff > 0.1:
				profit_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4)) # Green
			elif diff < -0.1:
				profit_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4)) # Red
			else:
				profit_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7)) # Grey
				
			info_box.add_child(profit_lbl)

		container.add_child(row)

func _on_buy(item: String, qty: int) -> void:
	_economy.player_buy(town_name, item, qty)
	var faction = _economy.get_town(town_name).get("faction", "")
	_faction.apply_trade_reputation(faction, _economy.get_price(town_name, item) * qty)
	build()

func _on_sell(item: String, qty: int) -> void:
	_economy.player_sell(town_name, item, qty)
	var faction = _economy.get_town(town_name).get("faction", "")
	_faction.apply_trade_reputation(faction, _economy.get_price(town_name, item) * qty)
	build()

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
