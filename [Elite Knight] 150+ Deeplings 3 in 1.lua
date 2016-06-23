------ REFILL SETTINGS ------

local LeaveMana = 270 --- How many mana potions until you leave the hunt?
local BuyMana = 1900 --- How many mana potions you begin the hunt with?

local LeaveHealth = 30 --- How many health potions until you leave the hunt?
local BuyHealth = 300 --- How many health potions you begin the hunt with?

local LeaveCap = 50 --- Leaves spawn when character reaches this cap.

local UseHaste = true --- Do you want use haste when bot go/leave from respawn?
local TypeHaste = 'utani hur'

-- HEALING SETTINGS -- CHANGE ONLY PERCENT

local healing = {
    {spell = 'exura gran ico', percent = 25, mana = 200},
    {spell = 'exura ico', percent = 85, mana = 40}
}

-- Sort Suppiles (Change name if you use others type of suppiles)

SortSuppiles = {
    {id = Item.GetID('Mana Potion'), bp = 'Zaoan Chess Box'},
    {id = Item.GetID('Supreme Health Potion'), bp = 'Zaoan Chess Box'}
    }

-- Potions Settings (Change names and prices if you use other potions):

local ManaName = 'Mana Potion' 
local ManaCost = 50

local HealthName = 'Supreme Health Potion' 
local HealthCost = 500

-- Backpack Configuration:

local MainBP = 'Backpack of Holding'

local SuppliesBP = 'Zaoan Chess Box'

local LootBP = 'Jewelled Backpack'

local UseExtraBackpack = false  --- Do you want use extra backpack? (For amulets etc)
local ExtraBP = 'Golden Backpack' --- If you dont want use extra backpack, ignore it!!!

local HideEquipment = true --- Do you want minimize your equipment?
local MinimizeBackpack = false --- Do you want minimize your backpacks?

--- Amulets , Rings, Food Configuration

local WithdrawFood = false  --- Do you want withdraw food? (Backpack of food must be at 2nd slot in your depot.)
local FoodName = 'Brown Mushroom'  --- Food name.
local Amount = 100  --- What amount of food you want to withdraw?

local useAmulets = false --- Do you want use amulets?
local AmuletName = 'Protection Amulet'
local WithdrawAmulets = false --- Do you want withdraw amulets? (You must UseExtraBackpack) (Backpack of amulets must be at 2nd slot in your depot.)
local AmountAmulets = 3 --- What amount of rings you want to withdraw?

local useRings = false --- Do you want use rings? 
local RingName = 'Dwarven Ring'
local WithdrawRings = false --- Do you want withdraw rings? (You must UseExtraBackpack) (Backpack of rings must be at 2nd slot in your depot.)
local AmountRings = 1 --- What amount of rings you want to withdraw?

--- Soft Boots, 

local Softboots = false --- Do you want use softboots? 
local ManaToEquip = 70 -- Mana Percent to equip soft boots.
local NormalBoots = 'Draken Boots' --- Your normal boots.

-- Extra Settings

local LowStamina = true --- Do you want logout if stamina drops below 16 hours?

local ManaRestore = false --- Do you want restore mana to x percent if no monsters on screen?
local RestoreManaToPercent = 90

local HealthRestore = false --- Do you want restore health to x percent if no monsters on screen?(Recommended only for eks)
local SpellToUse = 'exura ico' --- What spell you want use to restore health?
local ManaForThisSpell = 40 --- exura ico - 40
local RestoreHealthToPercent = 90

-- DO NOT CHANGE AFTER THIS UNLESS YOU ARE EXPERIENCED WITH SCRIPTING--.

local MinimizeBackpack = mini
local ringID = Item.GetItemIDFromDualInput(RingName)

--- Functions

function ManaPercent()
    return math.ceil(Self.Mana() / Self.MaxMana() * 100)
end

function HealthPercent()
    return math.ceil(Self.Health() / Self.MaxHealth() * 100)
end

function moveItems(table)
    local fromBP = Container.GetFirst()
    for spot, item in fromBP:iItems() do
        for _, data in pairs(table) do
            if item.id == data.id then
                local toBP = Container.New(data.bp)
                fromBP:MoveItemToContainer(spot, toBP:Index(), 0)
                     wait(Self.Ping() + 100, Self.Ping() + 300)
                return moveItems(table)
            end
        end
    end
end

--- Modules

