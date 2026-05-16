extends TownTab

var selected_item: String = ""
var trade_qty: int = 1
var market_view: String = "trade"

const GOODS_PROJECTION_DAYS := 14
const TRADE_BUTTON_TEXT := Color(0.878431, 0.780392, 0.505882)
const TRADE_BUTTON_TEXT_HOVER := Color(0.933333, 0.839216, 0.580392)
const TRADE_BUTTON_TEXT_DISABLED := Color(0.42, 0.36, 0.27, 0.85)
const TRADE_BUTTON_OUTLINE := Color(0.062745, 0.043137, 0.023529)
const TRADE_BUTTON_SHADOW := Color(0.0, 0.0, 0.0, 0.68)
const PANEL_BG := Color(0.085, 0.067, 0.047, 0.98)
const PANEL_INSET_BG := Color(0.036, 0.031, 0.026, 1.0)
const PANEL_BORDER_DARK := Color(0.045, 0.030, 0.017, 1.0)
const PANEL_BORDER_BRASS := Color(0.48, 0.34, 0.15, 0.78)
const PANEL_HIGHLIGHT := Color(0.70, 0.50, 0.24, 0.16)
const LABEL_MUTED_GOLD := Color(0.70, 0.56, 0.34)
const VALUE_PARCHMENT := Color(0.88, 0.80, 0.58)
const TITLE_PARCHMENT := Color(0.92, 0.82, 0.56)
const BODY_SHADOW := Color(0.0, 0.0, 0.0, 0.64)

func build() -> void:
	panel.offset_right = 760.0
	panel.offset_bottom = -10.0

	var trade_host := _get_trade_panel_host()
	var container: VBoxContainer = panel.get_node("ScrollContainer/ItemList") as VBoxContainer
	for child in container.get_children():
		child.queue_free()
	for child in trade_host.get_children():
		child.queue_free()
	trade_host.visible = false

	if selected_item == "" or not _economy.BASE_PRICES.has(selected_item):
		selected_item = _get_first_item()
	trade_qty = maxi(trade_qty, 1)

	_build_view_switch(container)
	if market_view == "goods":
		_build_goods_projection_view(container)
		return

	_build_trade_table(container)

	trade_host.visible = true
	_build_trade_panel(trade_host)

