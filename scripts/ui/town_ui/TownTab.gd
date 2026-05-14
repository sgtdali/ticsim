extends RefCounted
class_name TownTab

var ui: Control
var panel: Control
var town_name: String
var _player: Node
var _economy: Node
var _faction: Node
var _contracts: Node
var _events: Node

func _init(_ui: Control, _panel: Control):
	ui = _ui
	panel = _panel
	town_name = ui.town_name
	_player = ui.get_node("/root/PlayerData")
	_economy = ui.get_node("/root/EconomyManager")
	_faction = ui.get_node("/root/FactionManager")
	_contracts = ui.get_node("/root/ContractManager")
	_events = ui.get_node_or_null("/root/EventManager")
	setup()

func setup():
	pass

func build():
	pass
