extends TownTab

var selected_item: String = ""
var trade_qty: int = 1
var market_view: String = "trade"
var _current_max_buy: int = 0
var _current_max_sell: int = 0

const GOODS_PROJECTION_DAYS := 14
const TRADE_BUTTON_TEXT := Color(0.878431, 0.780392, 0.505882)
const TRADE_BUTTON_TEXT_HOVER := Color(0.933333, 0.839216, 0.580392)
const TRADE_BUTTON_TEXT_DISABLED := Color(0.42, 0.36, 0.27, 0.85)
const TRADE_BUTTON_OUTLINE := Color(0.062745, 0.043137, 0.023529)
const TRADE_BUTTON_SHADOW := Color(0.0, 0.0, 0.0, 0.68)
const PANEL_BG := Color(0.072, 0.056, 0.039, 0.99)
const PANEL_INSET_BG := Color(0.030, 0.026, 0.022, 1.0)
const PANEL_BORDER_DARK := Color(0.034, 0.022, 0.012, 1.0)
const PANEL_BORDER_BRASS := Color(0.50, 0.35, 0.15, 0.80)
const PANEL_HIGHLIGHT := Color(0.70, 0.50, 0.24, 0.13)
const LABEL_MUTED_GOLD := Color(0.72, 0.58, 0.35)
const VALUE_PARCHMENT := Color(0.90, 0.81, 0.58)
const TITLE_PARCHMENT := Color(0.94, 0.84, 0.58)
const BODY_SHADOW := Color(0.0, 0.0, 0.0, 0.64)
const ITEM_ICON_PATHS := {
	"bread": "res://assets/Icons/bread.png",
}
const BUY_BUTTON_TEXTURES := {
	"normal": "res://assets/ui/buy_button/not_pressed.png",
	"hover": "res://assets/ui/buy_button/hover.png",
	"pressed": "res://assets/ui/buy_button/pressed.png",
	"disabled": "res://assets/ui/buy_button/disabled.png",
}
const BUY_BUTTON_STYLES := {
	"normal": "res://assets/ui/buy_button/button_normal_style.tres",
	"hover": "res://assets/ui/buy_button/button_hover_style.tres",
	"pressed": "res://assets/ui/buy_button/button_pressed_style.tres",
	"disabled": "res://assets/ui/buy_button/button_disabled_style.tres",
}
const MARKET_BG_TEXTURE := "res://assets/ui/buy_button/market_bg.png"
const MARKET_BG_STYLE := "res://assets/ui/buy_button/market_bg_style.tres"
const MARKET_DIVIDER_TEXTURE := "res://assets/ui/buy_button/divider.png"
const MARKET_SEC_BG_STYLE := "res://assets/ui/buy_button/market_sec_bg_style.tres"
const MARKET_BOTTOM_BG_STYLE := "res://assets/ui/buy_button/market_bottom_bg_style.tres"
const MARKET_CLOSED_ROW_BG_STYLE := "res://assets/ui/market/market_closed_row_bg_style.tres"
const MARKET_OPENED_ROW_BG_STYLE := "res://assets/ui/market/market_opened_row_bg_style.tres"
const MARKET_BUY_BUTTON_STYLES := {
	"normal": "res://assets/ui/market/market_buy_button/market_buy_normal_style.tres",
	"hover": "res://assets/ui/market/market_buy_button/market_buy_hover_style.tres",
	"pressed": "res://assets/ui/market/market_buy_button/market_buy_pressed_style.tres",
	"disabled": "res://assets/ui/market/market_buy_button/market_buy_disabled_style.tres",
}
const MARKET_SELL_BUTTON_STYLES := {
	"normal": "res://assets/ui/market/market_sell_button/market_sell_normal_style.tres",
	"hover": "res://assets/ui/market/market_sell_button/market_sell_hover_style.tres",
	"pressed": "res://assets/ui/market/market_sell_button/market_sell_pressed_style.tres",
	"disabled": "res://assets/ui/market/market_sell_button/market_sell_disabled_style.tres",
}
const DOWN_BUTTON_UNPRESSED := "res://assets/ui/market/down_button_unpressed.png"
const DOWN_BUTTON_PRESSED := "res://assets/ui/market/down_button_pressed.png"

func build() -> void:
	if selected_item == "" or not _economy.BASE_PRICES.has(selected_item):
		selected_item = _get_first_item()
	trade_qty = maxi(trade_qty, 1)

	_build_market_hall_layout()

func _build_market_hall_layout() -> void:
	_prepare_market_panel()
	var root := panel.get_node_or_null("MarketHallFrame/MarketHallRoot") as VBoxContainer
	if root == null:
		return

	_update_market_hall_static(root)

	var trade_visible := market_view == "trade"
	var goods_visible := market_view == "goods"
	var city_visible := market_view == "city_info"

	_set_node_visible(root, "TownStrip", trade_visible)
	_set_node_visible(root, "TradeTableHeader", trade_visible)
	_set_node_visible(root, "MarketRowsScroll", trade_visible)
	_set_node_visible(root, "GoodsProjection", goods_visible)
	_set_node_visible(root, "CityInfoPlaceholder", city_visible)

	if trade_visible:
		var list := root.get_node("MarketRowsScroll/MarketRows") as VBoxContainer
		for child in list.get_children():
			child.queue_free()
		for item in _economy.BASE_PRICES:
			_add_market_trade_row(list, String(item))
	elif goods_visible:
		var goods := root.get_node("GoodsProjection") as VBoxContainer
		for child in goods.get_children():
			child.queue_free()
		_build_goods_projection_view(goods)
	elif city_visible:
		var label := root.get_node_or_null("CityInfoPlaceholder/CityInfoLabel") as Label
		if label != null:
			label.text = "%s city information layout will live here." % town_name

func _prepare_market_panel() -> void:
	panel.visible = true

func _update_market_hall_static(root: VBoxContainer) -> void:
	var town: Dictionary = _economy.get_town(town_name)
	_apply_market_hall_styles(root)
	_connect_market_hall_button(panel, "CloseButton", Callable(ui, "_on_close"))
	_connect_market_hall_tab(root, "MarketTabs/TabRow/TradeTab", "trade")
	_connect_market_hall_tab(root, "MarketTabs/TabRow/GoodsTab", "goods")
	_connect_market_hall_tab(root, "MarketTabs/TabRow/CityInfoTab", "city_info")

	var title := root.get_node_or_null("MarketHeader/HeaderRow/Title") as Label
	if title != null:
		title.label_settings = _make_trade_label_settings(36, TITLE_PARCHMENT)
	var town_label := root.get_node_or_null("TownStrip/TownRow/TownInfo/TownNameLabel") as Label
	if town_label != null:
		town_label.text = town_name
		town_label.label_settings = _make_trade_label_settings(29, TITLE_PARCHMENT)
	var meta := root.get_node_or_null("TownStrip/TownRow/TownInfo/MetaLabel") as Label
	if meta != null:
		meta.text = "%s    Pop %d    %s" % [
			String(town.get("faction", "")),
			int(town.get("population", 0)),
			_reputation_text(String(town.get("faction", "")))
		]
		meta.label_settings = _make_trade_label_settings(15, VALUE_PARCHMENT)
	var cargo_total := int(_player.get_total_cargo())
	var capacity := int(_player.caravan_capacity)
	var storage_value := root.get_node_or_null("TownStrip/TownRow/StorageInfo/StorageValue") as Label
	if storage_value != null:
		storage_value.text = "%d / %d" % [cargo_total, capacity]
		storage_value.label_settings = _make_trade_label_settings(25, TITLE_PARCHMENT)
	var cap_label := root.get_node_or_null("TownStrip/TownRow/StorageInfo/CargoCapacityLabel") as Label
	if cap_label != null:
		cap_label.text = "Cargo Capacity    %d" % capacity
		cap_label.label_settings = _make_trade_label_settings(14, VALUE_PARCHMENT)

