import math
import sys
from balance_loader import BalanceLoader

class EconomySim:
    def __init__(self):
        self.loader = BalanceLoader()
        if not self.loader.load_all():
            raise RuntimeError("Failed to load balance CSV data.")
        
        # Sim State
        self.current_day = 1
        self.gold = 400.0
        self.debt = 0.0
        self.debt_days = 0
        self.rank_index = 0
        self.rank_id = "Peddler"
        
        # Town states: { town_id: { population, prosperity, inventory: { item_id: qty }, prices: { item_id: price } } }
        self.towns = {}
        self._init_towns()
        
        # Trading Posts: { town_id: { rules: [ { item_id, type: "buy"/"sell", price_limit, amount_limit } ] } }
        self.trading_posts = {}
        
        # Caravan Masters: [ { master_type, current_town, target_town, travel_days_left, route: [town_ids], cargo: {item_id: qty} } ]
        self.caravan_masters = []
        
        # Caravan Upgrade Level: 0 = Donkey (20), 1 = Horse (35), 2 = Large (50)
        self.caravan_level = 0
        self.caravan_capacity = 20
        
        # Active contracts: [ { id, source, target, item, qty, reward_gold, deadline_day } ]
        self.active_contracts = []
        self.completed_contracts_count = 0
        self.failed_contracts_count = 0
        
        # Daily history log for stats
        self.history = []

    def _init_towns(self):
        for town_id, t in self.loader.towns.items():
            self.towns[town_id] = {
                "town_id": town_id,
                "display_name": t["display_name"],
                "population": float(t["start_population"]),
                "prosperity": float(t["start_prosperity"]),
                "inventory": {},
                "prices": {}
            }
            # Initialize stocks from town_stocks.csv
            if town_id in self.loader.town_stocks:
                for item_id, stock_info in self.loader.town_stocks[town_id].items():
                    self.towns[town_id]["inventory"][item_id] = float(stock_info["start_stock"])
            
            # Fill missing items with 0 stock
            for item_id in self.loader.items:
                if item_id not in self.towns[town_id]["inventory"]:
                    self.towns[town_id]["inventory"][item_id] = 0.0
            
            # Initial price calculation
            self.recalculate_town_prices(town_id)

    def get_season(self):
        # 30 days per season
        idx = int(((self.current_day - 1) // 30) % 4)
        return ["spring", "summer", "autumn", "winter"][idx]

    def get_season_multiplier(self, item_id, type_key="production_multiplier"):
        season = self.get_season()
        if season in self.loader.season_modifiers and item_id in self.loader.season_modifiers[season]:
            return self.loader.season_modifiers[season][item_id][type_key]
        return 1.0

    def get_prosperity_multiplier(self, prosperity):
        if prosperity >= 65:
            return 1.50
        elif prosperity >= 30:
            return 1.20
        return 1.00

    def get_daily_demand(self, town_id, item_id):
        town = self.towns[town_id]
        item = self.loader.items[item_id]
        pop = town["population"]
        base_demand = item["base_daily_demand_per_1000_pop"]
        prop_mult = self.get_prosperity_multiplier(town["prosperity"])
        season_mult = self.get_season_multiplier(item_id, "demand_multiplier")
        return (pop * base_demand / 1000.0) * prop_mult * season_mult

    def recalculate_town_prices(self, town_id):
        town = self.towns[town_id]
        for item_id, item in self.loader.items.items():
            qty = town["inventory"].get(item_id, 0.0)
            daily_demand = self.get_daily_demand(town_id, item_id)
            stock_cap = self.loader.town_stocks.get(town_id, {}).get(item_id, {}).get("stock_cap", item["stock_cap_base"])
            
            cat = item["category"]
            curves = self.loader.price_curves.get(cat, {"zero_stock_multiplier": 2.2, "base_stock_multiplier": 1.0, "max_stock_multiplier": 0.45})
            
            zero_mult = curves["zero_stock_multiplier"]
            base_mult = curves["base_stock_multiplier"]
            max_mult = curves["max_stock_multiplier"]
            
            if daily_demand > 0:
                days_of_stock = qty / daily_demand
                if days_of_stock <= 14.0:
                    # Interpolate zero_mult to base_mult
                    t = days_of_stock / 14.0
                    multiplier = zero_mult - (zero_mult - base_mult) * t
                elif days_of_stock <= 42.0:
                    # Interpolate base_mult to max_mult
                    t = (days_of_stock - 14.0) / 28.0
                    multiplier = base_mult - (base_mult - max_mult) * t
                else:
                    multiplier = max_mult
            else:
                # No daily demand: fall back to capacity ratio
                cap_ratio = min(1.0, qty / max(1.0, stock_cap))
                multiplier = zero_mult - (zero_mult - max_mult) * cap_ratio
                
            town["prices"][item_id] = item["base_price"] * multiplier

    def get_buy_price(self, town_id, item_id):
        price = self.towns[town_id]["prices"][item_id]
        # 8% Bid/Ask Spread (buy is higher)
        return price * 1.08

    def get_sell_price(self, town_id, item_id):
        price = self.towns[town_id]["prices"][item_id]
        # 8% Bid/Ask Spread (sell is lower)
        return price * 0.92

    def get_upkeep(self):
        # Caravan Upkeep
        caravan_upkeeps = [2.0, 5.0, 10.0]
        c_upkeep = caravan_upkeeps[self.caravan_level]
        
        # Rank Upkeep
        rank_upkeeps = {
            "Peddler": 0.0,
            "Trader": 3.0,
            "Merchant": 8.0,
            "Guild Master": 20.0,
            "Patrician": 0.0
        }
        r_upkeep = rank_upkeeps.get(self.rank_id, 0.0)
        
        # Trading Post Upkeep
        tp_cost = self.loader.automation["trading_post"]["daily_upkeep"]
        tp_upkeep = len(self.trading_posts) * tp_cost
        
        # Caravan Master wages
        master_upkeep = 0.0
        for m in self.caravan_masters:
            master_upkeep += self.loader.automation[m["master_type"]]["daily_upkeep"]
            
        return c_upkeep + r_upkeep + tp_upkeep + master_upkeep

    def buy_item(self, town_id, item_id, qty):
        """Player buys item from town market."""
        town = self.towns[town_id]
        total_cost = 0.0
        actual_bought = 0
        
        for _ in range(qty):
            price = self.get_buy_price(town_id, item_id)
            if self.gold >= price and town["inventory"][item_id] >= 1:
                self.gold -= price
                town["inventory"][item_id] -= 1
                total_cost += price
                actual_bought += 1
                # Recalculate price after single item change (marginal pricing)
                self.recalculate_town_prices(town_id)
            else:
                break
                
        return actual_bought, total_cost

    def sell_item(self, town_id, item_id, qty):
        """Player sells item to town market."""
        town = self.towns[town_id]
        total_revenue = 0.0
        actual_sold = 0
        stock_cap = self.loader.town_stocks.get(town_id, {}).get(item_id, {}).get("stock_cap", self.loader.items[item_id]["stock_cap_base"])
        
        for _ in range(qty):
            price = self.get_sell_price(town_id, item_id)
            if town["inventory"][item_id] < stock_cap:
                # Earn gold (first pays debt, then gold)
                self.add_gold(price)
                town["inventory"][item_id] += 1
                total_revenue += price
                actual_sold += 1
                # Recalculate price
                self.recalculate_town_prices(town_id)
            else:
                break
                
        return actual_sold, total_revenue

    def add_gold(self, amount):
        if self.debt > 0.0:
            payment = min(amount, self.debt)
            self.debt -= payment
            amount -= payment
            if self.debt <= 0.0:
                self.debt = 0.0
                self.debt_days = 0
        self.gold += amount

    def invest_gold(self, town_id, gold_amount):
        """Invest gold to increase town prosperity."""
        if self.debt > 0.0:
            return 0 # No investment while in debt
        if self.gold < gold_amount:
            gold_amount = self.gold
            
        town = self.towns[town_id]
        p = town["prosperity"]
        
        # basamaklı yatırım maliyeti (0-29 -> 25g, 30-64 -> 50g, 65+ -> 100g)
        gold_spent = 0.0
        prosperity_gained = 0.0
        
        while gold_spent < gold_amount and p < 100.0:
            if p < 30.0:
                cost = 25.0
            elif p < 65.0:
                cost = 50.0
            else:
                cost = 100.0
                
            if (gold_amount - gold_spent) >= cost:
                gold_spent += cost
                prosperity_gained += 1.0
                p += 1.0
            else:
                break
                
        self.gold -= gold_spent
        town["prosperity"] = p
        return prosperity_gained

    def tick_day(self):
        # 1. Pay Upkeep / Debt
        upkeep = self.get_upkeep()
        if self.gold >= upkeep:
            self.gold -= upkeep
        else:
            unpaid = upkeep - self.gold
            self.gold = 0.0
            self.debt += unpaid
            
        if self.debt > 0.0:
            self.debt_days += 1
            if self.debt_days >= 60:
                # Game Over
                return False
        else:
            self.debt_days = 0

        # 2. Production Phase
        for town_id, town in self.towns.items():
            self._process_town_production(town_id)

        # 3. Consumption Phase
        for town_id, town in self.towns.items():
            self._process_town_consumption(town_id)

        # 4. Recalculate Prices
        for town_id in self.towns:
            self.recalculate_town_prices(town_id)

        # 5. Trading Post Auto-Trade
        self._process_trading_post_rules()

        # 6. Caravan Master Route Progress
        self._process_caravan_masters()

        # 7. NPC Traders background stock adjustments
        self._process_npc_traders()

        # 8. Check Contract Deadlines
        self._process_contracts_deadlines()

        # 9. Rank Up Evaluation
        self._check_rank_up()

        # Log daily stats
        self.history.append({
            "day": self.current_day,
            "gold": self.gold,
            "debt": self.debt,
            "debt_days": self.debt_days,
            "rank": self.rank_id,
            "upkeep": upkeep,
            "towns": {
                town_id: {
                    "prosperity": t["prosperity"],
                    "population": t["population"],
                    "stocks": t["inventory"].copy()
                } for town_id, t in self.towns.items()
            }
        })
        
        self.current_day += 1
        return True

    def _process_town_production(self, town_id):
        town = self.towns[town_id]
        prop_mult = self.get_prosperity_multiplier(town["prosperity"])
        
        # Raw production (Natural Resources)
        # In Godot raw resources come from slots. In our CSV production plan:
        # We model base_daily_production directly as the town's resource capacity.
        # We process production of all items listed in production.csv for this town.
        for prod in self.loader.production:
            if prod["town_id"] != town_id:
                continue
            item_id = prod["item_id"]
            base_prod = prod["base_daily_production"]
            season_mult = self.get_season_multiplier(item_id, "production_multiplier")
            
            planned = base_prod * prop_mult * season_mult
            
            # Check inputs if output is a recipe
            efficiency = 1.0
            if item_id in self.loader.recipes:
                for recipe in self.loader.recipes[item_id]:
                    inp_id = recipe["input_item_id"]
                    req_qty = recipe["input_qty"] * planned
                    if req_qty > 0:
                        in_stock = town["inventory"].get(inp_id, 0.0)
                        efficiency = min(efficiency, in_stock / req_qty)
            
            actual_produced = planned * efficiency
            stock_cap = self.loader.town_stocks.get(town_id, {}).get(item_id, {}).get("stock_cap", self.loader.items[item_id]["stock_cap_base"])
            
            # Consume inputs
            if item_id in self.loader.recipes and actual_produced > 0:
                for recipe in self.loader.recipes[item_id]:
                    inp_id = recipe["input_item_id"]
                    req_qty = recipe["input_qty"] * actual_produced
                    town["inventory"][inp_id] = max(0.0, town["inventory"][inp_id] - req_qty)
            
            # Add output to stock (cannot exceed stock_cap)
            town["inventory"][item_id] = min(stock_cap, town["inventory"][item_id] + actual_produced)

    def _process_town_consumption(self, town_id):
        town = self.towns[town_id]
        
        # Track survival satisfaction
        survival_deltas = []
        comfort_deltas = []
        critical_shortage = False
        
        for item_id, item in self.loader.items.items():
            daily_demand = self.get_daily_demand(town_id, item_id)
            if daily_demand <= 0:
                continue
                
            in_stock = town["inventory"].get(item_id, 0.0)
            consumed = min(in_stock, daily_demand)
            town["inventory"][item_id] -= consumed
            
            satisfaction = consumed / daily_demand
            
            # Check survival items for prosperity delta
            if item["category"] == "survival":
                if satisfaction >= 0.80:
                    delta = 2
                elif satisfaction >= 0.40:
                    delta = -1
                else:
                    delta = -4
                    critical_shortage = True
                survival_deltas.append(delta)
            
            # Check comfort/luxury items for prosperity delta (only applies at prosperity >= 70)
            elif item["category"] == "comfort":
                if town["prosperity"] >= 70.0:
                    if satisfaction >= 0.80:
                        delta = 0.5
                    elif satisfaction < 0.40:
                        delta = -1.0
                    else:
                        delta = 0.0
                    comfort_deltas.append(delta)
                
        # Total prosperity delta (clamp prosperity between 0 and 100)
        total_delta = sum(survival_deltas) + sum(comfort_deltas)
        # Clamp daily prosperity change as per mvp_balance: min -3, max +2
        total_delta = max(-3.0, min(2.0, total_delta))
        town["prosperity"] = max(0.0, min(100.0, town["prosperity"] + total_delta))
        
        # Population update
        if critical_shortage:
            town["population"] = max(10.0, town["population"] * 0.97) # Lose 3%
        else:
            # Grow based on prosperity level
            level_mult = 0.01
            if town["prosperity"] >= 65:
                level_mult = 0.02
            elif town["prosperity"] >= 30:
                level_mult = 0.015
            town["population"] += town["population"] * level_mult
            town["population"] = min(2000.0, town["population"]) # Cap at 2000 for simulation

    def _process_trading_post_rules(self):
        """Run auto-buy and auto-sell rules on Trading Posts."""
        if self.debt > 0.0:
            return # TP rules don't process while in debt
            
        for town_id, tp in self.trading_posts.items():
            town = self.towns[town_id]
            for rule in tp["rules"]:
                item_id = rule["item_id"]
                rtype = rule["type"]
                price_limit = rule["price_limit"]
                amount_limit = rule["amount_limit"]
                
                # Check current depot stock vs rule limits
                current_depot_qty = tp["depot"].get(item_id, 0)
                
                if rtype == "buy" and current_depot_qty < amount_limit:
                    depot_total = sum(tp["depot"].values())
                    global_space = max(0, tp["capacity"] - depot_total)
                    if global_space > 0:
                        buy_price = self.get_buy_price(town_id, item_id)
                        if buy_price <= price_limit and town["inventory"][item_id] >= 1:
                            # Buy as many as possible up to limit and gold
                            to_buy = min(amount_limit - current_depot_qty, global_space, int(town["inventory"][item_id]))
                            actual_bought, cost = self.buy_item(town_id, item_id, to_buy)
                            tp["depot"][item_id] = current_depot_qty + actual_bought
                        
                elif rtype == "sell" and current_depot_qty > amount_limit:
                    sell_price = self.get_sell_price(town_id, item_id)
                    if sell_price >= price_limit:
                        stock_cap = self.loader.town_stocks.get(town_id, {}).get(item_id, {}).get("stock_cap", self.loader.items[item_id]["stock_cap_base"])
                        free_space = int(stock_cap - town["inventory"][item_id])
                        if free_space > 0:
                            to_sell = min(current_depot_qty - amount_limit, free_space)
                            actual_sold, rev = self.sell_item(town_id, item_id, to_sell)
                            tp["depot"][item_id] = current_depot_qty - actual_sold

    def _process_caravan_masters(self):
        """Simulate caravan master route steps."""
        for m in self.caravan_masters:
            if m["travel_days_left"] > 0:
                m["travel_days_left"] -= 1
                if m["travel_days_left"] == 0:
                    m["current_town"] = m["target_town"]
                    m["target_town"] = ""
                    # Arrived! Execute depot operations
                    self._execute_master_depot_ops(m)
            else:
                # Idle, start travel to next stop in route
                self._start_master_travel(m)

    def _start_master_travel(self, m):
        if not m["route"] or len(m["route"]) < 2:
            return
        
        curr = m["current_town"]
        # Find next town in route index
        try:
            idx = m["route"].index(curr)
            next_idx = (idx + 1) % len(m["route"])
        except ValueError:
            next_idx = 0
            
        target = m["route"][next_idx]
        m["target_town"] = target
        m["current_town"] = ""
        
        # Get travel days from routes.csv
        days = self.loader.routes.get(curr, {}).get(target, {}).get("travel_days", 2)
        # Apply speed level discount (10% per level, max 40%)
        speed_bonus = 0.10 * m["speed_level"]
        actual_days = max(1, int(round(days * (1.0 - min(0.40, speed_bonus)))))
        m["travel_days_left"] = actual_days

    def _execute_master_depot_ops(self, m):
        """Applies Load/Unload route rules at a Trading Post depot."""
        town_id = m["current_town"]
        if town_id not in self.trading_posts:
            return # No Trading Post, cannot load/unload
            
        tp = self.trading_posts[town_id]
        capacity = self.loader.automation[m["master_type"]]["capacity"]
        
        # Load / Unload rules logic
        # Rules structure is: { town_id: { item_id: "load"/"unload" } }
        town_rules = m.get("rules", {}).get(town_id, {})
        for item_id, rule_type in town_rules.items():
            if rule_type == "unload":
                qty = m["cargo"].get(item_id, 0)
                if qty > 0:
                    depot_free_space = max(0, tp["capacity"] - sum(tp["depot"].values()))
                    to_transfer = min(qty, depot_free_space)
                    tp["depot"][item_id] = tp["depot"].get(item_id, 0) + to_transfer
                    m["cargo"][item_id] = m["cargo"].get(item_id, 0) - to_transfer
                    # print(f"[Day {self.current_day}] Caravan Master unloaded {to_transfer} {item_id} at {town_id}")
                    
            elif rule_type == "load":
                current_cargo = sum(m["cargo"].values())
                cargo_free_space = max(0, capacity - current_cargo)
                depot_qty = tp["depot"].get(item_id, 0)
                if cargo_free_space > 0 and depot_qty > 0:
                    to_load = min(depot_qty, cargo_free_space)
                    tp["depot"][item_id] -= to_load
                    m["cargo"][item_id] = m["cargo"].get(item_id, 0) + to_load
                    # print(f"[Day {self.current_day}] Caravan Master loaded {to_load} {item_id} at {town_id}")

    def _process_npc_traders(self):
        """Simulate autonomous NPC traders who move and adjust stocks randomly."""
        # Every day, there is a small chance (e.g. 20%) that an NPC trader visits a town,
        # buying cheap items and selling expensive items to fluctuate prices and prevent route stagnation.
        for town_id, town in self.towns.items():
            # Random fluctuations
            for item_id in self.loader.items:
                # 5% chance of NPC transaction
                import random
                if random.random() < 0.08:
                    # Is it cheap? Buy it.
                    price = town["prices"][item_id]
                    base_price = self.loader.items[item_id]["base_price"]
                    if price < base_price * 0.8 and town["inventory"][item_id] >= 5:
                        qty = random.randint(2, 6)
                        town["inventory"][item_id] -= qty
                    # Is it expensive? Sell it.
                    elif price > base_price * 1.2:
                        qty = random.randint(2, 6)
                        stock_cap = self.loader.town_stocks.get(town_id, {}).get(item_id, {}).get("stock_cap", self.loader.items[item_id]["stock_cap_base"])
                        if town["inventory"][item_id] + qty <= stock_cap:
                            town["inventory"][item_id] += qty

    def _process_contracts_deadlines(self):
        # Handle active contract deadlines
        expired = []
        for c in self.active_contracts:
            if self.current_day > c["deadline_day"]:
                expired.append(c)
                
        for c in expired:
            self.active_contracts.remove(c)
            self.failed_contracts_count += 1
            # Apply reputation penalty in Godot (simulated as slight rep penalty, no direct gold penalty)

    def _check_rank_up(self):
        """Evaluates progression criteria and updates the player's rank."""
        # Requirements read from ranks.csv
        for r in self.loader.ranks:
            if r["rank_index"] <= self.rank_index:
                continue
                
            # Check gold
            if self.gold < r["gold_required"]:
                break
                
            # Check growing cities
            growing_count = 0
            prosperous_count = 0
            for t in self.towns.values():
                if t["prosperity"] >= 65:
                    prosperous_count += 1
                elif t["prosperity"] >= 30:
                    growing_count += 1
            
            # Prosperity condition: GM requires 2 Growing + 1 Prosperous.
            # Ranks requirements defined: growing_cities_required, prosperous_cities_required
            # A prosperous city also counts as growing
            total_growing = growing_count + prosperous_count
            if total_growing < r["growing_cities_required"] or prosperous_count < r["prosperous_cities_required"]:
                break
                
            # Check posts
            if len(self.trading_posts) < r["posts_required"]:
                break
                
            # Requirements met! Promote!
            self.rank_index = r["rank_index"]
            self.rank_id = r["rank_id"]

    def build_trading_post(self, town_id):
        cost = self.loader.automation["trading_post"]["hire_or_build_cost"]
        if self.gold >= cost and town_id not in self.trading_posts:
            self.gold -= cost
            self.trading_posts[town_id] = {
                "capacity": self.loader.automation["trading_post"]["capacity"],
                "depot": {},
                "rules": []
            }
            return True
        return False

    def hire_caravan_master(self, master_type, route, rules):
        cost = self.loader.automation[master_type]["hire_or_build_cost"]
        if self.gold >= cost:
            self.gold -= cost
            m = {
                "master_type": master_type,
                "current_town": route[0],
                "target_town": "",
                "travel_days_left": 0,
                "route": list(route),
                "cargo": {},
                "rules": dict(rules),
                "speed_level": self.loader.automation[master_type]["speed_level"],
                "bargaining_level": self.loader.automation[master_type]["bargaining_level"],
                "courage_level": self.loader.automation[master_type]["courage_level"]
            }
            self.caravan_masters.append(m)
            return True
        return False

    def accept_delivery_contract(self, source, target, item, qty, reward_gold, duration):
        c = {
            "id": f"contract_{len(self.active_contracts) + self.completed_contracts_count + self.failed_contracts_count}",
            "source": source,
            "target": target,
            "item": item,
            "qty": qty,
            "reward_gold": reward_gold,
            "deadline_day": self.current_day + duration
        }
        self.active_contracts.append(c)

    def complete_delivery_contract(self, contract_id):
        for c in self.active_contracts:
            if c["id"] == contract_id:
                self.active_contracts.remove(c)
                self.add_gold(c["reward_gold"])
                self.completed_contracts_count += 1
                return True
        return False
