--       _________ __                 __
--      /   _____//  |_____________ _/  |______     ____  __ __  ______
--      \_____  \\   __\_  __ \__  \\   __\__  \   / ___\|  |  \/  ___/
--      /        \|  |  |  | \// __ \|  |  / __ \_/ /_/  >  |  /\___ \ 
--     /_______  /|__|  |__|  (____  /__| (____  /\___  /|____//____  >
--             \/                  \/          \//_____/            \/ 
--  ______________________                           ______________________
--                        T H E   W A R   B E G I N S
--         Stratagus - A free fantasy real time strategy game engine
--
--	ai_nephrite_2013.lua - Nephrite AI 2013
--
--	(c) Copyright 2012-2013 by Kyran Jackson
--
--      This program is free software; you can redistribute it and/or modify
--      it under the terms of the GNU General Public License as published by
--      the Free Software Foundation; either version 2 of the License, or
--      (at your option) any later version.
--  
--      This program is distributed in the hope that it will be useful,
--      but WITHOUT ANY WARRANTY; without even the implied warranty of
--      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--      GNU General Public License for more details.
--  
--      You should have received a copy of the GNU General Public License
--      along with this program; if not, write to the Free Software
--      Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
--

-- This edition was started on 11/11/2013.

local nephrite_build -- What the AI is going to build.
local nephrite_attackbuffer -- The AI attacks when it has this many units.
local nephrite_attackforce
local nephrite_wait -- How long the AI waits for the next attack.
local nephrite_increment -- How large the attack force is increased by.

function AiNephrite_Setup_2013()
	nephrite_build = "Footman"
	nephrite_attackbuffer = 8
	nephrite_wait = 100
	nephrite_attackforce = 1
	nephrite_modifier_cav = 1
	nephrite_modifier_archer = 1
	nephrite_increment = 0.1
end

function AiNephrite_2013()
	if (nephrite_attackforce ~= nil) then
		if ((nephrite_wait < 3) or (nephrite_wait == 11) or (nephrite_wait == 21) or (nephrite_wait == 21) or (nephrite_wait == 31) or (nephrite_wait == 41) or (nephrite_wait == 51) or (nephrite_wait == 61) or (nephrite_wait == 71) or (nephrite_wait == 81) or (nephrite_wait == 91) or (nephrite_wait == 101)) then
			AiNephrite_Flush_2013()
		end
		AiNephrite_Pick_2013()
		if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiFarm()) >= 1) then
			if ((GetPlayerData(AiPlayer(), "Resources", "gold") > 800) and (GetPlayerData(AiPlayer(), "Resources", "wood") > 200)) then
				if ((GetPlayerData(AiPlayer(), "UnitTypesCount", AiBetterCityCenter()) > 0) and (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBestCityCenter()) == 0)) then
					if ((GetPlayerData(AiPlayer(), "Resources", "gold") > 2500) and (GetPlayerData(AiPlayer(), "Resources", "wood") > 1200)) then
						AiNephrite_Train_2013()
					end
				else
					AiNephrite_Train_2013()
				end
			elseif (GameCycle >= 5000) then
				if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiWorker()) < 20) then
					AiSet(AiWorker(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiWorker()) + 1)
				end
				if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBestCityCenter()) > 0) then
					AiNephrite_Train_2013()
				end
			end
		end
		if (nephrite_wait < 2) then
			AiNephrite_Attack_2013()
			--AiForce(0, {AiSoldier(), 2})
		else
			nephrite_wait = nephrite_wait - 1
		end
		AiNephrite_Research_2013()
		AiNephrite_Expand_2013()
	else
		AiNephrite_Setup_2013()
    end
end

