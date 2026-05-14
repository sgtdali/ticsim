extends Resource
class_name TownData

@export var id: String = ""
@export var display_name: String = ""
@export var faction_id: String = ""

@export_group("Starting Stats")
@export var starting_population: int = 1000
@export var starting_prosperity: int = 20

@export_group("Economy")
@export var production_plan: Dictionary = {} # Format: { "wheat": 20, "wood": 15 }
@export var consumption_rules: Dictionary = {} # Format: { "wheat": 10 }
@export var starting_inventory: Dictionary = {} # Format: { "wheat": 50 }