func _set_node_visible(root: Node, path: String, value: bool) -> void:
	var node := root.get_node_or_null(path) as CanvasItem
	if node != null:
		node.visible = value

func _connect_market_hall_tab(root: Node, path: String, view: String) -> void:
	var button := root.get_node_or_null(path) as Button
	if button == null:
		return
	button.button_pressed = market_view == view
	apply_market_tab_button_style(button, market_view == view)
	var meta_key := "market_view_connected_%s" % view
	if not bool(button.get_meta(meta_key, false)):
		button.pressed.connect(_set_market_view.bind(view))
		button.set_meta(meta_key, true)

func _connect_market_hall_button(root: Node, path: String, callback: Callable) -> void:
	var button := root.get_node_or_null(path) as Button
	if button != null and not bool(button.get_meta("market_button_connected", false)):
		button.pressed.connect(callback)
		button.set_meta("market_button_connected", true)

func _apply_market_hall_styles(root: Node) -> void:
	_style_panel(root, "MarketHeader", Color(0.045, 0.043, 0.039, 1.0), Color(0.24, 0.18, 0.10, 0.95), 2, 8.0, true)
	_style_panel(root, "MarketTabs", Color(0.030, 0.029, 0.027, 1.0), Color(0.18, 0.13, 0.07, 0.92), 1, 4.0, false)
	_style_panel(root, "TownStrip/TownRow/TownImageSlot", Color(0.030, 0.029, 0.026, 1.0), Color(0.20, 0.15, 0.08, 0.90), 2, 8.0, false)
	_style_panel(root, "TownStrip/TownRow/StorageImageSlot", Color(0.030, 0.029, 0.026, 1.0), Color(0.20, 0.15, 0.08, 0.90), 2, 8.0, false)
	var header_node := root.get_node_or_null("TradeTableHeader") as PanelContainer
	if header_node != null:
		header_node.add_theme_stylebox_override("panel", load(MARKET_CLOSED_ROW_BG_STYLE))
	_style_panel(root, "CityInfoPlaceholder", Color(0.060, 0.055, 0.047, 1.0), Color(0.25, 0.18, 0.09, 0.90), 2, 24.0, true)
	var switch_btn := root.get_node_or_null("TownStrip/TownRow/SwitchButton") as Button
	if switch_btn != null:
		apply_market_small_button_style(switch_btn)
	_update_static_label(root, "MarketHeader/HeaderRow/Title", "Market Hall", 36, TITLE_PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_update_static_label(root, "TownStrip/TownRow/TownImageSlot/PlaceholderLabel", "Town Image", 14, Color(0.45, 0.39, 0.30), HORIZONTAL_ALIGNMENT_CENTER)
	_update_static_label(root, "TownStrip/TownRow/StorageImageSlot/PlaceholderLabel", "Market Storage", 14, Color(0.45, 0.39, 0.30), HORIZONTAL_ALIGNMENT_CENTER)
	_update_static_label(root, "TownStrip/TownRow/StorageInfo/StorageTitle", "Storage", 17, LABEL_MUTED_GOLD, HORIZONTAL_ALIGNMENT_LEFT)
	_update_static_label(root, "CityInfoPlaceholder/CityInfoLabel", "%s city information layout will live here." % town_name, 24, TITLE_PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_update_header_labels(root)

func _style_panel(root: Node, path: String, bg: Color, border: Color, border_width: int, padding: float, raised: bool) -> void:
	var panel_node := root.get_node_or_null(path) as PanelContainer
	if panel_node != null:
		panel_node.add_theme_stylebox_override("panel", _make_panel_style(bg, border, border_width, padding, raised))

func _update_static_label(root: Node, path: String, text: String, font_size: int, color: Color, align: int) -> void:
	var label := root.get_node_or_null(path) as Label
	if label == null:
		return
	label.text = text
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.label_settings = _make_trade_label_settings(font_size, color)

func _update_header_labels(root: Node) -> void:
	var labels := {
		"TradeTableHeader/HeaderCells/GoodsHeader": ["Goods", HORIZONTAL_ALIGNMENT_LEFT],
		"TradeTableHeader/HeaderCells/TrendHeader": ["Trend", HORIZONTAL_ALIGNMENT_CENTER],
		"TradeTableHeader/HeaderCells/StockHeader": ["City Stock", HORIZONTAL_ALIGNMENT_CENTER],
		"TradeTableHeader/HeaderCells/PriceHeader": ["Price", HORIZONTAL_ALIGNMENT_CENTER],
		"TradeTableHeader/HeaderCells/CargoHeader": ["Cargo", HORIZONTAL_ALIGNMENT_CENTER],
	}
	for path in labels:
		var data: Array = labels[path]
		_update_static_label(root, path, String(data[0]), 16, LABEL_MUTED_GOLD, int(data[1]))

func _add_market_trade_row(parent: VBoxContainer, item: String) -> void:
	var is_selected := item == selected_item
	parent.add_child(_make_market_compact_row(item, is_selected))
	if is_selected:
		parent.add_child(_make_market_expanded_row(item))

func _make_market_compact_row(item: String, is_selected: bool) -> Control:
	var row := PanelContainer.new()
	row.name = "Row_%s" % item
	row.custom_minimum_size.y = 62
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.gui_input.connect(_on_market_row_input.bind(item))
	if is_selected:
		row.add_theme_stylebox_override("panel", load(MARKET_OPENED_ROW_BG_STYLE))
	else:
		row.add_theme_stylebox_override("panel", load(MARKET_CLOSED_ROW_BG_STYLE))

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 0)
	row.add_child(hbox)

	var data := _get_trade_table_row_data(item)
	_add_good_row_cell(hbox, item, data, 0.36)
	_add_value_row_cell(hbox, String(data.get("trend", "")), 0.12, _get_price_signal_color(item), HORIZONTAL_ALIGNMENT_CENTER, 28)
	_add_value_row_cell(hbox, String(data.get("city_stock", "0")), 0.16, VALUE_PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER, 23)
	_add_value_row_cell(hbox, "%.0f" % float(_economy.get_price(town_name, item)), 0.16, VALUE_PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER, 23)
	_add_value_row_cell(hbox, String(data.get("cargo", "0")), 0.16, VALUE_PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER, 23)
	_add_arrow_row_cell(hbox, is_selected)
	return row

func _add_good_row_cell(parent: HBoxContainer, item: String, data: Dictionary, stretch: float) -> void:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_stretch_ratio = stretch
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 8)
	parent.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	var icon_slot := _make_inset_panel(Vector2(58, 48))
	row.add_child(icon_slot)
	var texture := _get_item_icon_texture(item)
	if texture != null:
		var center := CenterContainer.new()
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon_slot.add_child(center)
		center.add_child(_make_market_item_icon_stack(texture, 40))

	var label := Label.new()
	label.text = String(data.get("good", _get_item_name(item)))
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.label_settings = _make_trade_label_settings(24, TITLE_PARCHMENT)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

func _add_value_row_cell(parent: HBoxContainer, text: String, stretch: float, color: Color, align: int, font_size: int) -> void:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_stretch_ratio = stretch
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	parent.add_child(margin)

	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.label_settings = _make_trade_label_settings(font_size, color)
	margin.add_child(label)

func _add_arrow_row_cell(parent: HBoxContainer, is_selected: bool) -> void:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_stretch_ratio = 0.04
	parent.add_child(margin)
	var center := CenterContainer.new()
	margin.add_child(center)
	var tex := TextureRect.new()
	tex.texture = load(DOWN_BUTTON_PRESSED if is_selected else DOWN_BUTTON_UNPRESSED)
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	center.add_child(tex)

