import sys
import os
import random

# Add current folder to path
sys.path.append(os.path.dirname(__file__))

from economy_sim import EconomySim

def run_manual_trader_scenario():
    print("\n" + "="*50)
    print("SCENARIO 1: MANUEL TRADER (Only Manual Trade & Contracts)")
    print("="*50)
    
    sim = EconomySim()
    current_town = "Ashford"
    cargo = {} # {item_id: qty}
    
    travel_target = ""
    travel_days_left = 0
    
    days_to_ranks = {}
    
    for day in range(1, 201):
        # Update ranks checklist
        if sim.rank_id not in days_to_ranks:
            days_to_ranks[sim.rank_id] = day
            print(f"[Day {day}] Reached Rank: {sim.rank_id} (Gold: {sim.gold:.1f})")
            
        if sim.rank_id == "Patrician":
            print(f"--> PATRICIAN VICTORY achieved on Day {day}!")
            break
            
        # Tick the day
        if not sim.tick_day():
            print(f"--> GAME OVER: Player went bankrupt on Day {day} (debt_days >= 60)")
            break
            
        # Handle travel
        if travel_days_left > 0:
            travel_days_left -= 1
            if travel_days_left == 0:
                current_town = travel_target
                travel_target = ""
            else:
                continue # Traveling...
                
        # --- Player Decision Loop (Only runs when at a town) ---
        town = sim.towns[current_town]
        
        # 1. Sell cargo in current town
        total_cargo = sum(cargo.values())
        if total_cargo > 0:
            sold_items = list(cargo.keys())
            for item_id in sold_items:
                qty = cargo[item_id]
                if qty > 0:
                    sold, revenue = sim.sell_item(current_town, item_id, qty)
                    cargo[item_id] -= sold
                    if cargo[item_id] == 0:
                        del cargo[item_id]
                        
        # 2. Upgrade caravan if possible
        if sim.gold >= 400.0: # Keep 400g buffer
            cost = 300 if sim.caravan_level == 0 else (800 if sim.caravan_level == 1 else -1)
            if cost > 0 and sim.gold - cost >= 400.0:
                sim.gold -= cost
                sim.caravan_level += 1
                sim.caravan_capacity = 35 if sim.caravan_level == 1 else 50
                print(f"[Day {day}] Upgraded Caravan to Level {sim.caravan_level} (Cap: {sim.caravan_capacity})")

        # 3. Invest in prosperity if we have surplus gold and want to reach Patrician requirements
        # Keep 500g buffer
        if sim.gold > 500.0:
            invest_amount = min(200.0, sim.gold - 500.0)
            # Invest in Ashford, Ironmere, or Stonebridge (whichever has lower prosperity)
            target_invest = min(sim.towns.keys(), key=lambda t: sim.towns[t]["prosperity"])
            gained = sim.invest_gold(target_invest, invest_amount)

        # 4. Look for next travel target and trade rules
        best_item = None
        best_profit = -9999.0
        best_dest = None
        
        for dest in sim.towns:
            if dest == current_town:
                continue
                
            for item_id in sim.loader.items:
                buy_p = sim.get_buy_price(current_town, item_id)
                sell_p = sim.get_sell_price(dest, item_id)
                profit = (sell_p - buy_p)
                
                # Check if it's a profitable route
                if profit > best_profit and town["inventory"].get(item_id, 0.0) >= 5:
                    best_profit = profit
                    best_item = item_id
                    best_dest = dest
                    
        # Buy items and travel
        if best_dest and best_profit > 1.0:
            free_cap = sim.caravan_capacity - sum(cargo.values())
            to_buy = min(free_cap, int(town["inventory"].get(best_item, 0.0)))
            if to_buy > 0:
                bought, cost = sim.buy_item(current_town, best_item, to_buy)
                if bought > 0:
                    cargo[best_item] = cargo.get(best_item, 0) + bought
                    
            travel_target = best_dest
            travel_days_left = sim.loader.routes.get(current_town, {}).get(best_dest, {}).get("travel_days", 2)
        else:
            travel_target = random.choice([t for t in sim.towns.keys() if t != current_town])
            travel_days_left = sim.loader.routes.get(current_town, {}).get(travel_target, {}).get("travel_days", 2)

    # Report results
    print("\nManual Trader Scenario Report:")
    for rank, day in days_to_ranks.items():
        print(f"  Reached {rank} on Day {day}")
    print(f"  Final Gold: {sim.gold:.1f}")
    print(f"  Final Debt: {sim.debt:.1f}")
    print(f"  Ashford Prosperity: {sim.towns['Ashford']['prosperity']:.1f}")
    print(f"  Ironmere Prosperity: {sim.towns['Ironmere']['prosperity']:.1f}")
    print(f"  Stonebridge Prosperity: {sim.towns['Stonebridge']['prosperity']:.1f}")