func _get_trade_panel_host() -> VBoxContainer:
	var host := panel.get_node_or_null("TradePanelHost") as VBoxContainer
	if host == null:
		host = VBoxContainer.new()
		host.name = "TradePanelHost"
		host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		host.size_flags_vertical = Control.SIZE_SHRINK_END
		host.add_theme_constant_override("separation", 0)
		panel.add_child(host)
	return host

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

	var panel := _make_trade_section()
	container.add_child(panel)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	panel.add_child(root)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 12)
	root.add_child(top_row)

	var item_box := _make_framed_panel(Vector2(220, 70), true)
	top_row.add_child(item_box)
	var item_vbox := VBoxContainer.new()
	item_vbox.add_theme_constant_override("separation", 2)
	item_box.add_child(item_vbox)
	_add_panel_label(item_vbox, "Selected Good")
	_add_panel_value(item_vbox, _get_item_name(item), 24, TITLE_PARCHMENT)

	top_row.add_child(_make_stat_box("Reference Price", "%.1fg" % float(_economy.get_price(town_name, item))))
	top_row.add_child(_make_stat_box("City Stock", "%d" % town_stock))
	top_row.add_child(_make_stat_box("Cargo", "%d" % player_has))

	var middle_row := HBoxContainer.new()
	middle_row.add_theme_constant_override("separation", 14)
	root.add_child(middle_row)

	var qty_panel := _make_framed_panel(Vector2(300, 118), false)
	middle_row.add_child(qty_panel)
	var qty_vbox := VBoxContainer.new()
	qty_vbox.add_theme_constant_override("separation", 8)
	qty_panel.add_child(qty_vbox)

	var qty_header := HBoxContainer.new()
	qty_header.add_theme_constant_override("separation", 10)
	qty_vbox.add_child(qty_header)
	_add_panel_label(qty_header, "Quantity")

	var spin_box_panel := _make_inset_panel(Vector2(92, 38))
	qty_header.add_child(spin_box_panel)

	var slider := HSlider.new()
	slider.min_value = 1
	slider.max_value = max_qty
	slider.step = 1
	slider.value = trade_qty
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_qty_changed)
	_apply_market_slider_style(slider)

	var spin := SpinBox.new()
	spin.min_value = 1
	spin.max_value = max_qty
	spin.step = 1
	spin.value = trade_qty
	spin.custom_minimum_size = Vector2(84, 34)
	spin.value_changed.connect(_on_qty_changed)
	_apply_quantity_spin_style(spin)
	spin_box_panel.add_child(spin)

	var slider_frame := _make_inset_panel(Vector2(0, 44))
	slider_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	qty_vbox.add_child(slider_frame)
	slider_frame.add_child(slider)

	var max_row := HBoxContainer.new()
	max_row.add_theme_constant_override("separation", 8)
	qty_vbox.add_child(max_row)

	var max_buy_btn := Button.new()
	max_buy_btn.text = "Max Buy"
	max_buy_btn.disabled = max_buy <= 0
	max_buy_btn.pressed.connect(_set_qty_and_rebuild.bind(max_buy))
	apply_market_small_button_style(max_buy_btn)
	max_row.add_child(max_buy_btn)

	var max_sell_btn := Button.new()
	max_sell_btn.text = "Max Sell"
	max_sell_btn.disabled = max_sell <= 0
	max_sell_btn.pressed.connect(_set_qty_and_rebuild.bind(max_sell))
	apply_market_small_button_style(max_sell_btn)
	max_row.add_child(max_sell_btn)

	var quote_row := HBoxContainer.new()
	quote_row.add_theme_constant_override("separation", 12)
	quote_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle_row.add_child(quote_row)

	var buy_total: float = float(_economy.get_buy_quote_total(town_name, item, trade_qty))
	var sell_total: float = float(_economy.get_sell_quote_total(town_name, item, trade_qty))
	var buy_avg: float = buy_total / float(trade_qty) if trade_qty > 0 else 0.0
	var sell_avg: float = sell_total / float(trade_qty) if trade_qty > 0 else 0.0
	var stored_avg: float = float(_player.purchase_prices.get(item, 0.0))

	_add_quote_block(quote_row, "Buy Quote", buy_total, buy_avg, max_buy)
	_add_quote_block(quote_row, "Sell Quote", sell_total, sell_avg, max_sell)
	if player_has > 0 and stored_avg > 0.0:
		var diff: float = sell_avg - stored_avg
		var profit: float = diff * float(mini(trade_qty, max_sell))
		_add_plain_info(quote_row, "Held avg\n%.1fg\n%+.1fg" % [stored_avg, profit], _profit_color(diff))

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 12)
	root.add_child(action_row)

	var buy_btn := Button.new()
	buy_btn.text = "Buy"
	buy_btn.disabled = trade_qty <= 0 or trade_qty > max_buy
	buy_btn.tooltip_text = _format_trade_quote_tooltip("Buy", trade_qty, buy_total)
	buy_btn.pressed.connect(_on_buy.bind(item, trade_qty))
	apply_market_trade_button_style(buy_btn, true)
	action_row.add_child(buy_btn)

	var sell_btn := Button.new()
	sell_btn.text = "Sell"
	sell_btn.disabled = trade_qty <= 0 or trade_qty > max_sell
	sell_btn.tooltip_text = _format_trade_quote_tooltip("Sell", trade_qty, sell_total)
	sell_btn.pressed.connect(_on_sell.bind(item, trade_qty))
	apply_market_trade_button_style(sell_btn, false)
	action_row.add_child(sell_btn)

func _make_trade_section() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_panel_style(PANEL_BG, PANEL_BORDER_DARK, 3, 22.0, true))
	return panel