func _make_market_expanded_row(item: String) -> Control:
	var panel_box := PanelContainer.new()
	panel_box.name = "Expanded_%s" % item
	panel_box.custom_minimum_size.y = 156
	panel_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_box.add_theme_stylebox_override("panel", load(MARKET_OPENED_ROW_BG_STYLE))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	panel_box.add_child(row)

	var texture := _get_item_icon_texture(item)
	var hero := _make_placeholder_panel(Vector2(250, 126), "")
	row.add_child(hero)
	if texture != null:
		var center := CenterContainer.new()
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hero.add_child(center)
		center.add_child(_make_market_item_icon_stack(texture, 108))

	var info := VBoxContainer.new()
	info.custom_minimum_size = Vector2(210, 126)
	info.add_theme_constant_override("separation", 6)
	row.add_child(info)
	var name_lbl := Label.new()
	name_lbl.text = _get_item_name(item)
	name_lbl.label_settings = _make_trade_label_settings(29, TITLE_PARCHMENT)
	info.add_child(name_lbl)
	var category := Label.new()
	category.text = "Market commodity"
	category.label_settings = _make_trade_label_settings(16, VALUE_PARCHMENT)
	info.add_child(category)

	var town: Dictionary = _economy.get_town(town_name)
	var stock := int(town.get("inventory", {}).get(item, 0))
	var cargo := int(_player.get_item_count(item))
	row.add_child(_make_expanded_stat("Ref. Price", "%.1f" % float(_economy.get_price(town_name, item))))
	row.add_child(_make_expanded_stat("City Stock", "%d" % stock))
	row.add_child(_make_expanded_stat("Cargo", "%d" % cargo))

	var qty_panel := _make_expanded_quantity_panel(item)
	row.add_child(qty_panel)

	var value_panel := _make_total_value_panel(item)
	row.add_child(value_panel)

	var action_col := VBoxContainer.new()
	action_col.custom_minimum_size = Vector2(170, 126)
	action_col.add_theme_constant_override("separation", 12)
	row.add_child(action_col)

	var buy_btn := Button.new()
	buy_btn.text = "Buy"
	buy_btn.disabled = trade_qty <= 0 or trade_qty > _current_max_buy
	buy_btn.tooltip_text = _format_trade_quote_tooltip("Buy", trade_qty, float(_economy.get_buy_quote_total(town_name, item, trade_qty)))
	buy_btn.pressed.connect(_on_buy.bind(item, trade_qty))
	apply_market_trade_button_style(buy_btn, true)
	buy_btn.custom_minimum_size = Vector2(158, 52)
	action_col.add_child(buy_btn)

	var sell_btn := Button.new()
	sell_btn.text = "Sell"
	sell_btn.disabled = trade_qty <= 0 or trade_qty > _current_max_sell
	sell_btn.tooltip_text = _format_trade_quote_tooltip("Sell", trade_qty, float(_economy.get_sell_quote_total(town_name, item, trade_qty)))
	sell_btn.pressed.connect(_on_sell.bind(item, trade_qty))
	apply_market_trade_button_style(sell_btn, false)
	sell_btn.custom_minimum_size = Vector2(158, 52)
	action_col.add_child(sell_btn)
	return panel_box

func _make_expanded_stat(title: String, value: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(120, 126)
	box.add_theme_constant_override("separation", 8)
	var title_lbl := Label.new()
	title_lbl.text = title
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.label_settings = _make_trade_label_settings(15, LABEL_MUTED_GOLD)
	box.add_child(title_lbl)
	var value_lbl := Label.new()
	value_lbl.text = value
	value_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_lbl.label_settings = _make_trade_label_settings(25, TITLE_PARCHMENT)
	box.add_child(value_lbl)
	return box

func _make_expanded_quantity_panel(item: String) -> VBoxContainer:
	var town: Dictionary = _economy.get_town(town_name)
	var town_stock: int = int(town.get("inventory", {}).get(item, 0))
	var player_has: int = int(_player.get_item_count(item))
	var town_free_stock: int = int(_economy.get_town_free_stock(town_name, item))
	var free_cap: int = int(_player.get_free_capacity())
	_current_max_buy = _get_max_affordable_buy(item, mini(town_stock, free_cap))
	_current_max_sell = mini(player_has, town_free_stock)
	var max_qty: int = maxi(1, maxi(_current_max_buy, _current_max_sell))
	trade_qty = clampi(trade_qty, 1, max_qty)

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(240, 126)
	box.add_theme_constant_override("separation", 8)
	var title := Label.new()
	title.text = "Quantity"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.label_settings = _make_trade_label_settings(16, LABEL_MUTED_GOLD)
	box.add_child(title)

	var controls := HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 10)
	box.add_child(controls)

	var minus := Button.new()
	minus.text = "-"
	minus.custom_minimum_size = Vector2(42, 36)
	minus.pressed.connect(_set_qty_and_rebuild.bind(trade_qty - 1))
	apply_market_small_button_style(minus)
	controls.add_child(minus)

	var qty := SpinBox.new()
	qty.custom_minimum_size = Vector2(84, 36)
	qty.min_value = 1
	qty.max_value = max_qty
	qty.value = trade_qty
	qty.value_changed.connect(_on_qty_changed)
	_apply_quantity_spin_style(qty)
	controls.add_child(qty)

	var plus := Button.new()
	plus.text = "+"
	plus.custom_minimum_size = Vector2(42, 36)
	plus.pressed.connect(_set_qty_and_rebuild.bind(trade_qty + 1))
	apply_market_small_button_style(plus)
	controls.add_child(plus)

	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(210, 36)
	slider.min_value = 1
	slider.max_value = max_qty
	slider.value = trade_qty
	slider.value_changed.connect(_on_qty_changed)
	_apply_market_slider_style(slider)
	box.add_child(slider)
	return box

