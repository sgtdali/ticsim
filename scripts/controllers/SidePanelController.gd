extends RefCounted
class_name SidePanelController

const DEFAULT_MASTER_HIRE_COST := 120
const DEFAULT_MASTER_DAILY_WAGE := 4.0

var _wm: Node
var _player_data: Node
var _economy: Node
var _contracts: Node
var _posts: Node
var _masters: Node

var _selected_master_id: String = ""
var _expanded_masters: Dictionary = {}
var _expanded_posts: Dictionary = {}

func _init(world_map: Node) -> void:
	_wm = world_map
	_player_data = world_map.get_node("/root/PlayerData")
	_economy = world_map.get_node("/root/EconomyManager")
	_contracts = world_map.get_node_or_null("/root/ContractManager")
	_posts = world_map.get_node_or_null("/root/TradingPostManager")
	_masters = world_map.get_node_or_null("/root/CaravanMasterManager")

func bind_signals() -> void:
	var hire_btn := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Operations/OperationsVBox/HireMasterButton") as Button
	if hire_btn:
		hire_btn.pressed.connect(_on_hire_master_pressed)

	var establish_btn := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Operations/OperationsVBox/EstablishPostButton") as Button
	if establish_btn:
		establish_btn.pressed.connect(_on_establish_post_pressed)

	var upgrade_btn := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Player/PlayerVBox/UpgradeCaravanButton") as Button
	if upgrade_btn:
		upgrade_btn.pressed.connect(_on_upgrade_caravan_pressed)

	var rank_manager := _wm.get_node_or_null("/root/RankManager")
	if rank_manager and rank_manager.has_signal("rank_changed"):
		rank_manager.connect("rank_changed", _on_rank_changed)

	if _contracts and _contracts.has_signal("contracts_changed"):
		_contracts.connect("contracts_changed", update)
	if _posts and _posts.has_signal("post_updated"):
		_posts.connect("post_updated", _on_post_updated)
	if _masters:
		if _masters.has_signal("master_updated"):
			_masters.connect("master_updated", _on_master_updated)
		if _masters.has_signal("master_leveled_up"):
			_masters.connect("master_leveled_up", _on_master_updated)

	update()

func update(_arg: Variant = null) -> void:
	_update_operations_tab()
	_update_player_tab()
	_update_contracts_tab()

# --- Operations Tab ---

func _update_operations_tab() -> void:
	var master_list := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Operations/OperationsVBox/MasterList") as VBoxContainer
	var post_list := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Operations/OperationsVBox/PostList") as VBoxContainer
	var hire_btn := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Operations/OperationsVBox/HireMasterButton") as Button
	var route_btn := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Operations/OperationsVBox/OpenTradeRouteButton") as Button
	var establish_btn := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Operations/OperationsVBox/EstablishPostButton") as Button

	if _masters != null:
		if _selected_master_id != "" and not _masters.masters.has(_selected_master_id):
			_selected_master_id = ""
		if _selected_master_id == "" and not _masters.masters.is_empty():
			_selected_master_id = str(_masters.masters.keys()[0])

	if master_list:
		MapUtils.clear_container(master_list)
		if _masters == null:
			MapUtils.add_muted_label(master_list, "Caravan Master system is not enabled.")
		elif _masters.masters.is_empty():
			MapUtils.add_muted_label(master_list, "No masters hired.")
		else:
			for master_id in _masters.masters.keys():
				_add_master_panel(master_list, str(master_id))

	if hire_btn:
		if _masters == null:
			hire_btn.disabled = true
			hire_btn.text = "Hire Master"
		else:
			var count: int = int(_masters.get_active_master_count())
			var cap: int = int(_masters.get_master_cap())
			hire_btn.text = "Hire Master (%d/%d)" % [count, cap]
			hire_btn.disabled = false

	if route_btn:
		route_btn.disabled = false

	if post_list:
		MapUtils.clear_container(post_list)
		if _posts == null:
			MapUtils.add_muted_label(post_list, "Trading Post system is not enabled.")
		else:
			var has_any_post := false
			for town_name in _economy.towns.keys():
				if _posts.has_post(str(town_name)):
					has_any_post = true
					_add_post_panel(post_list, str(town_name))
			if not has_any_post:
				MapUtils.add_muted_label(post_list, "No trading posts established.")

	if establish_btn:
		var can_establish := false
		if _posts != null:
			var rank_manager := _wm.get_node_or_null("/root/RankManager")
			can_establish = (
				not _wm.is_traveling
				and rank_manager != null
				and rank_manager.can_open_trading_post()
				and not _player_data.has_debt()
				and not _posts.has_post(_player_data.current_town)
				and _player_data.gold >= float(_posts.POST_COST)
			)
		establish_btn.text = "Establish Post in %s" % _player_data.current_town
		establish_btn.disabled = not can_establish

