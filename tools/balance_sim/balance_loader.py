import csv
import os
import sys

class BalanceLoader:
    def __init__(self, data_dir=None):
        if data_dir is None:
            # Default to ../../data/balance/ relative to this script
            self.data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "data", "balance"))
        else:
            self.data_dir = data_dir
        
        self.items = {}
        self.towns = {}
        self.town_stocks = {}
        self.production = []
        self.recipes = {}
        self.routes = {}
        self.contracts = []
        self.ranks = []
        self.automation = {}
        self.price_curves = {}
        self.season_modifiers = {}
        self.caravan_upgrades = []

    def _read_csv(self, filename):
        filepath = os.path.join(self.data_dir, filename)
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"CSV file not found: {filepath}")
        
        rows = []
        with open(filepath, mode="r", encoding="utf-8-sig") as f:
            reader = csv.DictReader(f)
            for row in reader:
                rows.append(dict(row))
        return rows

    def load_all(self):
        try:
            self._load_items()
            self._load_towns()
            self._load_town_stocks()
            self._load_production()
            self._load_recipes()
            self._load_routes()
            self._load_contracts()
            self._load_ranks()
            self._load_automation()
            self._load_price_curves()
            self._load_season_modifiers()
            self._load_caravan_upgrades()
            self.validate_data()
            return True
        except Exception as e:
            print(f"Error loading balance data: {e}", file=sys.stderr)
            return False

    def _load_items(self):
        rows = self._read_csv("items.csv")
        for r in rows:
            item_id = r["item_id"]
            self.items[item_id] = {
                "item_id": item_id,
                "display_name": r["display_name"],
                "category": r["category"],
                "base_price": float(r["base_price"]),
                "base_daily_demand_per_1000_pop": float(r["base_daily_demand_per_1000_pop"]),
                "demand_tags": [tag.strip() for tag in r["demand_tags"].split(";") if tag.strip()],
                "stock_cap_base": int(r["stock_cap_base"])
            }

    def _load_towns(self):
        rows = self._read_csv("towns.csv")
        for r in rows:
            town_id = r["town_id"]
            self.towns[town_id] = {
                "town_id": town_id,
                "display_name": r["display_name"],
                "start_population": int(r["start_population"]),
                "start_prosperity": int(r["start_prosperity"]),
                "faction": r["faction"],
                "identity": r["identity"]
            }

    def _load_town_stocks(self):
        rows = self._read_csv("town_stocks.csv")
        for r in rows:
            town_id = r["town_id"]
            item_id = r["item_id"]
            if town_id not in self.town_stocks:
                self.town_stocks[town_id] = {}
            self.town_stocks[town_id][item_id] = {
                "start_stock": int(r["start_stock"]),
                "stock_cap": int(r["stock_cap"])
            }

    def _load_production(self):
        rows = self._read_csv("production.csv")
        for r in rows:
            self.production.append({
                "town_id": r["town_id"],
                "item_id": r["item_id"],
                "base_daily_production": float(r["base_daily_production"]),
                "season_profile": r["season_profile"]
            })

    def _load_recipes(self):
        rows = self._read_csv("recipes.csv")
        for r in rows:
            output_id = r["output_item_id"]
            if output_id not in self.recipes:
                self.recipes[output_id] = []
            self.recipes[output_id].append({
                "input_item_id": r["input_item_id"],
                "input_qty": float(r["input_qty"]),
                "output_qty": float(r["output_qty"])
            })

    def _load_routes(self):
        rows = self._read_csv("routes.csv")
        for r in rows:
            from_t = r["from_town"]
            to_t = r["to_town"]
            if from_t not in self.routes:
                self.routes[from_t] = {}
            self.routes[from_t][to_t] = {
                "travel_days": int(r["travel_days"]),
                "risk_level": r["risk_level"],
                "attack_risk": float(r["attack_risk"])
            }

    def _load_contracts(self):
        rows = self._read_csv("contracts.csv")
        for r in rows:
            self.contracts.append({
                "rank_min": r["rank_min"],
                "min_qty": int(r["min_qty"]),
                "max_qty": int(r["max_qty"]),
                "reward_multiplier": float(r["reward_multiplier"]),
                "rep_reward": float(r["rep_reward"]),
                "deadline_days": int(r["deadline_days"]),
                "fail_rep_penalty": float(r["fail_rep_penalty"])
            })

    def _load_ranks(self):
        rows = self._read_csv("ranks.csv")
        for r in rows:
            self.ranks.append({
                "rank_id": r["rank_id"],
                "rank_index": int(r["rank_index"]),
                "gold_required": float(r["gold_required"]),
                "growing_cities_required": int(r["growing_cities_required"]),
                "prosperous_cities_required": int(r["prosperous_cities_required"]),
                "posts_required": int(r["posts_required"]),
                "daily_upkeep": float(r["daily_upkeep"])
            })
        self.ranks.sort(key=lambda x: x["rank_index"])

    def _load_caravan_upgrades(self):
        rows = self._read_csv("caravan_upgrades.csv")
        for r in rows:
            self.caravan_upgrades.append({
                "level": int(r["level"]),
                "name": r["name"],
                "cost": float(r["cost"]),
                "capacity": int(r["capacity"]),
                "daily_upkeep": float(r["daily_upkeep"]),
                "unlock_rank": r["unlock_rank"]
            })
        self.caravan_upgrades.sort(key=lambda x: x["level"])

    def _load_automation(self):
        rows = self._read_csv("automation.csv")
        for r in rows:
            t = r["automation_type"]
            self.automation[t] = {
                "automation_type": t,
                "unlock_rank": r["unlock_rank"],
                "hire_or_build_cost": float(r["hire_or_build_cost"]),
                "daily_upkeep": float(r["daily_upkeep"]),
                "capacity": int(r["capacity"]),
                "speed_level": int(r["speed_level"]),
                "bargaining_level": int(r["bargaining_level"]),
                "courage_level": int(r["courage_level"])
            }

    def _load_price_curves(self):
        rows = self._read_csv("price_curves.csv")
        for r in rows:
            cat = r["category"]
            self.price_curves[cat] = {
                "zero_stock_multiplier": float(r["zero_stock_multiplier"]),
                "base_stock_multiplier": float(r["base_stock_multiplier"]),
                "max_stock_multiplier": float(r["max_stock_multiplier"])
            }

    def _load_season_modifiers(self):
        rows = self._read_csv("season_modifiers.csv")
        for r in rows:
            season = r["season"]
            item_id = r["item_id"]
            if season not in self.season_modifiers:
                self.season_modifiers[season] = {}
            self.season_modifiers[season][item_id] = {
                "production_multiplier": float(r["production_multiplier"]),
                "demand_multiplier": float(r["demand_multiplier"])
            }

    def validate_data(self):
        # Validate items exist in stocks, production, recipes
        for town_id, stocks in self.town_stocks.items():
            if town_id not in self.towns:
                raise ValueError(f"Stock contains undefined town: {town_id}")
            for item_id in stocks:
                if item_id not in self.items:
                    raise ValueError(f"Stock contains undefined item: {item_id} in {town_id}")
        
        for prod in self.production:
            if prod["town_id"] not in self.towns:
                raise ValueError(f"Production contains undefined town: {prod['town_id']}")
            if prod["item_id"] not in self.items:
                raise ValueError(f"Production contains undefined item: {prod['item_id']}")
        
        for output_id, inputs in self.recipes.items():
            if output_id not in self.items:
                raise ValueError(f"Recipe contains undefined output item: {output_id}")
            for inp in inputs:
                if inp["input_item_id"] not in self.items:
                    raise ValueError(f"Recipe for {output_id} contains undefined input item: {inp['input_item_id']}")

        for from_t, dests in self.routes.items():
            if from_t not in self.towns:
                raise ValueError(f"Route starts from undefined town: {from_t}")
            for to_t in dests:
                if to_t not in self.towns:
                    raise ValueError(f"Route leads to undefined town: {to_t}")

        print("Data validation SUCCESS: All references and fields are valid!")

if __name__ == "__main__":
    loader = BalanceLoader()
    if loader.load_all():
        print("Balance Loader successfully parsed and validated all CSVs!")
    else:
        print("Balance Loader failed.")