func _make_framed_panel(min_size: Vector2, emphasized: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if min_size.x <= 0.0 else Control.SIZE_SHRINK_BEGIN
	var bg := Color(0.135, 0.096, 0.058, 1.0) if emphasized else Color(0.066, 0.052, 0.039, 1.0)
	var border := PANEL_BORDER_BRASS.lightened(0.05) if emphasized else Color(0.31, 0.22, 0.105, 0.82)
	panel.add_theme_stylebox_override("panel", _make_panel_style(bg, border, 2, 14.0, true))
	return panel

func _make_inset_panel(min_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.add_theme_stylebox_override("panel", _make_panel_style(PANEL_INSET_BG, Color(0.16, 0.11, 0.065, 0.9), 2, 8.0, false))
	return panel

func _make_stat_box(title: String, value: String) -> PanelContainer:
	var box := _make_framed_panel(Vector2(124, 70), false)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	box.add_child(vbox)
	_add_panel_label(vbox, title)
	_add_panel_value(vbox, value, 20, VALUE_PARCHMENT)
	return box

func _make_panel_style(bg: Color, border: Color, border_width: int, padding: float, raised: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg.lightened(0.008 if raised else 0.0)
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width + (2 if raised else 1)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding * 0.82
	style.content_margin_bottom = padding * 0.82
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.66 if raised else 0.48)
	style.shadow_size = 3 if raised else 2
	style.shadow_offset = Vector2(0, 2 if raised else 1)
	style.expand_margin_left = 0.0
	style.expand_margin_right = 0.0
	style.expand_margin_top = 0.0
	style.expand_margin_bottom = 1.0 if raised else 0.0
	return style

func _add_panel_label(parent: Container, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.label_settings = _make_trade_label_settings(12, LABEL_MUTED_GOLD)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label

func _add_panel_value(parent: Container, text: String, font_size: int = 18, color: Color = VALUE_PARCHMENT) -> Label:
	var label := Label.new()
	label.text = text
	label.label_settings = _make_trade_label_settings(font_size, color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label

func _make_trade_label_settings(font_size: int, color: Color) -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = 1
	settings.outline_color = Color(0.055, 0.035, 0.018)
	settings.shadow_color = BODY_SHADOW
	settings.shadow_offset = Vector2(1.5, 1.5)
	return settings

func _apply_quantity_spin_style(spin: SpinBox) -> void:
	spin.add_theme_font_size_override("font_size", 16)
	spin.add_theme_color_override("font_color", VALUE_PARCHMENT)
	spin.add_theme_color_override("font_outline_color", TRADE_BUTTON_OUTLINE)
	spin.add_theme_constant_override("outline_size", 1)
	spin.add_theme_stylebox_override("normal", _make_input_style(false))
	spin.add_theme_stylebox_override("focus", _make_input_style(true))

func _make_input_style(focused: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_INSET_BG.lightened(0.014 if focused else 0.0)
	style.border_color = PANEL_BORDER_BRASS.lightened(0.04) if focused else Color(0.115, 0.080, 0.045, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 1
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

func _apply_market_slider_style(slider: HSlider) -> void:
	slider.custom_minimum_size = Vector2(0, 42)
	slider.add_theme_stylebox_override("slider", _make_slider_track_style(false))
	slider.add_theme_stylebox_override("grabber_area", _make_slider_track_style(true))
	slider.add_theme_stylebox_override("grabber_area_highlight", _make_slider_track_style(true))
	slider.add_theme_icon_override("grabber", _make_slider_grabber_texture(false))
	slider.add_theme_icon_override("grabber_highlight", _make_slider_grabber_texture(true))
	slider.add_theme_icon_override("grabber_disabled", _make_slider_grabber_texture(false))

func _make_slider_track_style(filled: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.275, 0.185, 0.085, 0.96) if filled else Color(0.018, 0.016, 0.014, 1.0)
	style.border_color = Color(0.52, 0.36, 0.15, 0.78) if filled else Color(0.075, 0.052, 0.032, 1.0)
	style.border_width_left = 2
	style.border_width_top = 3
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.48)
	style.shadow_size = 1
	style.shadow_offset = Vector2(0, 1)
	return style

func _make_slider_grabber_texture(highlighted: bool) -> Texture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.22, 0.62, 1.0])
	var top := Color(0.70, 0.48, 0.22) if highlighted else Color(0.54, 0.36, 0.16)
	var mid := Color(0.36, 0.235, 0.10) if highlighted else Color(0.27, 0.175, 0.075)
	var low := Color(0.11, 0.068, 0.030)
	gradient.colors = PackedColorArray([top, Color(0.40, 0.27, 0.12), mid, low])
	var texture := GradientTexture2D.new()
	texture.width = 20
	texture.height = 32
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.5, 0.0)
	texture.fill_to = Vector2(0.5, 1.0)
	texture.gradient = gradient
	return texture

func apply_market_small_button_style(button: Button) -> void:
	button.custom_minimum_size = Vector2(92, 32)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color(0.76, 0.65, 0.43))
	button.add_theme_color_override("font_hover_color", TRADE_BUTTON_TEXT_HOVER)
	button.add_theme_color_override("font_disabled_color", TRADE_BUTTON_TEXT_DISABLED)
	button.add_theme_color_override("font_outline_color", TRADE_BUTTON_OUTLINE)
	button.add_theme_constant_override("outline_size", 1)
	button.add_theme_stylebox_override("normal", _make_small_button_style("normal"))
	button.add_theme_stylebox_override("hover", _make_small_button_style("hover"))
	button.add_theme_stylebox_override("pressed", _make_small_button_style("pressed"))
	button.add_theme_stylebox_override("disabled", _make_small_button_style("disabled"))
	button.focus_mode = Control.FOCUS_NONE

func _make_small_button_style(state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 3
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.50)
	style.shadow_size = 2
	style.shadow_offset = Vector2(0, 2)
	var bg := Color(0.118, 0.082, 0.050, 1.0)
	var border := Color(0.36, 0.25, 0.115, 0.88)
	match state:
		"hover":
			bg = bg.lightened(0.08)
			border = border.lightened(0.10)
		"pressed":
			bg = bg.darkened(0.10)
			style.shadow_size = 1
			style.shadow_offset = Vector2(0, 1)
		"disabled":
			bg = Color(0.065, 0.055, 0.044, 0.94)
			border = Color(0.16, 0.13, 0.085, 0.55)
	style.bg_color = bg
	style.border_color = border
	return style

func apply_market_trade_button_style(button: Button, primary: bool) -> void:
	button.custom_minimum_size = Vector2(154, 60)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", TRADE_BUTTON_TEXT if primary else Color(0.78, 0.68, 0.47))
	button.add_theme_color_override("font_hover_color", TRADE_BUTTON_TEXT_HOVER)
	button.add_theme_color_override("font_pressed_color", Color(0.72, 0.55, 0.31))
	button.add_theme_color_override("font_disabled_color", TRADE_BUTTON_TEXT_DISABLED)
	button.add_theme_color_override("font_outline_color", TRADE_BUTTON_OUTLINE)
	button.add_theme_color_override("font_shadow_color", TRADE_BUTTON_SHADOW)
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_constant_override("shadow_offset_x", 2)
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.add_theme_stylebox_override("normal", _make_trade_button_style(primary, "normal"))
	button.add_theme_stylebox_override("hover", _make_trade_button_style(primary, "hover"))
	button.add_theme_stylebox_override("pressed", _make_trade_button_style(primary, "pressed"))
	button.add_theme_stylebox_override("disabled", _make_trade_button_style(primary, "disabled"))
	button.focus_mode = Control.FOCUS_NONE

func _make_trade_button_style(primary: bool, state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 5
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.62)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 3)

	var bg := Color(0.155, 0.085, 0.060)
	var border := Color(0.42, 0.235, 0.135, 0.90)
	if primary:
		bg = Color(0.285, 0.195, 0.100)
		border = Color(0.62, 0.425, 0.18, 0.94)

	match state:
		"hover":
			bg = bg.lightened(0.055)
			border = border.lightened(0.07)
		"pressed":
			bg = bg.darkened(0.13)
			border = border.darkened(0.10)
			style.border_width_top = 4
			style.border_width_bottom = 3
			style.shadow_size = 1
			style.shadow_offset = Vector2(0, 1)
		"disabled":
			bg = Color(0.075, 0.062, 0.048)
			border = Color(0.18, 0.145, 0.095, 0.58)

	style.bg_color = bg.lightened(0.006)
	style.border_color = border
	return style