function AiNephrite_Flush_2013()
	AiSet(AiBarracks(), 0)
	AiSet(AiCityCenter(), 0)
	AiSet(AiFarm(), 1)
	AiSet(AiBlacksmith(), 0)
	AiSet(AiLumberMill(), 0)
	AiSet(AiStables(), 0)
	AiSet(AiWorker(), 0)
	AiSet(AiCatapult(), 0)
	AiSet(AiShooter(), 0)
	AiSet(AiCavalry(), 0)
	AiSet(AiSoldier(), 0)
end

function AiNephrite_Pick_2013()
	-- What am I going to build next?
	nephrite_build = SyncRand(4)
	if (nephrite_build == 1) then
		if ((nephrite_modifier_archer == 0) or ((GetPlayerData(AiPlayer(), "UnitTypesCount", AiShooter())/2) > (GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCavalry())))) then
			nephrite_build = "Knight"
		else
			nephrite_build = "Archer"
		end
	elseif (nephrite_build == 2) then
		nephrite_build = "Knight"
	elseif ((nephrite_build == 3) and (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) >= 2)) then
		nephrite_build = "Catapult"
	else
		nephrite_build = "Knight"
	end
	if ((nephrite_modifier_cav == 0) and (nephrite_build == "Knight")) then
		nephrite_build = "Footman"
	end
	if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiCityCenter()) > 0) then
		if ((((GetPlayerData(AiPlayer(), "UnitTypesCount", AiShooter()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCavalry())) > ((GetPlayerData(AiPlayer(), "UnitTypesCount", AiWorker())) * 2)) or (GetPlayerData(AiPlayer(), "UnitTypesCount", AiWorker()) < 10))) then
			AiSet(AiWorker(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiWorker()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCityCenter()))
		end
	end
end

function AiNephrite_Attack_2013()
	if (nephrite_attackforce ~= nil) then
		--AddMessage("It is time to attack.")
		if ((GetPlayerData(AiPlayer(), "UnitTypesCount", AiHeroRider()) + GetPlayerData(AiPlayer(), "UnitTypesCount", "unit-skeleton") + GetPlayerData(AiPlayer(), "UnitTypesCount", AiHeroShooter()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiFlyer()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiMage()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiHeroSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCatapult()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiShooter()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCavalry())) >= nephrite_attackbuffer) then
			--AddMessage("Attacking with force 1.")
			AiForce(nephrite_attackforce, {AiEliteSoldier(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiEliteSoldier()), AiHeroRider(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiHeroRider()), AiHeroSoldier(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiHeroSoldier()), AiMage(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiMage()), AiFlyer(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiFlyer()), AiBones(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiBones()), AiHeroShooter(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiHeroShooter()), AiCatapult(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiCatapult()), AiSoldier(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()), AiCavalry(), (GetPlayerData(AiPlayer(), "UnitTypesCount", AiCavalryMage()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCavalry())), AiShooter(), (GetPlayerData(AiPlayer(), "UnitTypesCount", AiEliteShooter()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiShooter()))}, true)
			AiAttackWithForce(nephrite_attackforce)
			nephrite_wait = 150
			if (nephrite_attackforce >= 8) then
				nephrite_attackforce = 1
				nephrite_attackbuffer = nephrite_attackbuffer + nephrite_increment
				AiForce(0, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0})
				AiForce(1, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0}, true)
				AiForce(2, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0}, true)
				AiForce(3, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0}, true)
				AiForce(4, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0}, true)
				AiForce(5, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0}, true)
				AiForce(6, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0}, true)
				AiForce(7, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0}, true)
				AiForce(8, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0}, true)
				AiForce(9, {AiEliteSoldier(), 0, AiHeroRider(), 0, AiHeroSoldier(), 0, AiMage(), 0, AiFlyer(), 0, AiBones(), 0, AiHeroShooter(), 0, AiCatapult(), 0, AiSoldier(), 0, AiCavalry(), 0, AiShooter(), 0}, true)
			else
				nephrite_attackforce = nephrite_attackforce + 1
			end
		end
	else
		AiNephrite_Setup_2013()
	end
