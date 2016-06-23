------ REFILL SETTINGS ------

local LeaveMana = 60 --- How many mana potions until you leave the hunt?
local BuyMana = 1000 --- How many mana potions you begin the hunt with?

local LeaveHealth = 10 --- How many health potions until you leave the hunt?
local BuyHealth = 40 --- How many health potions you begin the hunt with?

local LeaveCap = 50 --- Leaves spawn when character reaches this cap.

local UseHaste = true --- Do you want use haste when bot go/leave from respawn?
local TypeHaste = 'utani hur'

-- HEALING SETTINGS -- CHANGE ONLY PERCENT

local healing = {
    {spell = 'exura gran ico', percent = 20, mana = 200},
    {spell = 'exura ico', percent = 85, mana = 40}
}

-- Sort Suppiles (Change name if you use others type of suppiles)

SortSuppiles = {
    {id = Item.GetID('Mana Potion'), bp = 'Blue Backpack'},
    {id = Item.GetID('Great Health Potion'), bp = 'Blue Backpack'}
    }

-- Potions Settings (Change names and prices if you use other potions):

local ManaName = 'Mana Potion' 
local ManaCost = 50

local HealthName = 'Great Health Potion' 
local HealthCost = 190

-- Backpack Configuration:

local MainBP = 'Backpack'

local SuppliesBP = 'Blue Backpack'

local LootBP = 'Brocade Backpack'

local UseExtraBackpack = false  --- Do you want use extra backpack? (For amulets etc)
local ExtraBP = 'Jewelled Backpack' --- If you dont want use extra backpack, ignore it!!!

local HideEquipment = true --- Do you want minimize your equipment?
local MinimizeBackpack = false --- Do you want minimize your backpacks?

--- Amulets , Rings, Food Configuration

local WithdrawFood = true  --- Do you want withdraw food? (Backpack of food must be at 3rd slot in your depot.)
local FoodName = 'Brown Mushroom'  --- Food name.
local Amount = 100  --- What amount of food you want to withdraw?

local useAmulets = false --- Do you want use amulets?
local AmuletName = 'Protection Amulet'
local WithdrawAmulets = false --- Do you want withdraw amulets? (You must UseExtraBackpack) (Backpack of amulets must be at 3rd slot in your depot.)
local AmountAmulets = 3 --- What amount of rings you want to withdraw?

local useRings = false --- Do you want use rings? 
local RingName = 'Dwarven Ring'
local WithdrawRings = false --- Do you want withdraw rings? (You must UseExtraBackpack) (Backpack of rings must be at 3rd slot in your depot.)
local AmountRings = 1 --- What amount of rings you want to withdraw?

--- Soft Boots, 

local Softboots = false --- Do you want use softboots? 
local ManaToEquip = 70 -- Mana Percent to equip soft boots.
local NormalBoots = 'Draken Boots' --- Your normal boots.

-- Extra Settings

local DropVials = false --- Do you want drop empty vials?
local CapToStartDroppingFlasks = 250

local LowStamina = false --- Do you want logout if stamina drops below 16 hours?

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