func _make_total_value_panel(item: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(180, 126)
	box.add_theme_constant_override("separation", 6)
	var title := Label.new()
	title.text = "Total Value"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.label_settings = _make_trade_label_settings(16, LABEL_MUTED_GOLD)
	box.add_child(title)

	var total := Label.new()
	var buy_total := float(_economy.get_buy_quote_total(town_name, item, trade_qty))
	total.text = "%.1f" % buy_total
	total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total.label_settings = _make_trade_label_settings(27, TITLE_PARCHMENT)
	box.add_child(total)

	var unit := Label.new()
	var avg := float(_economy.get_buy_quote_average(town_name, item, trade_qty))
	unit.text = "%.1f per unit" % avg
	unit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unit.label_settings = _make_trade_label_settings(14, VALUE_PARCHMENT)
	box.add_child(unit)
	return box

func _build_goods_projection_screen(parent: VBoxContainer) -> void:
	var content := VBoxContainer.new()
	content.name = "GoodsProjection"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	parent.add_child(content)
	_build_goods_projection_view(content)

func _build_city_info_screen(parent: VBoxContainer) -> void:
	var panel_box := PanelContainer.new()
	panel_box.name = "CityInfoPlaceholder"
	panel_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_box.add_theme_stylebox_override("panel", _make_panel_style(Color(0.060, 0.055, 0.047, 1.0), Color(0.25, 0.18, 0.09, 0.90), 2, 24.0, true))
	parent.add_child(panel_box)
	var label := Label.new()
	label.text = "%s city information layout will live here." % town_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.label_settings = _make_trade_label_settings(24, TITLE_PARCHMENT)
	panel_box.add_child(label)

func _make_placeholder_panel(min_size: Vector2, text: String) -> PanelContainer:
	var box := PanelContainer.new()
	box.custom_minimum_size = min_size
	box.add_theme_stylebox_override("panel", _make_panel_style(Color(0.030, 0.029, 0.026, 1.0), Color(0.20, 0.15, 0.08, 0.90), 2, 8.0, false))
	if text != "":
		var label := Label.new()
		label.text = text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.label_settings = _make_trade_label_settings(14, Color(0.45, 0.39, 0.30))
		box.add_child(label)
	return box

func _make_market_item_icon_stack(texture: Texture2D, icon_size: int) -> Control:
	var stack := Control.new()
	stack.custom_minimum_size = Vector2(icon_size + 10, icon_size + 10)

	var shadow := TextureRect.new()
	shadow.modulate = Color(0.0, 0.0, 0.0, 0.34)
	shadow.texture = texture
	shadow.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shadow.offset_left = 3
	shadow.offset_top = 4
	shadow.offset_right = 3
	shadow.offset_bottom = 4
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(shadow)

	var icon := TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 5
	icon.offset_top = 4
	icon.offset_right = -5
	icon.offset_bottom = -6
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(icon)
	return stack

func _make_icon_text_button(text: String, min_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	apply_market_small_button_style(button)
	return button

func _on_market_row_input(event: InputEvent, item: String) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		_select_item(item)

func _reputation_text(faction: String) -> String:
	if _faction != null and _faction.has_method("get_reputation_label"):
		return String(_faction.get_reputation_label(faction))
	return "Reputable"

func _ensure_market_layout() -> Dictionary:
	var frame := panel.get_node_or_null("MarketFrame") as PanelContainer
	var body: VBoxContainer
	if frame == null:
		var scroll := panel.get_node("ScrollContainer") as ScrollContainer
		panel.remove_child(scroll)

		frame = PanelContainer.new()
		frame.name = "MarketFrame"
		frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
		frame.add_theme_stylebox_override("panel", _make_market_frame_style())
		panel.add_child(frame)

		body = VBoxContainer.new()
		body.name = "MarketBody"
		body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body.size_flags_vertical = Control.SIZE_EXPAND_FILL
		body.add_theme_constant_override("separation", 0)
		frame.add_child(body)

		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		body.add_child(scroll)
	else:
		body = frame.get_node("MarketBody") as VBoxContainer
		frame.add_theme_stylebox_override("panel", _make_market_frame_style())

	var host := body.get_node_or_null("TradePanelHost") as VBoxContainer
	if host == null:
		host = VBoxContainer.new()
		host.name = "TradePanelHost"
		host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		host.size_flags_vertical = Control.SIZE_SHRINK_END
		host.add_theme_constant_override("separation", 0)
		body.add_child(host)

	return {
		"item_list": body.get_node("ScrollContainer/ItemList"),
		"trade_host": host,
	}

func _make_market_frame_style() -> StyleBox:
	return _make_market_bg_style()

func _build_view_switch(container: VBoxContainer) -> void:
	var strip := PanelContainer.new()
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.add_theme_stylebox_override("panel", _make_panel_style(Color(0.060, 0.047, 0.034, 1.0), Color(0.31, 0.22, 0.10, 0.82), 2, 8.0, true))
	container.add_child(strip)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	strip.add_child(row)

	var trade_btn := Button.new()
	trade_btn.text = "Trade"
	trade_btn.toggle_mode = true
	trade_btn.button_pressed = market_view == "trade"
	trade_btn.custom_minimum_size = Vector2(150, 44)
	trade_btn.pressed.connect(_set_market_view.bind("trade"))
	if market_view == "trade":
		apply_market_tab_button_style(trade_btn, true)
	else:
		apply_market_tab_button_style(trade_btn, false)
	row.add_child(trade_btn)

	var goods_btn := Button.new()
	goods_btn.text = "Goods"
	goods_btn.toggle_mode = true
	goods_btn.button_pressed = market_view == "goods"
	goods_btn.custom_minimum_size = Vector2(150, 44)
	goods_btn.pressed.connect(_set_market_view.bind("goods"))
	if market_view == "goods":
		apply_market_tab_button_style(goods_btn, true)
	else:
		apply_market_tab_button_style(goods_btn, false)
	row.add_child(goods_btn)

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
		"icon_path": _get_item_icon_path(item),
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
	_current_max_buy = max_buy
	_current_max_sell = max_sell
	var max_qty: int = maxi(1, maxi(max_buy, max_sell))
	trade_qty = clampi(trade_qty, 1, max_qty)
	var buy_total: float = float(_economy.get_buy_quote_total(town_name, item, trade_qty))
	var sell_total: float = float(_economy.get_sell_quote_total(town_name, item, trade_qty))
	var buy_avg: float = buy_total / float(trade_qty) if trade_qty > 0 else 0.0
	var sell_avg: float = sell_total / float(trade_qty) if trade_qty > 0 else 0.0
	var stored_avg: float = float(_player.purchase_prices.get(item, 0.0))
	var unit_profit: float = sell_avg - stored_avg if stored_avg > 0.0 else 0.0
	var total_profit: float = unit_profit * float(mini(trade_qty, max_sell)) if stored_avg > 0.0 else 0.0

	_ensure_trade_panel_skeleton(container)
	_populate_trade_panel_skeleton(container, item, player_has, town_stock, max_buy, max_sell, max_qty, buy_total, sell_total, buy_avg, sell_avg, unit_profit, total_profit, stored_avg > 0.0)
	return

	var panel := _make_trade_section()
	container.add_child(panel)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	panel.add_child(root)

	var main_row := HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 14)
	main_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(main_row)

	main_row.add_child(_make_selected_good_panel(item))

	var right_stack := VBoxContainer.new()
	right_stack.add_theme_constant_override("separation", 10)
	right_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_row.add_child(right_stack)

	var stat_row := HBoxContainer.new()
	stat_row.add_theme_constant_override("separation", 10)
	stat_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_stack.add_child(stat_row)
	stat_row.add_child(_make_stat_box("Reference Price", "%.1fg" % float(_economy.get_price(town_name, item))))
	stat_row.add_child(_make_stat_box("City Stock", "%d" % town_stock))
	stat_row.add_child(_make_stat_box("Cargo", "%d" % player_has))

	var trade_row := HBoxContainer.new()
	trade_row.add_theme_constant_override("separation", 10)
	trade_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_stack.add_child(trade_row)

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

	var max_buy_btn := Button.new()
	max_buy_btn.text = "Max Buy"
	max_buy_btn.disabled = max_buy <= 0
	max_buy_btn.pressed.connect(_set_qty_and_rebuild.bind(max_buy))
	apply_market_small_button_style(max_buy_btn)

	var max_sell_btn := Button.new()
	max_sell_btn.text = "Max Sell"
	max_sell_btn.disabled = max_sell <= 0
	max_sell_btn.pressed.connect(_set_qty_and_rebuild.bind(max_sell))
	apply_market_small_button_style(max_sell_btn)

	trade_row.add_child(_make_quantity_panel(slider, spin, max_buy_btn, max_sell_btn))
	_add_quote_block(trade_row, "Buy Quote", buy_total, buy_avg, max_buy)
	_add_quote_block(trade_row, "Sell Quote", sell_total, sell_avg, max_sell)
	_add_profit_block(trade_row, unit_profit, total_profit, stored_avg > 0.0)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 18)
	action_row.alignment = BoxContainer.ALIGNMENT_CENTER
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
	panel.name = "TradeSection"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_market_bottom_bg_style())
	return panel