Module.New('ManaRestore', function(RestoreH)
        if (ManaPercent() < RestoreManaToPercent) and (#Self.GetTargets(8) == 0) and (Self.ItemCount(ManaName) > 0) and (ManaRestore) then
                Walker.Stop()
                while (ManaPercent() < RestoreManaToPercent) and (#Self.GetTargets(8) == 0) and (Self.ItemCount(ManaName) > 0) do
                        Self.UseItemWithMe(ManaName)
                        wait(500,700)
                end
                Walker.Start()
        end
        RestoreH:Delay(500)
end)

Module.New('HealthRestore', function(RestoreH)
    if (HealthPercent() < RestoreHealthToPercent) and (#Self.GetTargets(8) == 0) and (Self.ItemCount(ManaName) > 0) and (HealthRestore) then
            Walker.Stop()
            while (HealthPercent() < RestoreHealthToPercent) and (#Self.GetTargets(8) == 0) and (Self.ItemCount(ManaName) > 0) do
                    Self.Cast(SpellToUse, ManaForThisSpell)
                    wait(500,700)
            end
        Walker.Start()
    end    
    RestoreH:Delay(500)
end)

Module.New('ItemMover', function(Mover)
	moveItems(SortSuppiles)
	Mover:Delay(500, 600)
	end)

Module.New('Amulets', function(Amulet)
    if (useAmulets) and (Self.ItemCount(AmuletName) > 0) and (Self.Amulet().id ~= Item.GetItemIDFromDualInput(AmuletName)) then
    	Self.Equip(AmuletName, 'amulet')
    end
        Amulet:Delay(2000, 4000)
end)

Module.New('Rings', function(Ring)
    if (useRings) and (Self.ItemCount(RingName) > 0) and (Self.Ring().id ~= Item.GetRingActiveID(ringID)) then
    	Self.Equip(ringID, 'ring')
    end    	  	   	    		
        Ring:Delay(3000, 5000)
end)

Module.New('Equip Softs', function(Softs)
    if (Softboots) and (ManaPercent() <= ManaToEquip) and (Self.Feet().id ~= 3549) and (Self.ItemCount(6529) > 0) then
        Self.Equip(6529, 'feet')
        Softs:Delay(1000)
    elseif (ManaPercent() >= ManaToEquip) or (Self.Feet().id == 6530) and (Self.Feet().id ~= NormalBoots) then
        Self.Equip(NormalBoots, 'feet')
        Softs:Delay(1000)
    end
end)

Module('Refill Haster', function(Speed)
    if not Self.isHasted() and not Self.isInPz() and (UseHaste) and (TypeHaste == 'utani hur') then
        Self.Cast('utani hur', 60)
   	end
    Speed:Delay(1000)
end)

Module.New('Heal', function(Healing)
	for i = 1, #healing do
		if (HealthPercent() <= healing[i].percent) then
			if (getSelfSpellCooldown(healing[i].spell) == 0 and Self.Mana() >= healing[i].mana) then
				Self.Say(healing[i].spell)
			end
		end
	end
	Healing:Delay(200)
end)

NpcMessageProxy.OnReceive('SafeBank', function(proxy, npcName, message)
	local safemoney = string.match(message, "You don't have enough money in bank.")
	if safemoney then
		Cavebot.Stop()
		wait(2000)
		Self.Logout()
	end
end)

GenericTextMessageProxy.OnReceive('AntyRedSkull', function(proxy, message)
    if (string.find(string.lower(message), "the murder of")) then
        os.exit()
    end
end)

registerEventListener(WALKER_SELECTLABEL, 'onWalkerSelectLabel')

function onWalkerSelectLabel(labelName)
	if (labelName == 'CheckerEast') then		
		Walker.ConditionalGoto((Self.ItemCount(ManaName) <= LeaveMana) or (Self.Cap() < LeaveCap) or (Self.ItemCount(HealthName) <= LeaveHealth), 'Leave', 'WestSpawn')

	elseif (labelName == 'CheckerWest') then
		Walker.ConditionalGoto((Self.ItemCount(ManaName) <= LeaveMana) or (Self.Cap() < LeaveCap) or (Self.ItemCount(HealthName) <= LeaveHealth), 'Leave', 'SouthSpawn')

	elseif (labelName == 'CheckerSouth') then
		Walker.ConditionalGoto((Self.ItemCount(ManaName) <= LeaveMana) or (Self.Cap() < LeaveCap) or (Self.ItemCount(HealthName) <= LeaveHealth), 'Leave', 'EastSpawn') 

	elseif (labelName == 'Start') then
		print([[If you want withdraw some items from depot, you must make sure that you have enought capacity. ]])
		if (ManaRestore) then
			wait(300)
			Module.Stop('ManaRestore')
		end
		if (HealthRestore) then
			wait(300)
			Module.Stop('HealthRestore')
		end
		if (useAmulets) then
			wait(300)
			Module.Stop('Amulets')
		end
		if (useRings) then
			wait(300)
			Module.Stop('Rings')
		end

	elseif (labelName == 'Bank') then
		Walker.Stop()
		Self.SayToNpc({'hi', 'deposit all', 'yes'}, 100)

		local withdrawManas = math.max(BuyMana - Self.ItemCount(ManaName), 0)*ManaCost
		local withdrawHealths = math.max(BuyHealth - Self.ItemCount(HealthName), 0)*HealthCost
		local extracash = 1500
		local total = math.abs(withdrawManas + withdrawHealths + extracash)
		
		if total >= 1 then
			Self.SayToNpc({'withdraw ' .. total, 'yes', 'balance'}, 100)
		end
		if (Softboots) and (Self.ItemCount(6529) == 0) then
		Self.WithdrawMoney((10000*(Self.ItemCount(6530)))+800)
		wait(500)
		end		
		Walker.Start()

	elseif (labelName == 'CheckStamina') then
		Walker.Stop()
		if (LowStamina) and (Self.Stamina() < 960) then			
			print([[Low stamina, Logout now.]])
			wait(3500)
			Self.Logout()
		else
			Walker.Start()
			print([[Enough stamina, Continue hunt..]])
		end

	elseif (labelName == 'WithdrawStuff') then
		Walker.Stop()
		if (WithdrawAmulets) then
			AmuletsToWithdraw = (AmountAmulets - Self.ItemCount(AmuletName))
			Self.WithdrawItems(1, {AmuletName, ExtraBP, AmuletsToWithdraw})
			wait(500)
		end
		if (WithdrawFood) then
			FoodToWithdraw = (Amount - Self.ItemCount(FoodName))
			Self.WithdrawItems(1, {FoodName, MainBP, FoodToWithdraw})
			wait(500)
		end
		if (WithdrawRings) then
			RingsToWithdraw = (AmountRings - Self.ItemCount(RingName))
			Self.WithdrawItems(1, {RingName, ExtraBP, RingsToWithdraw})
			wait(500)
		end
		Walker.Start()

	elseif (labelName == 'Suppiles') then
			Walker.Stop()
		if (Self.ItemCount(ManaName) < BuyMana) or (Self.ItemCount(HealthName) < BuyHealth) then
			Self.SayToNpc('hi', 100)
			Self.ShopSellFlasks()
			wait(1500)
			Self.SayToNpc('trade', 100)
			wait(1100)
			while (Self.ItemCount(ManaName) < BuyMana) do
				Self.ShopBuyItemsUpTo(ManaName, BuyMana)
				wait(500,800)
			end
			if (Self.ItemCount(HealthName) < BuyHealth) then
				Self.ShopBuyItemsUpTo(HealthName, BuyHealth)
				wait(500)
			end
			wait(200, 500)
		end
		Walker.Start()

	elseif (labelName == 'Backpacks') then
		Walker.Stop()
	if (UseExtraBackpack) then
		Self.CloseContainers()
		Self.OpenMainBackpack(mini):OpenChildren({SuppliesBP, mini}, {LootBP, mini}, {ExtraBP, mini})
	else
		Self.CloseContainers()
		Self.OpenMainBackpack(mini):OpenChildren({SuppliesBP, mini}, {LootBP, mini})
	end
	if (HideEquipment) then
		Client.HideEquipment()
	end
		Walker.Start()

	elseif (labelName == 'EastSpawn') then
		if (UseHaste) then
			wait(300)
			Module.Stop('Refill Haster')
		end
		if (ManaRestore) then
			wait(300)
			Module.Start('ManaRestore')
		end
		if (useAmulets) then
			wait(300)
			Module.Start('Amulets')
		end
		if (useRings) then
			wait(300)
			Module.Start('Rings')
		end
		Looter.Start()
		Targeting.Start()

	elseif (labelName == 'Leave') then
		if (UseHaste) then
			wait(300)
			Module.Start('Refill Haster')
		end
		if (ManaRestore) then
			wait(300)
			Module.Stop('ManaRestore')
		end
		if (useAmulets) then
			Module.Stop('Amulets')			
			wait(300)
			Self.Dequip("amulet", ExtraBP)
		end
		if (useRings) then
			Module.Stop('Rings')			
			wait(600)
			Self.Dequip("ring", ExtraBP)
		end
		Looter.Stop()
		Targeting.Stop()
	
	elseif (labelName == 'CheckSoft') then
		if (Softboots) and (Self.ItemCount(6530) > 0) then
			gotoLabel('GoForNewSoft')
		else
			gotoLabel('Stay')
		end	
					
	elseif (labelName == 'RepairSoft') then
		Walker.Stop()		
		if (Self.ItemCount(6530) > 0) then	
		Self.SayToNpc({'hi', 'repair', 'yes'}, 100)	
		end
		Walker.Start()

	elseif (labelName == 'ToVenore') then
		Walker.Stop()
			wait(300,500)
			Self.SayToNpc({'hi', 'travel', 'venore'}, 70, 5)
		Walker.Start()
	
	elseif (labelName == 'ToGrayIsland') then
		Walker.Stop()			
			wait(300,500)
			Self.SayToNpc({'hi', 'gray island', 'yes'}, 70, 5)
		Walker.Start()
	end
end