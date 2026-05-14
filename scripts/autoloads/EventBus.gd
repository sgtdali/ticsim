extends Node

# --- Economy Events ---
signal economy_updated
signal item_bought(town_name: String, item: String, qty: int, price: float)
signal item_sold(town_name: String, item: String, qty: int, price: float)
signal town_invested(town_name: String, gold_amount: float, prosperity_gained: int)

# --- Contract Events ---
signal contracts_changed
signal contract_accepted(contract_id: String)
signal contract_completed(contract_id: String)
signal contract_failed(contract_id: String)

# --- UI Events ---
signal open_town(town_name: String)
signal close_town