def run_automation_scenario():
    print("\n" + "="*50)
    print("SCENARIO 2: AUTOMATION NETWORK (Posts & Caravan Masters)")
    print("="*50)
    
    sim = EconomySim()
    current_town = "Ashford"
    cargo = {}
    
    travel_target = ""
    travel_days_left = 0
    
    days_to_ranks = {}
    
    tp_built = set()
    masters_hired = 0
    
    for day in range(1, 201):
        if sim.rank_id not in days_to_ranks:
            days_to_ranks[sim.rank_id] = day
            print(f"[Day {day}] Reached Rank: {sim.rank_id} (Gold: {sim.gold:.1f})")
            
        if sim.rank_id == "Patrician":
            print(f"--> PATRICIAN VICTORY achieved on Day {day}!")
            break
            
        if not sim.tick_day():
            print(f"--> GAME OVER: Player went bankrupt on Day {day} (debt_days >= 60)")
            break
            
        # Build Trading Posts as soon as Merchant rank is unlocked (Rank index 2)
        if sim.rank_index >= 2:
            # Build TPs in all 3 towns if gold permits
            for t_id in sim.towns:
                if t_id not in tp_built and sim.gold >= 450.0: # Keep 150g buffer
                    if sim.build_trading_post(t_id):
                        tp_built.add(t_id)
                        print(f"[Day {day}] Built Trading Post at {t_id} (Gold remaining: {sim.gold:.1f})")
                        
        # Configure rules once TPs are built
        for t_id in tp_built:
            tp = sim.trading_posts[t_id]
            if not tp["rules"]:
                if t_id == "Ashford":
                    # Buy bread up to 25, sell iron, tool, wine
                    tp["rules"].append({"item_id": "bread", "type": "buy", "price_limit": 20.0, "amount_limit": 25})
                    tp["rules"].append({"item_id": "iron_bar", "type": "sell", "price_limit": 20.0, "amount_limit": 0})
                    tp["rules"].append({"item_id": "tool", "type": "sell", "price_limit": 30.0, "amount_limit": 0})
                    tp["rules"].append({"item_id": "wine", "type": "sell", "price_limit": 40.0, "amount_limit": 0})
                elif t_id == "Ironmere":
                    # Buy iron_bar/tool up to 20/15, sell bread
                    tp["rules"].append({"item_id": "iron_bar", "type": "buy", "price_limit": 25.0, "amount_limit": 20})
                    tp["rules"].append({"item_id": "tool", "type": "buy", "price_limit": 40.0, "amount_limit": 15})
                    tp["rules"].append({"item_id": "bread", "type": "sell", "price_limit": 0.0, "amount_limit": 0})
                elif t_id == "Stonebridge":
                    # Buy wine up to 15, sell bread
                    tp["rules"].append({"item_id": "wine", "type": "buy", "price_limit": 50.0, "amount_limit": 15})
                    tp["rules"].append({"item_id": "bread", "type": "sell", "price_limit": 0.0, "amount_limit": 0})

        # Hire Caravan Masters when Merchant or higher is unlocked
        if sim.rank_index >= 2 and len(tp_built) >= 2:
            # Hire master 1: route Ashford <-> Ironmere (Hauler Master for high capacity)
            if masters_hired == 0 and sim.gold >= 500.0:
                route1 = ["Ashford", "Ironmere"]
                rules1 = {
                    "Ashford": {"bread": "load", "iron_bar": "unload", "tool": "unload"},
                    "Ironmere": {"bread": "unload", "iron_bar": "load", "tool": "load"}
                }
                if sim.hire_caravan_master("hauler_master", route1, rules1):
                    masters_hired = 1
                    print(f"[Day {day}] Hired Hauler Master 1 for route Ashford <-> Ironmere")
            
            # Hire master 2: route Ashford <-> Stonebridge (Runner Master for speed)
            if masters_hired == 1 and len(tp_built) >= 3 and sim.gold >= 400.0:
                route2 = ["Ashford", "Stonebridge"]
                rules2 = {
                    "Ashford": {"bread": "load", "wine": "unload"},
                    "Stonebridge": {"bread": "unload", "wine": "load"}
                }
                if sim.hire_caravan_master("runner_master", route2, rules2):
                    masters_hired = 2
                    print(f"[Day {day}] Hired Runner Master 2 for route Ashford <-> Stonebridge")
                    
            # Hire master 3: route Ashford <-> Stonebridge (Apprentice Master to assist on Ashford <-> Stonebridge)
            if masters_hired == 2 and len(tp_built) >= 3 and sim.gold >= 1500.0:
                route3 = ["Ashford", "Stonebridge"]
                rules3 = {
                    "Ashford": {"bread": "load"},
                    "Stonebridge": {"bread": "unload"}
                }
                if sim.hire_caravan_master("apprentice_master", route3, rules3):
                    masters_hired = 3
                    print(f"[Day {day}] Hired Apprentice Master 3 for route Ashford <-> Stonebridge")

        # Handle manual travel if not automated yet
        if travel_days_left > 0:
            travel_days_left -= 1
            if travel_days_left == 0:
                current_town = travel_target
                travel_target = ""
            else:
                continue
                
        # Manual trading loop to support early gold accumulation
        town = sim.towns[current_town]
        
        # Sell cargo in current town
        total_cargo = sum(cargo.values())
        if total_cargo > 0:
            sold_items = list(cargo.keys())
            for item_id in sold_items:
                qty = cargo[item_id]
                if qty > 0:
                    sold, revenue = sim.sell_item(current_town, item_id, qty)
                    cargo[item_id] -= sold
                    if cargo[item_id] == 0:
                        del cargo[item_id]
                        
        # Invest surplus gold into prosperity (especially for rank requirements)
        # Keep a gold reserve that scales with our active upkeeps
        reserve = 400.0
        if sim.rank_index >= 3:
            reserve = 4200.0 # Save gold to reach Patrician rank requirement (10000 gold)
        
        if sim.gold > reserve:
            invest_amount = min(500.0, sim.gold - reserve)
            # Find town with lowest prosperity to invest in
            target_invest = min(sim.towns.keys(), key=lambda t: sim.towns[t]["prosperity"])
            gained = sim.invest_gold(target_invest, invest_amount)
            if gained > 0:
                print(f"[Day {day}] Invested in {target_invest}. New Prosperity: {sim.towns[target_invest]['prosperity']:.1f} (Gold remaining: {sim.gold:.1f})")
                
        # Next manual target
        best_item = None
        best_profit = -9999.0
        best_dest = None
        
        for dest in sim.towns:
            if dest == current_town:
                continue
            
            for item_id in sim.loader.items:
                buy_p = sim.get_buy_price(current_town, item_id)
                sell_p = sim.get_sell_price(dest, item_id)
                profit = (sell_p - buy_p)
                
                if profit > best_profit and town["inventory"].get(item_id, 0.0) >= 5:
                    best_profit = profit
                    best_item = item_id
                    best_dest = dest
                    
        if best_dest and best_profit > 1.0:
            free_cap = sim.caravan_capacity - sum(cargo.values())
            to_buy = min(free_cap, int(town["inventory"].get(best_item, 0.0)))
            if to_buy > 0:
                bought, cost = sim.buy_item(current_town, best_item, to_buy)
                if bought > 0:
                    cargo[best_item] = cargo.get(best_item, 0) + bought
            travel_target = best_dest
            travel_days_left = sim.loader.routes.get(current_town, {}).get(best_dest, {}).get("travel_days", 2)
        else:
            travel_target = random.choice([t for t in sim.towns.keys() if t != current_town])
            travel_days_left = sim.loader.routes.get(current_town, {}).get(travel_target, {}).get("travel_days", 2)

    # Report results
    print("\nAutomation Scenario Report:")
    for rank, day in days_to_ranks.items():
        print(f"  Reached {rank} on Day {day}")
    print(f"  Final Gold: {sim.gold:.1f}")
    print(f"  Final Debt: {sim.debt:.1f}")
    print(f"  Active Trading Posts: {len(sim.trading_posts)}")
    print(f"  Caravan Masters: {len(sim.caravan_masters)}")
    for idx, m in enumerate(sim.caravan_masters):
        print(f"    Master {idx+1} ({m['master_type']}): current_town={m['current_town']}, cargo={m['cargo']}")
    print(f"  Ashford Prosperity: {sim.towns['Ashford']['prosperity']:.1f}")
    print(f"  Ironmere Prosperity: {sim.towns['Ironmere']['prosperity']:.1f}")
    print(f"  Stonebridge Prosperity: {sim.towns['Stonebridge']['prosperity']:.1f}")
    print(f"  Ashford Bread Stock: {sim.towns['Ashford']['inventory'].get('bread', 0):.1f}")
    print(f"  Ironmere Bread Stock: {sim.towns['Ironmere']['inventory'].get('bread', 0):.1f}")
    print(f"  Stonebridge Bread Stock: {sim.towns['Stonebridge']['inventory'].get('bread', 0):.1f}")
    print(f"  Ashford Depot: {sim.trading_posts['Ashford']['depot'] if 'Ashford' in sim.trading_posts else {}}")
    print(f"  Ironmere Depot: {sim.trading_posts['Ironmere']['depot'] if 'Ironmere' in sim.trading_posts else {}}")
    print(f"  Stonebridge Depot: {sim.trading_posts['Stonebridge']['depot'] if 'Stonebridge' in sim.trading_posts else {}}")
    print(f"  Ironmere Depot Bread: {sim.trading_posts['Ironmere']['depot'].get('bread', 0) if 'Ironmere' in sim.trading_posts else 0:.1f}")
    print(f"  Stonebridge Depot Bread: {sim.trading_posts['Stonebridge']['depot'].get('bread', 0) if 'Stonebridge' in sim.trading_posts else 0:.1f}")

if __name__ == "__main__":
    # Seed random for reproducibility
    random.seed(42)
    run_manual_trader_scenario()
    run_automation_scenario()
