extends TownTab

func build() -> void:
	var container = panel.get_node("ScrollContainer/ContractList")
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
		ui.apply_primary_button_style(accept_btn)
		accept_btn.pressed.connect(_on_accept_contract.bind(str(contract.get("id", ""))))
		actions.add_child(accept_btn)
	else:
		var complete_btn = Button.new()
		complete_btn.text = "Complete"
		complete_btn.disabled = not _contracts.can_complete_contract(str(contract.get("id", "")))
		ui.apply_primary_button_style(complete_btn)
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
	build()

func _on_complete_contract(contract_id: String) -> void:
	_contracts.complete_contract(contract_id)
	build()
	if ui.tabs.has("market"):
		ui.tabs["market"].build()