func _add_quote_block(parent: HBoxContainer, title: String, total: float, avg: float, max_qty: int) -> void:
	var box := _make_framed_panel(Vector2(120, 118), false)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	box.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = title
	title_lbl.label_settings = _make_trade_label_settings(12, LABEL_MUTED_GOLD)
	vbox.add_child(title_lbl)

	var total_lbl := Label.new()
	total_lbl.text = "%.1fg" % total
	total_lbl.label_settings = _make_trade_label_settings(22, VALUE_PARCHMENT)
	vbox.add_child(total_lbl)

	var avg_lbl := Label.new()
	avg_lbl.text = "Avg %.1fg" % avg
	avg_lbl.label_settings = _make_trade_label_settings(12, Color(0.72, 0.64, 0.46))
	vbox.add_child(avg_lbl)

	var max_lbl := Label.new()
	max_lbl.text = "Max %d" % max_qty
	max_lbl.label_settings = _make_trade_label_settings(12, Color(0.66, 0.57, 0.40))
	vbox.add_child(max_lbl)

func _add_plain_info(parent: HBoxContainer, text: String, color: Color) -> void:
	var box := _make_framed_panel(Vector2(110, 118), false)
	parent.add_child(box)

	var label := Label.new()
	label.text = text
	label.label_settings = _make_trade_label_settings(13, color)
	box.add_child(label)

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