func _ensure_trade_panel_skeleton(container: VBoxContainer) -> void:
	if not container.has_node("MarketDivider"):
		var divider := _make_market_divider()
		divider.name = "MarketDivider"
		container.add_child(divider)
	else:
		_ensure_market_divider_visuals(container.get_node("MarketDivider") as Control)
	if container.has_node("TradeSection"):
		_apply_trade_panel_styles(container)
		return

	var section := _make_trade_section()
	container.add_child(section)

	var root := VBoxContainer.new()
	root.name = "TradeRoot"
	root.add_theme_constant_override("separation", 12)
	section.add_child(root)

	var main_row := HBoxContainer.new()
	main_row.name = "MainRow"
	main_row.add_theme_constant_override("separation", 14)
	main_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(main_row)

	main_row.add_child(_make_selected_good_panel("bread"))

	var right_stack := VBoxContainer.new()
	right_stack.name = "RightStack"
	right_stack.add_theme_constant_override("separation", 10)
	right_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_row.add_child(right_stack)

	var stat_row := HBoxContainer.new()
	stat_row.name = "StatRow"
	stat_row.add_theme_constant_override("separation", 10)
	stat_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_stack.add_child(stat_row)
	stat_row.add_child(_make_stat_box("Reference Price", "0.0g"))
	stat_row.get_child(0).name = "ReferencePrice"
	stat_row.add_child(_make_stat_box("City Stock", "0"))
	stat_row.get_child(1).name = "CityStock"
	stat_row.add_child(_make_stat_box("Cargo", "0"))
	stat_row.get_child(2).name = "Cargo"

	var trade_row := HBoxContainer.new()
	trade_row.name = "TradeRow"
	trade_row.add_theme_constant_override("separation", 10)
	trade_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_stack.add_child(trade_row)

	var slider := HSlider.new()
	slider.name = "QuantitySlider"
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_market_slider_style(slider)

	var spin := SpinBox.new()
	spin.name = "QuantitySpin"
	spin.custom_minimum_size = Vector2(84, 34)
	_apply_quantity_spin_style(spin)

	var max_buy_btn := Button.new()
	max_buy_btn.name = "MaxBuyButton"
	max_buy_btn.text = "Max Buy"
	apply_market_small_button_style(max_buy_btn)

	var max_sell_btn := Button.new()
	max_sell_btn.name = "MaxSellButton"
	max_sell_btn.text = "Max Sell"
	apply_market_small_button_style(max_sell_btn)

	trade_row.add_child(_make_quantity_panel(slider, spin, max_buy_btn, max_sell_btn))
	trade_row.get_child(0).name = "QuantityPanel"
	_add_quote_block(trade_row, "Buy Quote", 0.0, 0.0, 0)
	trade_row.get_child(1).name = "BuyQuotePanel"
	_add_quote_block(trade_row, "Sell Quote", 0.0, 0.0, 0)
	trade_row.get_child(2).name = "SellQuotePanel"
	_add_profit_block(trade_row, 0.0, 0.0, false)
	trade_row.get_child(3).name = "ProfitEstimatePanel"

	var action_row := HBoxContainer.new()
	action_row.name = "ActionRow"
	action_row.add_theme_constant_override("separation", 18)
	action_row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(action_row)

	var buy_btn := Button.new()
	buy_btn.name = "BuyButton"
	buy_btn.text = "Buy"
	apply_market_trade_button_style(buy_btn, true)
	action_row.add_child(buy_btn)

	var sell_btn := Button.new()
	sell_btn.name = "SellButton"
	sell_btn.text = "Sell"
	apply_market_trade_button_style(sell_btn, false)
	action_row.add_child(sell_btn)

	_connect_trade_panel_signals(container)