func _add_master_panel(parent: VBoxContainer, master_id: String) -> void:
	var master: CaravanMaster = _masters.get_master(master_id)
	if master == null:
		return
	var route: Dictionary = _masters.get_route(master_id)

	var title := Button.new()
	title.alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.toggle_mode = true
	if master_id == _selected_master_id:
		title.button_pressed = true
	title.text = "%s | %s | Lv %d" % [
		master.display_name,
		_masters.get_master_location(master_id),
		int(master.level),
	]
	title.pressed.connect(_select_master_for_route.bind(master_id))
	parent.add_child(title)

	if not bool(_expanded_masters.get(master_id, false)):
		return

	var detail := VBoxContainer.new()
	detail.add_theme_constant_override("separation", 3)
	parent.add_child(detail)

	var stops: Array = route.get("stops", [])
	var stop_names: Array[String] = []
	for stop in stops:
		stop_names.append(str(stop.get("town_name", "")))
	MapUtils.add_muted_label(detail, "Route: %s" % (" -> ".join(stop_names) if not stop_names.is_empty() else "No route"))

	var inventory: Dictionary = route.get("inventory", {})
	if inventory.is_empty():
		MapUtils.add_muted_label(detail, "Cargo: empty")
	else:
		for item in inventory.keys():
			MapUtils.add_muted_label(detail, "Cargo: %s x%d" % [str(item).capitalize(), int(inventory[item])])

	var xp_bar := ProgressBar.new()
	xp_bar.max_value = float(CaravanMaster.XP_PER_LEVEL * int(master.level))
	xp_bar.value = float(master.xp)
	xp_bar.custom_minimum_size = Vector2(0, 16)
	detail.add_child(xp_bar)

func _add_post_panel(parent: VBoxContainer, town_name: String) -> void:
	var total: int = int(_posts.get_depot_total(town_name))
	var rules: Array = _posts.get_rules(town_name)
	var active_rules := 0
	for rule in rules:
		if bool(rule.get("enabled", true)) and str(rule.get("status", "")) == "active":
			active_rules += 1

	var title := Button.new()
	title.alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.text = "%s | Depot %d/%d | Active rules %d" % [town_name, total, int(_posts.DEPOT_CAPACITY), active_rules]
	title.pressed.connect(_toggle_post_expanded.bind(town_name))
	parent.add_child(title)

	if not bool(_expanded_posts.get(town_name, false)):
		return

	var detail := VBoxContainer.new()
	detail.add_theme_constant_override("separation", 3)
	parent.add_child(detail)

	if rules.is_empty():
		MapUtils.add_muted_label(detail, "No rules.")
	else:
		for rule in rules:
			var status: String = str(rule.get("status", "waiting_price"))
			MapUtils.add_muted_label(detail, "%s %s | limit %.1f | %s" % [
				str(rule.get("type", "buy")).capitalize(),
				str(rule.get("item", "")).capitalize(),
				float(rule.get("price_limit", 0.0)),
				status,
			])

# --- Player Tab ---

func _update_player_tab() -> void:
	var caravan_summary := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Player/PlayerVBox/CaravanSummary") as Label
	var cargo_summary := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Player/PlayerVBox/CargoSummary") as Label
	var cargo_list := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Player/PlayerVBox/CargoList") as VBoxContainer
	var upgrade_btn := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Player/PlayerVBox/UpgradeCaravanButton") as Button
	var rank_label := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Player/PlayerVBox/RankLabel") as Label
	var rank_reqs := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Player/PlayerVBox/RankRequirements") as VBoxContainer
	var prosperity_list := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Player/PlayerVBox/ProsperityList") as VBoxContainer

	if caravan_summary:
		caravan_summary.text = "%s - %d capacity" % [_player_data.get_upgrade_name(), int(_player_data.caravan_capacity)]
	if cargo_summary:
		cargo_summary.text = "Cargo %d/%d" % [int(_player_data.get_total_cargo()), int(_player_data.caravan_capacity)]
	if cargo_list:
		MapUtils.clear_container(cargo_list)
		if _player_data.inventory.is_empty():
			MapUtils.add_muted_label(cargo_list, "Cargo empty.")
		else:
			for item in _player_data.inventory.keys():
				var qty: int = int(_player_data.inventory[item])
				if qty <= 0:
					continue
				var avg: float = float(_player_data.purchase_prices.get(item, 0.0))
				MapUtils.add_muted_label(cargo_list, "%s | %d | avg %.1fg" % [str(item).capitalize(), qty, avg])

	if upgrade_btn:
		var next_name: String = _player_data.get_next_upgrade_name()
		if next_name == "":
			upgrade_btn.text = "Caravan Fully Upgraded"
			upgrade_btn.disabled = true
		else:
			upgrade_btn.text = "Upgrade: %s (%dg)" % [next_name, int(_player_data.get_next_upgrade_cost())]
			upgrade_btn.disabled = not _player_data.can_upgrade_caravan()

	var rank_manager := _wm.get_node_or_null("/root/RankManager")
	if rank_manager == null:
		return

	if rank_label:
		rank_label.text = "Rank: %s" % str(rank_manager.get_current_rank())

	if rank_reqs:
		MapUtils.clear_container(rank_reqs)
		var next_rank: String = str(rank_manager.get_next_rank())
		if next_rank == "":
			MapUtils.add_muted_label(rank_reqs, "Maximum rank achieved.")
		else:
			MapUtils.add_muted_label(rank_reqs, "Next: %s" % next_rank)
			var progress: Dictionary = rank_manager.get_progress_data()
			for key in progress.keys():
				var req: int = int(progress[key].get("req", 0))
				if req <= 0:
					continue
				var current: int = int(progress[key].get("current", 0))
				var label := Label.new()
				label.text = "%s: %d/%d" % [str(key).replace("_", " ").capitalize(), current, req]
				label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.35) if current >= req else Color(1.0, 0.55, 0.35))
				rank_reqs.add_child(label)

	if prosperity_list:
		MapUtils.clear_container(prosperity_list)
		for town_name in _economy.towns.keys():
			_add_prosperity_row(prosperity_list, str(town_name))

