extends Control

func _ready() -> void:
	get_node("VBox/MenuBtn").pressed.connect(_on_menu)
	get_node("VBox/QuitBtn").pressed.connect(_on_quit)

func _on_menu() -> void:
	var player = get_node_or_null("/root/PlayerData")
	if player:
		player.gold = 400.0
		player.debt = 0.0
		player.debt_days = 0
		player.inventory.clear()
		player.purchase_prices.clear()
		player.caravan_capacity = 20
		player.caravan_upgrade_level = 0
		player.current_day = 1
	var rank = get_node_or_null("/root/RankManager")
	if rank:
		rank.current_rank_index = 0
	var eco = get_node_or_null("/root/EconomyManager")
	if eco:
		eco.current_day = 1
		eco._init_towns()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_quit() -> void:
	get_tree().quit()