func _apply_trade_panel_styles(container: VBoxContainer) -> void:
	var section := container.get_node("TradeSection") as PanelContainer
	section.add_theme_stylebox_override("panel", _make_market_bottom_bg_style())
	_style_market_sec_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/SelectedGoodPanel") as PanelContainer)
	_style_market_sec_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/StatRow/ReferencePrice") as PanelContainer)
	_style_market_sec_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/StatRow/CityStock") as PanelContainer)
	_style_market_sec_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/StatRow/Cargo") as PanelContainer)
	_style_framed_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel") as PanelContainer, false)
	_style_market_sec_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/BuyQuotePanel") as PanelContainer)
	_style_market_sec_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/SellQuotePanel") as PanelContainer)
	_style_market_sec_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/ProfitEstimatePanel") as PanelContainer)
	_style_inset_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/SelectedGoodPanel/SelectedGoodContent/IconSlot") as PanelContainer)
	_style_inset_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/Header/SpinBoxPanel") as PanelContainer)
	_style_inset_panel(container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/SliderFrame") as PanelContainer)
	var buy_btn := container.get_node_or_null("TradeSection/TradeRoot/ActionRow/BuyButton") as Button
	if buy_btn != null:
		apply_market_trade_button_style(buy_btn, true)
	var sell_btn := container.get_node_or_null("TradeSection/TradeRoot/ActionRow/SellButton") as Button
	if sell_btn != null:
		apply_market_trade_button_style(sell_btn, false)
	var max_buy_btn := container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/MaxRow/MaxBuyButton") as Button
	if max_buy_btn != null:
		apply_market_small_button_style(max_buy_btn)
	var max_sell_btn := container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/MaxRow/MaxSellButton") as Button
	if max_sell_btn != null:
		apply_market_small_button_style(max_sell_btn)
	var slider := container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/SliderFrame/QuantitySlider") as HSlider
	if slider != null:
		_apply_market_slider_style(slider)
	var spin := container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/Header/SpinBoxPanel/QuantitySpin") as SpinBox
	if spin != null:
		_apply_quantity_spin_style(spin)
	_connect_trade_panel_signals(container)

func _style_framed_panel(panel_node: PanelContainer, emphasized: bool) -> void:
	if panel_node == null:
		return
	var bg := Color(0.126, 0.088, 0.052, 1.0) if emphasized else Color(0.057, 0.045, 0.034, 1.0)
	var border := PANEL_BORDER_BRASS.lightened(0.035) if emphasized else Color(0.34, 0.235, 0.105, 0.84)
	panel_node.add_theme_stylebox_override("panel", _make_panel_style(bg, border, 2 if emphasized else 1, 14.0, true))

func _style_inset_panel(panel_node: PanelContainer) -> void:
	if panel_node == null:
		return
	panel_node.add_theme_stylebox_override("panel", _make_panel_style(PANEL_INSET_BG, Color(0.12, 0.083, 0.047, 0.96), 2, 8.0, false))

func _style_market_sec_panel(panel_node: PanelContainer) -> void:
	if panel_node == null:
		return
	var style := load(MARKET_SEC_BG_STYLE) as StyleBoxTexture
	if style != null:
		panel_node.add_theme_stylebox_override("panel", style.duplicate() as StyleBoxTexture)
	else:
		_style_framed_panel(panel_node, false)

func _populate_trade_panel_skeleton(container: VBoxContainer, item: String, player_has: int, town_stock: int, max_buy: int, max_sell: int, max_qty: int, buy_total: float, sell_total: float, buy_avg: float, sell_avg: float, unit_profit: float, total_profit: float, has_cost_basis: bool) -> void:
	var selected_panel := container.get_node("TradeSection/TradeRoot/MainRow/SelectedGoodPanel") as PanelContainer
	_update_selected_good_panel(selected_panel, item)
	_update_stat_box(container.get_node("TradeSection/TradeRoot/MainRow/RightStack/StatRow/ReferencePrice") as PanelContainer, "Reference Price", "%.1fg" % float(_economy.get_price(town_name, item)))
	_update_stat_box(container.get_node("TradeSection/TradeRoot/MainRow/RightStack/StatRow/CityStock") as PanelContainer, "City Stock", "%d" % town_stock)
	_update_stat_box(container.get_node("TradeSection/TradeRoot/MainRow/RightStack/StatRow/Cargo") as PanelContainer, "Cargo", "%d" % player_has)

	var slider := container.get_node("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/SliderFrame/QuantitySlider") as HSlider
	var spin := container.get_node("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/Header/SpinBoxPanel/QuantitySpin") as SpinBox
	_set_range_value_without_signal(slider, max_qty, trade_qty)
	_set_range_value_without_signal(spin, max_qty, trade_qty)

	var max_buy_btn := container.get_node("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/MaxRow/MaxBuyButton") as Button
	max_buy_btn.disabled = max_buy <= 0
	var max_sell_btn := container.get_node("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/MaxRow/MaxSellButton") as Button
	max_sell_btn.disabled = max_sell <= 0

	_update_quote_panel(container.get_node("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/BuyQuotePanel") as PanelContainer, "Buy Quote", buy_total, buy_avg, max_buy)
	_update_quote_panel(container.get_node("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/SellQuotePanel") as PanelContainer, "Sell Quote", sell_total, sell_avg, max_sell)
	_update_profit_panel(container.get_node("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/ProfitEstimatePanel") as PanelContainer, unit_profit, total_profit, has_cost_basis)

	var buy_btn := container.get_node("TradeSection/TradeRoot/ActionRow/BuyButton") as Button
	buy_btn.disabled = trade_qty <= 0 or trade_qty > max_buy
	buy_btn.tooltip_text = _format_trade_quote_tooltip("Buy", trade_qty, buy_total)
	var sell_btn := container.get_node("TradeSection/TradeRoot/ActionRow/SellButton") as Button
	sell_btn.disabled = trade_qty <= 0 or trade_qty > max_sell
	sell_btn.tooltip_text = _format_trade_quote_tooltip("Sell", trade_qty, sell_total)

func _set_range_value_without_signal(range_node: Range, max_qty: int, value: int) -> void:
	range_node.set_block_signals(true)
	range_node.min_value = 1
	range_node.max_value = max_qty
	range_node.step = 1
	range_node.value = value
	range_node.set_block_signals(false)

func _connect_trade_panel_signals(container: VBoxContainer) -> void:
	var slider := container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/SliderFrame/QuantitySlider") as HSlider
	if slider != null and not slider.value_changed.is_connected(_on_qty_changed):
		slider.value_changed.connect(_on_qty_changed)
	var spin := container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/Header/SpinBoxPanel/QuantitySpin") as SpinBox
	if spin != null and not spin.value_changed.is_connected(_on_qty_changed):
		spin.value_changed.connect(_on_qty_changed)
	var max_buy_btn := container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/MaxRow/MaxBuyButton") as Button
	if max_buy_btn != null and not max_buy_btn.pressed.is_connected(_on_max_buy_pressed):
		max_buy_btn.pressed.connect(_on_max_buy_pressed)
	var max_sell_btn := container.get_node_or_null("TradeSection/TradeRoot/MainRow/RightStack/TradeRow/QuantityPanel/QuantityContent/MaxRow/MaxSellButton") as Button
	if max_sell_btn != null and not max_sell_btn.pressed.is_connected(_on_max_sell_pressed):
		max_sell_btn.pressed.connect(_on_max_sell_pressed)
	var buy_btn := container.get_node_or_null("TradeSection/TradeRoot/ActionRow/BuyButton") as Button
	if buy_btn != null and not buy_btn.pressed.is_connected(_on_buy_pressed):
		buy_btn.pressed.connect(_on_buy_pressed)
	var sell_btn := container.get_node_or_null("TradeSection/TradeRoot/ActionRow/SellButton") as Button
	if sell_btn != null and not sell_btn.pressed.is_connected(_on_sell_pressed):
		sell_btn.pressed.connect(_on_sell_pressed)

func _make_market_bg_style() -> StyleBox:
	var resource_style := load(MARKET_BG_STYLE) as StyleBoxTexture
	if resource_style != null:
		return resource_style.duplicate() as StyleBoxTexture

	var texture := load(MARKET_BG_TEXTURE) as Texture2D
	if texture == null:
		return _make_panel_style(PANEL_BG, PANEL_BORDER_DARK, 3, 22.0, true)

	var style := StyleBoxTexture.new()
	style.texture = texture
	style.draw_center = true
	style.texture_margin_left = 24.0
	style.texture_margin_top = 24.0
	style.texture_margin_right = 24.0
	style.texture_margin_bottom = 24.0
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.content_margin_top = 18.0
	style.content_margin_bottom = 18.0
	return style

func _make_market_bottom_bg_style() -> StyleBox:
	var resource_style := load(MARKET_BOTTOM_BG_STYLE) as StyleBoxTexture
	if resource_style != null:
		return resource_style.duplicate() as StyleBoxTexture
	return _make_panel_style(PANEL_BG, PANEL_BORDER_DARK, 3, 22.0, true)

func _make_selected_good_panel(item: String) -> PanelContainer:
	var box := _make_framed_panel(Vector2(176, 188), true)
	box.name = "SelectedGoodPanel"
	_style_market_sec_panel(box)
	var vbox := VBoxContainer.new()
	vbox.name = "SelectedGoodContent"
	vbox.add_theme_constant_override("separation", 8)
	box.add_child(vbox)

	var title := _add_panel_label(vbox, "Selected Good")
	title.name = "Title"

	var icon_slot := _make_inset_panel(Vector2(0, 72))
	icon_slot.name = "IconSlot"
	icon_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(icon_slot)
	var icon_texture := _get_item_icon_texture(item)
	if icon_texture != null:
		var icon_center := CenterContainer.new()
		icon_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon_slot.add_child(icon_center)
		icon_center.add_child(_make_selected_item_icon_stack(icon_texture))

	var name_label := _add_panel_value(vbox, _get_item_name(item), 24, TITLE_PARCHMENT)
	name_label.name = "ItemName"

	var desc := Label.new()
	desc.name = "Description"
	desc.text = "Market commodity"
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.label_settings = _make_trade_label_settings(12, Color(0.62, 0.54, 0.39))
	vbox.add_child(desc)
	return box

func _make_quantity_panel(slider: HSlider, spin: SpinBox, max_buy_btn: Button, max_sell_btn: Button) -> PanelContainer:
	var panel := _make_framed_panel(Vector2(156, 128), false)
	panel.name = "QuantityPanel"
	var vbox := VBoxContainer.new()
	vbox.name = "QuantityContent"
	vbox.add_theme_constant_override("separation", 7)
	panel.add_child(vbox)

	var header := HBoxContainer.new()
	header.name = "Header"
	header.add_theme_constant_override("separation", 8)
	vbox.add_child(header)
	_add_panel_label(header, "Quantity")

	var spin_box_panel := _make_inset_panel(Vector2(88, 36))
	spin_box_panel.name = "SpinBoxPanel"
	header.add_child(spin_box_panel)
	spin_box_panel.add_child(spin)

	var slider_frame := _make_inset_panel(Vector2(0, 42))
	slider_frame.name = "SliderFrame"
	slider_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(slider_frame)
	slider_frame.add_child(slider)

	var max_row := HBoxContainer.new()
	max_row.name = "MaxRow"
	max_row.add_theme_constant_override("separation", 6)
	vbox.add_child(max_row)
	max_row.add_child(max_buy_btn)
	max_row.add_child(max_sell_btn)
	return panel

func _make_market_divider() -> Control:
	var divider := Control.new()
	divider.custom_minimum_size.y = 16
	divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ensure_market_divider_visuals(divider)
	return divider

func _ensure_market_divider_visuals(divider: Control) -> void:
	divider.custom_minimum_size.y = 16
	divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if divider.get_child_count() > 0:
		return
	var texture := load(MARKET_DIVIDER_TEXTURE) as Texture2D
	if texture == null:
		return
	var image := TextureRect.new()
	image.name = "DividerImage"
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	divider.add_child(image)

func _make_framed_panel(min_size: Vector2, emphasized: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if min_size.x <= 0.0 else Control.SIZE_SHRINK_BEGIN
	var bg := Color(0.126, 0.088, 0.052, 1.0) if emphasized else Color(0.057, 0.045, 0.034, 1.0)
	var border := PANEL_BORDER_BRASS.lightened(0.035) if emphasized else Color(0.34, 0.235, 0.105, 0.84)
	panel.add_theme_stylebox_override("panel", _make_panel_style(bg, border, 2 if emphasized else 1, 14.0, true))
	return panel

func _make_inset_panel(min_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.add_theme_stylebox_override("panel", _make_panel_style(PANEL_INSET_BG, Color(0.12, 0.083, 0.047, 0.96), 2, 8.0, false))
	return panel

func _make_stat_box(title: String, value: String) -> PanelContainer:
	var box := _make_framed_panel(Vector2(124, 70), false)
	_style_market_sec_panel(box)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var vbox := VBoxContainer.new()
	vbox.name = "Content"
	vbox.add_theme_constant_override("separation", 4)
	box.add_child(vbox)
	var title_label := _add_panel_label(vbox, title)
	title_label.name = "Title"
	var value_label := _add_panel_value(vbox, value, 20, VALUE_PARCHMENT)
	value_label.name = "Value"
	return box

func _make_panel_style(bg: Color, border: Color, border_width: int, padding: float, raised: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg.lightened(0.004 if raised else 0.0)
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width + (2 if raised else 1)
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding * 0.82
	style.content_margin_bottom = padding * 0.82
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.70 if raised else 0.56)
	style.shadow_size = 2 if raised else 1
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
	settings.outline_color = Color(0.040, 0.026, 0.014)
	settings.shadow_color = Color(0.0, 0.0, 0.0, 0.72)
	settings.shadow_offset = Vector2(1.0, 1.0)
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
	style.bg_color = PANEL_INSET_BG.lightened(0.010 if focused else 0.0)
	style.border_color = PANEL_BORDER_BRASS.lightened(0.025) if focused else Color(0.095, 0.065, 0.036, 1.0)
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
	slider.custom_minimum_size = Vector2(0, 46)
	slider.add_theme_stylebox_override("slider", _make_slider_track_style(false))
	slider.add_theme_stylebox_override("grabber_area", _make_slider_track_style(true))
	slider.add_theme_stylebox_override("grabber_area_highlight", _make_slider_track_style(true))
	slider.add_theme_icon_override("grabber", _make_slider_grabber_texture(false))
	slider.add_theme_icon_override("grabber_highlight", _make_slider_grabber_texture(true))
	slider.add_theme_icon_override("grabber_disabled", _make_slider_grabber_texture(false))

func _make_slider_track_style(filled: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.245, 0.160, 0.072, 0.98) if filled else Color(0.012, 0.011, 0.010, 1.0)
	style.border_color = Color(0.48, 0.325, 0.13, 0.82) if filled else Color(0.060, 0.040, 0.024, 1.0)
	style.border_width_left = 2
	style.border_width_top = 4
	style.border_width_right = 2
	style.border_width_bottom = 3
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_top = 9
	style.content_margin_bottom = 9
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

func apply_market_tab_button_style(button: Button, selected: bool) -> void:
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", TRADE_BUTTON_TEXT if selected else Color(0.66, 0.56, 0.38))
	button.add_theme_color_override("font_hover_color", TRADE_BUTTON_TEXT_HOVER)
	button.add_theme_color_override("font_pressed_color", Color(0.72, 0.55, 0.31))
	button.add_theme_color_override("font_disabled_color", TRADE_BUTTON_TEXT_DISABLED)
	button.add_theme_color_override("font_outline_color", TRADE_BUTTON_OUTLINE)
	button.add_theme_constant_override("outline_size", 1)
	button.add_theme_stylebox_override("normal", _make_market_tab_button_style(selected, "normal"))
	button.add_theme_stylebox_override("hover", _make_market_tab_button_style(selected, "hover"))
	button.add_theme_stylebox_override("pressed", _make_market_tab_button_style(selected, "pressed"))
	button.focus_mode = Control.FOCUS_NONE

func _make_market_tab_button_style(selected: bool, state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 3 if selected else 2
	var bg := Color(0.145, 0.100, 0.054, 1.0) if selected else Color(0.050, 0.040, 0.032, 1.0)
	var border := Color(0.55, 0.37, 0.15, 0.90) if selected else Color(0.30, 0.205, 0.095, 0.78)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.50)
	style.shadow_size = 1
	style.shadow_offset = Vector2(0, 1)
	if state == "hover":
		bg = bg.lightened(0.055)
		border = border.lightened(0.07)
	if state == "pressed":
		bg = bg.darkened(0.08)
	style.bg_color = bg
	style.border_color = border
	return style

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
	var bg := Color(0.104, 0.072, 0.044, 1.0)
	var border := Color(0.38, 0.255, 0.110, 0.90)
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
	button.custom_minimum_size = Vector2(178, 70)
	button.add_theme_font_size_override("font_size", 19)
	var text_color := Color(0.56, 0.72, 0.34) if primary else Color(0.74, 0.30, 0.22)
	var hover_color := Color(0.66, 0.82, 0.42) if primary else Color(0.86, 0.38, 0.28)
	var pressed_color := Color(0.42, 0.58, 0.25) if primary else Color(0.58, 0.22, 0.17)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", hover_color)
	button.add_theme_color_override("font_pressed_color", pressed_color)
	button.add_theme_color_override("font_disabled_color", TRADE_BUTTON_TEXT_DISABLED)
	button.add_theme_color_override("font_outline_color", TRADE_BUTTON_OUTLINE)
	button.add_theme_color_override("font_shadow_color", TRADE_BUTTON_SHADOW)
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_constant_override("shadow_offset_x", 2)
	button.add_theme_constant_override("shadow_offset_y", 2)
	if primary:
		for state in ["normal", "hover", "pressed", "disabled"]:
			button.add_theme_stylebox_override(state, load(String(MARKET_BUY_BUTTON_STYLES[state])))
	else:
		for state in ["normal", "hover", "pressed", "disabled"]:
			button.add_theme_stylebox_override(state, load(String(MARKET_SELL_BUTTON_STYLES[state])))
	button.focus_mode = Control.FOCUS_NONE

func _make_buy_texture_button_style(state: String) -> StyleBoxTexture:
	var style_path := String(BUY_BUTTON_STYLES.get(state, BUY_BUTTON_STYLES["normal"]))
	var resource_style := load(style_path) as StyleBoxTexture
	if resource_style != null:
		return resource_style.duplicate() as StyleBoxTexture

	var style := StyleBoxTexture.new()
	var texture_path := String(BUY_BUTTON_TEXTURES.get(state, BUY_BUTTON_TEXTURES["normal"]))
	style.texture = load(texture_path) as Texture2D
	style.draw_center = true
	style.texture_margin_left = 18.0
	style.texture_margin_top = 18.0
	style.texture_margin_right = 18.0
	style.texture_margin_bottom = 18.0
	style.content_margin_left = 26.0
	style.content_margin_right = 26.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	return style

func _make_trade_button_style(primary: bool, state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.content_margin_left = 26.0
	style.content_margin_right = 26.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 6
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.62)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 3)

	var bg := Color(0.135, 0.073, 0.052)
	var border := Color(0.43, 0.230, 0.125, 0.93)
	if primary:
		bg = Color(0.265, 0.178, 0.088)
		border = Color(0.64, 0.430, 0.170, 0.96)

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
	var box := _make_framed_panel(Vector2(104, 128), false)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_market_sec_panel(box)
	parent.add_child(box)

	var vbox := VBoxContainer.new()
	vbox.name = "Content"
	vbox.add_theme_constant_override("separation", 4)
	box.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.name = "Title"
	title_lbl.text = title
	title_lbl.label_settings = _make_trade_label_settings(12, LABEL_MUTED_GOLD)
	vbox.add_child(title_lbl)

	var total_lbl := Label.new()
	total_lbl.name = "Total"
	total_lbl.text = "%.1fg" % total
	total_lbl.label_settings = _make_trade_label_settings(23, VALUE_PARCHMENT)
	vbox.add_child(total_lbl)

	var avg_lbl := Label.new()
	avg_lbl.name = "Average"
	avg_lbl.text = "Avg %.1fg" % avg
	avg_lbl.label_settings = _make_trade_label_settings(13, Color(0.75, 0.66, 0.47))
	vbox.add_child(avg_lbl)

	var divider := ColorRect.new()
	divider.name = "Divider"
	divider.custom_minimum_size.y = 2
	divider.color = Color(0.48, 0.31, 0.12, 0.30)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(divider)

	var max_lbl := Label.new()
	max_lbl.name = "Max"
	max_lbl.text = "Max %d" % max_qty
	max_lbl.label_settings = _make_trade_label_settings(13, Color(0.69, 0.59, 0.41))
	vbox.add_child(max_lbl)

func _add_profit_block(parent: HBoxContainer, unit_profit: float, total_profit: float, has_cost_basis: bool) -> void:
	var box := _make_framed_panel(Vector2(112, 128), false)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_market_sec_panel(box)
	parent.add_child(box)

	var vbox := VBoxContainer.new()
	vbox.name = "Content"
	vbox.add_theme_constant_override("separation", 4)
	box.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.name = "Title"
	title_lbl.text = "Profit Estimate"
	title_lbl.label_settings = _make_trade_label_settings(12, LABEL_MUTED_GOLD)
	vbox.add_child(title_lbl)

	var unit_lbl := Label.new()
	unit_lbl.name = "Unit"
	unit_lbl.text = "%+.1fg" % unit_profit if has_cost_basis else "--"
	unit_lbl.label_settings = _make_trade_label_settings(21, _profit_color(unit_profit) if has_cost_basis else Color(0.64, 0.56, 0.42))
	vbox.add_child(unit_lbl)

	var divider := ColorRect.new()
	divider.name = "Divider"
	divider.custom_minimum_size.y = 2
	divider.color = Color(0.48, 0.31, 0.12, 0.30)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(divider)

	var total_lbl := Label.new()
	total_lbl.name = "Total"
	total_lbl.text = "Total %+.1fg" % total_profit if has_cost_basis else "No cost basis"
	total_lbl.label_settings = _make_trade_label_settings(12, Color(0.72, 0.64, 0.46))
	vbox.add_child(total_lbl)

	var note_lbl := Label.new()
	note_lbl.name = "Note"
	note_lbl.text = "after held avg"
	note_lbl.label_settings = _make_trade_label_settings(11, Color(0.52, 0.45, 0.34))
	vbox.add_child(note_lbl)

func _add_plain_info(parent: HBoxContainer, text: String, color: Color) -> void:
	var box := _make_framed_panel(Vector2(110, 118), false)
	parent.add_child(box)

	var label := Label.new()
	label.text = text
	label.label_settings = _make_trade_label_settings(13, color)
	box.add_child(label)

func _update_selected_good_panel(panel_node: PanelContainer, item: String) -> void:
	(panel_node.get_node("SelectedGoodContent/Title") as Label).label_settings = _make_trade_label_settings(12, LABEL_MUTED_GOLD)
	var name_label := panel_node.get_node("SelectedGoodContent/ItemName") as Label
	name_label.text = _get_item_name(item)
	name_label.label_settings = _make_trade_label_settings(24, TITLE_PARCHMENT)
	var desc := panel_node.get_node("SelectedGoodContent/Description") as Label
	desc.text = "Market commodity"
	desc.label_settings = _make_trade_label_settings(12, Color(0.62, 0.54, 0.39))
	var icon_slot := panel_node.get_node("SelectedGoodContent/IconSlot") as PanelContainer
	for child in icon_slot.get_children():
		child.queue_free()
	var icon_texture := _get_item_icon_texture(item)
	if icon_texture != null:
		var icon_center := CenterContainer.new()
		icon_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon_slot.add_child(icon_center)
		icon_center.add_child(_make_selected_item_icon_stack(icon_texture))

func _update_stat_box(box: PanelContainer, title: String, value: String) -> void:
	var title_label := box.get_node("Content/Title") as Label
	title_label.text = title
	title_label.label_settings = _make_trade_label_settings(12, LABEL_MUTED_GOLD)
	var value_label := box.get_node("Content/Value") as Label
	value_label.text = value
	value_label.label_settings = _make_trade_label_settings(20, VALUE_PARCHMENT)

func _update_quote_panel(box: PanelContainer, title: String, total: float, avg: float, max_qty: int) -> void:
	var title_label := box.get_node("Content/Title") as Label
	title_label.text = title
	title_label.label_settings = _make_trade_label_settings(12, LABEL_MUTED_GOLD)
	var total_label := box.get_node("Content/Total") as Label
	total_label.text = "%.1fg" % total
	total_label.label_settings = _make_trade_label_settings(23, VALUE_PARCHMENT)
	var avg_label := box.get_node("Content/Average") as Label
	avg_label.text = "Avg %.1fg" % avg
	avg_label.label_settings = _make_trade_label_settings(13, Color(0.75, 0.66, 0.47))
	var max_label := box.get_node("Content/Max") as Label
	max_label.text = "Max %d" % max_qty
	max_label.label_settings = _make_trade_label_settings(13, Color(0.69, 0.59, 0.41))
	(box.get_node("Content/Divider") as ColorRect).color = Color(0.48, 0.31, 0.12, 0.30)

func _update_profit_panel(box: PanelContainer, unit_profit: float, total_profit: float, has_cost_basis: bool) -> void:
	(box.get_node("Content/Title") as Label).label_settings = _make_trade_label_settings(12, LABEL_MUTED_GOLD)
	var unit_lbl := box.get_node("Content/Unit") as Label
	unit_lbl.text = "%+.1fg" % unit_profit if has_cost_basis else "--"
	unit_lbl.label_settings = _make_trade_label_settings(21, _profit_color(unit_profit) if has_cost_basis else Color(0.64, 0.56, 0.42))
	var total_lbl := box.get_node("Content/Total") as Label
	total_lbl.text = "Total %+.1fg" % total_profit if has_cost_basis else "No cost basis"
	total_lbl.label_settings = _make_trade_label_settings(12, Color(0.72, 0.64, 0.46))
	(box.get_node("Content/Note") as Label).label_settings = _make_trade_label_settings(11, Color(0.52, 0.45, 0.34))
	(box.get_node("Content/Divider") as ColorRect).color = Color(0.48, 0.31, 0.12, 0.30)

func _on_max_buy_pressed() -> void:
	_set_qty_and_rebuild(_current_max_buy)

func _on_max_sell_pressed() -> void:
	_set_qty_and_rebuild(_current_max_sell)

func _on_buy_pressed() -> void:
	if selected_item != "":
		_on_buy(selected_item, trade_qty)

func _on_sell_pressed() -> void:
	if selected_item != "":
		_on_sell(selected_item, trade_qty)

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

func _get_item_icon_path(item: String) -> String:
	return String(ITEM_ICON_PATHS.get(item, ""))

func _get_item_icon_texture(item: String) -> Texture2D:
	var icon_path := _get_item_icon_path(item)
	if icon_path == "":
		return null
	return load(icon_path) as Texture2D

func _make_selected_item_icon_stack(texture: Texture2D) -> Control:
	var stack := Control.new()
	stack.custom_minimum_size = Vector2(58, 58)

	var shadow := TextureRect.new()
	shadow.modulate = Color(0.0, 0.0, 0.0, 0.34)
	shadow.texture = texture
	shadow.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shadow.offset_left = 3
	shadow.offset_top = 4
	shadow.offset_right = 3
	shadow.offset_bottom = 4
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(shadow)

	var icon := TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 5
	icon.offset_top = 4
	icon.offset_right = -5
	icon.offset_bottom = -6
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(icon)
	return stack

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