end

function AiNephrite_Expand_2013()
	-- New in Nephrite 2013 is the expand function.
	if (GetPlayerData(AiPlayer(), "Resources", "gold") < 4000) then
		if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiCityCenter()) == 0) then
			AiSet(AiCityCenter(), 1)
		end
	elseif (GetPlayerData(AiPlayer(), "Resources", "gold") < 8000) then
		if (GameCycle >= 6000) then
			if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiCityCenter()) < 2) then
				AiSet(AiCityCenter(), 2)
			end
		end
	end
	if (GetPlayerData(AiPlayer(), "Resources", "gold") > 1000) then
		if ((GetPlayerData(AiPlayer(), "TotalNumUnits") / GetPlayerData(AiPlayer(), "UnitTypesCount", AiFarm())) > 4.5) then
			AiSet(AiFarm(), (GetPlayerData(AiPlayer(), "UnitTypesCount", AiFarm()) + 1))
		end
	end
	if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiFarm()) >= 1) then
		if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) == 0) then
			if (GetPlayerData(AiPlayer(), "Resources", "gold") > 1000) then
				AiSet(AiBarracks(), 1)
			end
		elseif (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) == 1) then
			if (GameCycle >= 5000) then
				if (GetPlayerData(AiPlayer(), "Resources", "gold") > 2000) then
					AiSet(AiWorker(), 12)
					AiSet(AiBarracks(), 2)
				end
			end
		elseif (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) == 2) then
			if (GetPlayerData(AiPlayer(), "Resources", "gold") > 4000) then
				AiSet(AiWorker(), 16)
				AiSet(AiBarracks(), 3)
			end
		elseif (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) == 3) then
			if (GameCycle >= 10000) then
				if (GetPlayerData(AiPlayer(), "Resources", "gold") > 12000) then
					AiSet(AiWorker(), 20)
					AiSet(AiBarracks(), 4)
				end
			end
		elseif (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) == 4) then
			if (GetPlayerData(AiPlayer(), "Resources", "gold") > 16000) then
				AiSet(AiWorker(), 25)
				AiSet(AiBarracks(), 5)
			end
		elseif (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) == 5) then
			if (GetPlayerData(AiPlayer(), "Resources", "gold") > 32000) then
				AiSet(AiWorker(), 30)
				AiSet(AiBarracks(), 6)
			end
		elseif (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) > 5) then
			if (((GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) / GetPlayerData(AiPlayer(), "TotalResources", "gold")) > 1200) and (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) < 8)) then
				AiSet(AiBarracks(), (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) + 1))
			end
		end
	end
end
	
function AiNephrite_Research_2013()
	-- New in Nephrite 2013 is the research function.
	-- TODO: Add captapult
	if ((GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCavalry())) >= 1) then
		if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBlacksmith()) == 0) then
			AiSet(AiBlacksmith(), 1)
		else
			if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBestCityCenter()) == 0) then
				AiUpgradeTo(AiBestCityCenter())
			else
				if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiTemple()) == 0) then
					AiSet(AiTemple(), 1)
				else
					AiResearch(AiUpgradeCavalryMage())
					AiResearch(AiCavalryMageSpell1())
				end
			end
			if ((GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCavalry())) >= 1) then
				AiResearch(AiUpgradeWeapon1())
				AiResearch(AiUpgradeArmor1())
				if ((GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCavalry())) >= 2) then
					AiResearch(AiUpgradeArmor2())
					AiResearch(AiUpgradeWeapon2())
				end
			end
			if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiShooter()) >= 1) then
				if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiLumberMill()) == 0) then
					AiSet(AiLumberMill(), 1)
				else
					AiResearch(AiUpgradeMissile1())
					AiResearch(AiUpgradeMissile2())
					if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiStables()) == 0) then
						AiSet(AiStables(), 1)
					else
						if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBestCityCenter()) == 0) then
							AiUpgradeTo(AiBestCityCenter())
						else
							AiResearch(AiUpgradeEliteShooter())
							AiResearch(AiUpgradeEliteShooter2())
							AiResearch(AiUpgradeEliteShooter3())
						end
					end	
				end
			end
		end
	end