func _add_prosperity_row(parent: VBoxContainer, town_name: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)

	var name_lbl := Label.new()
	name_lbl.text = town_name
	name_lbl.custom_minimum_size.x = 92
	row.add_child(name_lbl)

	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = float(_economy.get_prosperity(town_name))
	bar.custom_minimum_size = Vector2(82, 16)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(bar)

	var status_lbl := Label.new()
	status_lbl.text = _economy.get_prosperity_label(town_name)
	row.add_child(status_lbl)

# --- Contracts Tab ---

func _update_contracts_tab() -> void:
	var list := _wm.get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Contracts/ContractsVBox/ActiveContractList") as VBoxContainer
	if list == null or _contracts == null:
		return
	MapUtils.clear_container(list)
	var active_contracts: Array = _contracts.get_active_contracts()
	if active_contracts.is_empty():
		MapUtils.add_muted_label(list, "Aktif kontrat yok.")
		return
	for contract in active_contracts:
		_add_active_contract_row(list, contract)

func _add_active_contract_row(parent: VBoxContainer, contract: Dictionary) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	parent.add_child(row)

	var title := Label.new()
	title.text = "%s | %s" % [str(contract.get("title", "Contract")), str(contract.get("status", "")).capitalize()]
	title.add_theme_color_override("font_color", MapUtils.contract_status_color(str(contract.get("status", ""))))
	row.add_child(title)

	var item: String = str(contract.get("required_item", ""))
	var held: int = int(_player_data.get_item_count(item))
	var required: int = int(contract.get("required_quantity", 0))
	var detail := Label.new()
	detail.text = "%d/%d %s | %d day(s) left | %dg" % [
		held,
		required,
		item.capitalize(),
		int(_contracts.get_days_remaining(contract)),
		int(contract.get("reward_gold", 0)),
	]
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(detail)
	parent.add_child(HSeparator.new())

# --- Button Handlers ---

func _on_upgrade_caravan_pressed() -> void:
	if _player_data.upgrade_caravan():
		_wm._update_ui()

func _on_establish_post_pressed() -> void:
	if _posts != null and _posts.establish_post(_player_data.current_town):
		_wm._update_ui()
		_wm._refresh_buttons()

func _on_hire_master_pressed() -> void:
	if _wm.top_bar and _wm.top_bar.has_method("show_notification"):
		_wm.top_bar.call("show_notification", "Visit a Town's Tavern to hire Caravan Masters!", Color(0.95, 0.65, 0.25))

func _select_master_for_route(master_id: String) -> void:
	_selected_master_id = master_id
	_expanded_masters[master_id] = not bool(_expanded_masters.get(master_id, false))
	if bool(_expanded_masters.get(master_id, false)):
		for other_id in _expanded_masters.keys():
			if str(other_id) != master_id:
				_expanded_masters[other_id] = false
	update()

func _toggle_post_expanded(town_name: String) -> void:
	_expanded_posts[town_name] = not bool(_expanded_posts.get(town_name, false))
	update()

func _on_post_updated(_town_name: String) -> void:
	update()
	_wm._refresh_buttons()

func _on_master_updated(_master_id: String) -> void:
	update()

func _on_rank_changed(_old_rank: String, new_rank: String) -> void:
	if _wm.top_bar and _wm.top_bar.has_method("show_notification"):
		_wm.top_bar.call("show_notification", "You are now a %s!" % new_rank, Color(1.0, 0.85, 0.3))
