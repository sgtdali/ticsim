extends Resource
class_name CaravanMaster

@export var id: String = ""
@export var display_name: String = ""

# Base stats (1-5 range)
@export var speed: int = 1
@export var capacity: int = 1
@export var bargaining: int = 1
@export var courage: int = 1

# Experience
@export var xp: int = 0
@export var level: int = 1
const MAX_LEVEL := 5
const XP_PER_LEVEL := 100

# Hiring cost
@export var hire_cost: int = 0
@export var daily_wage: float = 0.0

# Derived stats
func get_travel_multiplier() -> float:
	# Higher speed = fewer days. Speed 1 = 1.0x, Speed 5 = 0.6x
	return 1.0 - ((speed - 1) * 0.1)

func get_capacity() -> int:
	# Base 15, +5 per capacity point
	return 10 + (capacity * 5)

func get_bargaining_discount() -> float:
	# Each point = 0.5% discount on buy, bonus on sell
	return (bargaining - 1) * 0.005

func get_courage_risk_reduction() -> float:
	# Each point reduces attack chance by 3%
	return (courage - 1) * 0.03

func add_xp(amount: int) -> bool:
	# Returns true if leveled up
	if level >= MAX_LEVEL:
		return false
	xp += amount
	if xp >= XP_PER_LEVEL * level:
		level += 1
		xp = 0
		return true
	return false

func can_level_up() -> bool:
	return level < MAX_LEVEL and xp >= XP_PER_LEVEL * level
