extends Resource
class_name ItemData

@export var id: String = ""
@export var display_name: String = ""
@export_enum("survival", "comfort", "production_input") var category: String = "survival"

@export_group("Economy")
@export var base_price: float = 1.0
@export var stock_cap: int = 100
@export var stock_cap_base_cost: int = 50

@export_group("Production")
@export var production_base_cost: int = 50
@export var production_interval_days: int = 1
@export var recipe_inputs: Dictionary = {} # Format: { "wood": 2, "iron_ore": 1 }
