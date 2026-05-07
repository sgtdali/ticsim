extends Node

# --- Risk parametreleri ---
const BASE_ATTACK_CHANCE := 0.05        # Boş yolculuk neredeyse güvenli (%5)
const CARGO_RISK_PER_UNIT := 0.018      # Cargo doldukça hızla artar (%1.8/birim)
const MAX_ATTACK_CHANCE := 0.50         # Tam dolu cargo gerçek tehdit
const REPUTATION_PROTECTION := 0.001    # Faction rep başına azalma

var _player: Node
var _faction: Node
var _economy: Node

# -----------------------------------------------

func _ready() -> void:
	randomize()
	_player = get_node("/root/PlayerData")
	_faction = get_node("/root/FactionManager")
	_economy = get_node("/root/EconomyManager")

# Belirli bir seyahat için saldırı ihtimalini hesaplar (0.0 - 1.0).
# Cargo ne kadar fazlaysa risk o kadar yüksek.
# Hedef şehrin faction reputation'ı ne kadar yüksekse risk o kadar düşük.
func calculate_attack_chance(destination_town: String) -> float:
	var cargo_count: int = int(_player.get_total_cargo())
	var cargo_risk: float = float(cargo_count) * CARGO_RISK_PER_UNIT

	var protection: float = 0.0
	var dest_data: Dictionary = _economy.get_town(destination_town)
	if not dest_data.is_empty():
		var faction: String = str(dest_data.get("faction", ""))
		if faction != "":
			var rep: float = float(_player.get_faction_rep(faction))
			# Sadece pozitif rep koruma sağlar
			protection = maxf(rep, 0.0) * REPUTATION_PROTECTION

	var chance: float = BASE_ATTACK_CHANCE + cargo_risk - protection
	return clamp(chance, 0.0, MAX_ATTACK_CHANCE)

# Saldırı olup olmayacağına karar verir. true = saldırı oldu.
func roll_attack(destination_town: String) -> bool:
	var chance: float = calculate_attack_chance(destination_town)
	return randf() < chance

# Risk seviyesi etiketi (UI için).
func get_risk_label(chance: float) -> String:
	if chance < 0.10:
		return "Safe"
	elif chance < 0.20:
		return "Low Risk"
	elif chance < 0.30:
		return "Risky"
	else:
		return "Dangerous"