end

function AiNephrite_Train_2013()
	AiSetReserve({0, 400, 0, 0, 0, 0, 0})
	if (nephrite_build == "Worker") then
		AiSet(AiWorker(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiWorker()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiCityCenter()))
	elseif (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()) > 0) then
		if (nephrite_build == "Footman") then
			AiSet(AiSoldier(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()))
		elseif (nephrite_build == "Catapult") then
			if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBlacksmith()) > 0) then
				AiSet(AiCatapult(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiCatapult()) + 1)
			else
				AiSet(AiBlacksmith(), 1)
			end
		elseif (nephrite_build == "Archer") then
			AiSet(AiShooter(), (GetPlayerData(AiPlayer(), "UnitTypesCount", AiShooter()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks())))
		elseif (nephrite_build == "Knight") then
			if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiStables()) > 0) then
				AiSet(AiCavalry(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiCavalry()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()))
			else
				AiSet(AiSoldier(), GetPlayerData(AiPlayer(), "UnitTypesCount", AiSoldier()) + GetPlayerData(AiPlayer(), "UnitTypesCount", AiBarracks()))
				if ((GetPlayerData(AiPlayer(), "UnitTypesCount", AiBetterCityCenter()) > 0) or (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBestCityCenter()) > 0)) then
					AiSet(AiStables(), 1)
				elseif (GetPlayerData(AiPlayer(), "UnitTypesCount", AiCityCenter()) > 0) then
					if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiLumberMill()) > 0) then
						if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBlacksmith()) > 0) then
							AiUpgradeTo(AiBetterCityCenter())
						else
							AiSet(AiBlacksmith(), 1)
						end
					else
						AiSet(AiLumberMill(), 1)
					end
				else
					AiSet(AiCityCenter(), 1)
				end
			end
		end
	else
		AiSet(AiBarracks(), 1)
	end
	AiSetReserve({0, 0, 0, 0, 0, 0, 0})
end

function AiNephrite_NoCav_2013()
	if (nephrite_attackforce ~= nil) then
		AiNephrite_2013()
		if (nephrite_attackbuffer > 20) then
			nephrite_attackbuffer = 10
		end
	else
		nephrite_attackforce = 1
		nephrite_build = "Soldier"
		nephrite_attackbuffer = 1
		nephrite_wait = 100
		nephrite_modifier_cav = 0
		nephrite_modifier_archer = 1
		nephrite_increment = 1
	end
end

function AiNephrite_Level5()
	AiSet(AiLumberMill(), 1)
	if (nephrite_attackforce ~= nil) then
		if (GetPlayerData(2, "Resources", "gold") > 1000) then
			AiNephrite_Train_2013()
			AiNephrite_Pick_2013()
			if (nephrite_wait < 2) then
				AiNephrite_Attack_2013()
			else
				nephrite_wait = nephrite_wait - 1
			end
			AiNephrite_Research_2013()
			if (GetPlayerData(AiPlayer(), "UnitTypesCount", AiBlacksmith()) > 0) then
				AiNephrite_Expand_2013()
			end
		end
	else
		nephrite_attackforce = 1
		nephrite_build = "Archer"
		nephrite_attackbuffer = 6
		nephrite_wait = 100
		nephrite_modifier_cav = 0
		nephrite_modifier_archer = 1
		nephrite_increment = 0.1
	end
end

DefineAi("ai_nephrite_2013", "*", "ai_nephrite_2013", AiNephrite_2013)
DefineAi("ai_nephrite_nocav_2013", "*", "ai_nephrite_nocav_2013", AiNephrite_NoCav_2013)