Module.New('Mana Restore', function(RestoreM)
    while (ManaPercent() < RestoreManaToPercent) and (#Self.GetTargets(8) == 0) and (Self.ItemCount(ManaName) > 0) and (ManaRestore) do
        if Walker.IsEnabled() then
            Walker.Stop()
        end
        Self.UseItemWithMe(ManaName)
        wait(500, 1000)
        Walker.Start()
    end    
    RestoreM:Delay(500)
end)

Module.New('Health Restore', function(RestoreH)
    while (HealthPercent() < RestoreHealthToPercent) and (#Self.GetTargets(8) == 0) and (Self.ItemCount(ManaName) > 0) and (HealthRestore) do
        if Walker.IsEnabled() then
            Walker.Stop()
        end
        Self.Cast(SpellToUse, ManaForThisSpell)
        wait(600, 1100)
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

Module.New('Drop Vials', function(Vials)
	if (DropVials) and (Self.Cap() < CapToStartDroppingFlasks) then 
    Self.DropFlasks(Self.Position().x, Self.Position().y, Self.Position().z)
    end 
 Vials:Delay(10000, 15000)
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
    if not Self.isHasted() and not Self.isInPz() and (UseHaste) and (TypeHaste == 'utani tempo hur') then
		Self.Cast('utani tempo hur', 100)
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

registerEventListener(WALKER_SELECTLABEL, 'onWalkerSelectLabel')

function onWalkerSelectLabel(labelName)
	if (labelName == 'Checker') then		
		Walker.ConditionalGoto((Self.ItemCount(ManaName) <= LeaveMana) or (Self.Cap() < LeaveCap) or (Self.ItemCount(HealthName) <= LeaveHealth), 'Leave', 'BeginHunt')

	elseif (labelName == 'Start') then
		print([[If you want withdraw some items from depot, you must make sure that you have enought capacity. ]])
		if (UseHaste) then
			wait(300)
			Module.Start('Refill Haster')
		end
		Looter.Stop()

	elseif (labelName == 'BeginHunt') then		
		if (UseHaste) then
			wait(300)
			Module.Stop('Refill Haster')
		end
		Looter.Start()

	elseif (labelName == 'Leave') then
		if (UseHaste) then
			wait(300)
			Module.Start('Refill Haster')
		end
		Looter.Stop()

	elseif (labelName == 'DepositGold') then
		Walker.Stop()	
		Self.SayToNpc({'hi', 'deposit all', 'yes'}, 100)

		local withdrawManas = math.max(BuyMana - Self.ItemCount(ManaName), 0)*ManaCost
		local withdrawHealths = math.max(BuyHealth - Self.ItemCount(HealthName), 0)*HealthCost
		local extra = 2000
		local total = math.abs(withdrawManas + withdrawHealths + extra)
		
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

	elseif (labelName == 'WithdrawFood') then
		if (WithdrawFood) then
			Walker.Stop()		
			FoodToWithdraw = (Amount - Self.ItemCount(FoodName))
			Self.WithdrawItems(2, {FoodName, MainBP, FoodToWithdraw})
			wait(300)
		end		
		Walker.Start()

	elseif (labelName == 'WithdrawAmulet')	then
		if (WithdrawAmulets) then
			print([[If you wear other amulet like platinum etc, move amulet from slot.]])
			Walker.Stop()
			AmuletsToWithdraw = (AmountAmulets - Self.ItemCount(AmuletName))
			Self.WithdrawItems(2, {AmuletName, ExtraBP, AmuletsToWithdraw})
			wait(300)
		end
		Walker.Start()

	elseif (labelName == 'WithdrawRing') then
		if (WithdrawRings) then
			Walker.Stop()
			RingsToWithdraw = (AmountRings - Self.ItemCount(RingName))
			Self.WithdrawItems(2, {RingName, ExtraBP, RingsToWithdraw})
			wait(300)
		end
		Walker.Start()

	elseif (labelName == 'BuyManas') then
			Walker.Stop()
		if (Self.ItemCount(ManaName) < BuyMana) or (Self.ItemCount(HealthName) < BuyHealth) then
			Self.SayToNpc('hi', 100)
			Self.ShopSellFlasks()
			wait(800)
			Self.SayToNpc('trade', 100)
			wait(800)
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

	elseif (labelName == 'BankDoor1') then
		Walker.Stop()
		Self.OpenDoor(33013, 31488, 10)
		wait(500, 1000)
		Walker.Start()
	
	elseif (labelName == 'BankDoor2') then
		Walker.Stop()
		Self.OpenDoor(33008, 31491, 10)
		wait(500, 1000)
		Walker.Start()
	
	elseif (labelName == 'ManaDoor') then
		Walker.Stop()
		Self.OpenDoor(33010, 31537, 10)
		wait(500, 1000)
		Walker.Start()

	elseif (labelName == 'ManaDoor2') then
		Walker.Stop()
		Self.OpenDoor(33010, 31537, 10)
		wait(500, 1000)
		Walker.Start()

	elseif (labelName == 'LeverCity') then
		Walker.Stop()
		Self.UseLever(33062, 31527, 10, item)
		wait(700, 1500)
		Self.UseLever(33062, 31527, 10, item)
		wait(700, 1500)
		Walker.Start()
	
	elseif (labelName == 'LeverCity2') then
		Walker.Stop()
		Self.UseLever(32992, 31539, 4, item)
		wait(700, 1500)
		Self.UseLever(32992, 31539, 4, item)
		wait(700, 1500)
		Walker.Start()
		
	elseif (labelName == 'LeverBack') then
		Walker.Stop()
		Self.UseLever(32994, 31547, 4, item)
		wait(700, 1500)
		Self.UseLever(32994, 31547, 4, item)
		wait(700, 1500)
		Walker.Start()

	elseif (labelName == 'OpenEast') then
		Walker.Stop()
		Self.UseItemFromGround(Self.Position().x + 1, Self.Position().y, Self.Position().z) 
		Walker.Start()

	elseif (labelName == 'OpenWest') then
		Walker.Stop()
		Self.UseItemFromGround(Self.Position().x - 1, Self.Position().y, Self.Position().z) 
		Walker.Start()
		
	elseif (labelName == 'OpenNorth') then
		Walker.Stop()
		Self.UseItemFromGround(Self.Position().x, Self.Position().y - 1, Self.Position().z) 
		Walker.Start()
		
	elseif (labelName == 'OpenSouth') then
		Walker.Stop()
		Self.UseItemFromGround(Self.Position().x, Self.Position().y + 1, Self.Position().z) 
		Walker.Start()	
	
	elseif (labelName == 'CheckUp') then 
		Walker.ConditionalGoto((Self.Position().x and Self.Position().y and Self.Position().z == 5), 'GoDepot', 'GoUp')		
		
	elseif (labelName == 'CheckLeverCity') then 
		Walker.ConditionalGoto((Self.Position().x and Self.Position().y and Self.Position().z == 4), 'GoToLeverCity2', 'RetryLeverCity')
		
	elseif (labelName == 'CheckLeverCity2') then 
		Walker.ConditionalGoto((Self.Position().x and Self.Position().y and Self.Position().z == 1), 'Continue', 'RetryLeverCity2')

	elseif (labelName == 'CheckLeverBack') then 
		Walker.ConditionalGoto((Self.Position().x == 33061 and Self.Position().y == 31527 and Self.Position().z == 10), 'GoDepot2', 'RetryLeverBack')

	-- elseif (labelName == 'CheckSouth') then
	-- Walker.ConditionalGoto((Self.Position().x == x and Self.Position().y == y and Self.Position().z == z), 'DoneSouth', 'GoDepot2')
	
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
		
	end
end

function onSpeak(channel, text)

		script = "[Elite Knight]  | 80+ |  Zao Hidden Brimstone's"
		
		if (text == 'help') then
		channel:SendOrangeMessage(Self.Name(), 'Avaiable commands:')
		channel:SendOrangeMessage(Self.Name(), 'start, leave, stop, script, resetBps, stay.')
		end
		
		if (text == 'start') then
		Walker.Start()
		Targeting.Start()
		channel:SendOrangeMessage(Self.Name(), 'Activated  ' ..script.. '')
		end
		
		if (text == 'leave') then
		Walker.Stop()
		Walker.Goto('Leave')
		Walker.Start()
		channel:SendOrangeMessage(Self.Name(), 'Leaving')
		end
		
		if (text == 'stay') then
		Walker.Stop()
		Walker.Goto('BeginHunt')
		Walker.Start()
		Looter.Start()
		Targeting.Start()
		channel:SendOrangeMessage(Self.Name(), 'Stay at Respawn')
		end

		if (text == 'stop') then
		Walker.Stop()
		Looter.Stop()
		Targeting.Stop()
		channel:SendOrangeMessage(Self.Name(), 'Stopped')
		end
		
		if (text == 'script') then
		channel:SendOrangeMessage(Self.Name(), 'Running  ' ..script.. '.')
		end
		
		if (text == 'resetBps') then
		Walker.Stop()
		Looter.Stop()
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
		Looter.Start()
		channel:SendOrangeMessage(Self.Name(), 'Backpacks Reseted')
				
			end
			end
			
			
local channel = Channel.New(Self.Name(), onSpeak)
channel:SendRedMessage(Self.Name(), ' Channel Information.')
channel:SendOrangeMessage(Self.Name(), 'Use help to see list of commands.')
channel:SendOrangeMessage(Self.Name(), 'Use start to start script.')