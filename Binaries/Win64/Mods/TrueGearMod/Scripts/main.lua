local truegear = require "truegear"

local primaryWeapon = {
	"AKM",
    "M16A4",
    "AK74",
    "QBZ-95",
    "AK5C",
    "FAMAS",
    "FN-SCAR-L",
    "G3",
    "FN-FAL",
	"AKS74U",
    "M4A1",
    "AUG-A3",
    "MK18",
    "CZ 805",
    "G36C",
	"Spectre M4",
    "MP7A1",
    "MP5A3",
    "UZI PRO",
    "Kriss Vector",
    "AS VAL",
    "UMP45",
    "P90",
    "AAC HB",
	"M590",
    "RM870",
    "SPAS-12",
    "M1014",
	"Sako85",
    "SKS",
    "M1A",
    "SVD",
    "AWM",
	"R 10/22",
	"M1A1 Paratrooper",
	"Vz. 58",
	"Fallschir",
	"Sturmgewehr 44",
	"XM177",
	"M16E1",
	"Krebs AK",
	"R4",
	"M1 Rifle",
	"K2",
	"AK-12",
	"Ak-102",
	"SS2 V1",
	"AMD-65",
	"Type 88",
	"AK-103",
	"An-94",
	"9A-91",
	"SS2 V5",
	"Aug A1",
	"KAC PDW",
	"SG552",
	"SG551",
	"MDX",
	"DAR-21",
	"Grot",
	"HK33",
	"I2A",
	"HK416",
	"MCX",
	"L15",
	"MC51K",
	"L85",
	"Masada",
	"Type 20",
	"TAR 21",
	"Scar SC",
	"Wz. 96 Beryl",
	"M4 Custom",
	"G36KA4",
	"M14",
	"HK 433",
	"M16A3",
	"Weaver's custom W16",
	"M4A1 RIS",
	"G36",
	"FAL Para",
	"G3A3",
	"G11",
	"Micro Uzi",
	"SST",
	"MP9",
	"Spectre M4",
	"MPL",
	"PP2000",
	"Mac 10",
	"MP7",
	"PP19",
	"MP5K",
	"Thompson M1928A1",
	"FMG",
	"MP5",
	"UMP45",
	"Vector",
	"EV03",
	"Model 635",
	"P90",
	"686E Bock",
	"Vendetta",
	"M1100",
	"M26 Standalone",
	"M500",
	"M4",
	"R870 Magpul",
	"Spas 12",
	"Nova",
	"M2",
	"VR80",
	"Komrad",
	"KSG",
	"M99",
	"Tokarev SVT-40",
	"SVD",
	"PSG 1",
	"M40A1",
	"M24SWS",
	"Scout",
	"SV98",
	"SG550",
	"GM6 Lynx",
	"M82A2",
	"Solothum 31 M",
	"BAR M1918A2",
	"RPK",
	"G8",
	"M60E1",
	"M240B",
	"PKM",
	"M249 PARA",
	"M60E4",
	"Maschinengewehr 34",
	"MG3"
}
local secondaryWeapon = {
	"P250",
    "AP85",
    "P30",
    "M1911A1",
    "Glock 22",
    "Magnum",
    "Deagle"
}

local isRightHandMode = true
local hookIds = {}
local isFirst = true
local resetHook = true
local health = 100.0
local maxHealth = 100.0
local canChamber = true
local leftHandItem = ""
local rightHandItem = ""
local canOutputItem = true
local canInputItem = true
local isDeath = false
local localPlayerId = 0
local isOutputItem = false
local isTwoHand = false
local weaponTwoHand = ""
local canWeaponTwoHand = true
local leftIsPrimaryWeapon = false
local rightIsPrimaryWeapon = false
local canPullBowString = false

function Split(str, sep)
	assert(type(str) == 'string' and type(sep) == 'string', 'The arguments must be <string>')
	if sep == '' then return {str} end
	
	local res, from = {}, 1
	repeat
	  local pos = str:find(sep, from)
	  res[#res + 1] = str:sub(from, pos and pos - 1)
	  from = pos and pos + #sep
	until not from
	return res
end

-- 表内容进行比对
function inValue (tab, val)
    for index, value in ipairs(tab) do
        if string.find(val,value) then
            return true
        end
    end
    return false
end

function SendMessage(context)
	if isDeath == true then
		return
	end
	if context then
		print(context .. "\n")
		return
	end
	print("nil\n")
end

function OutputMessage(context)
	if isDeath == true then
		return
	end
	if context then		
		local file = io.open("TrueGear.log", "a")			
		io.output(file)
		io.write(os.date("%Y-%m-%d %H:%M:%S") .. "	[TrueGear]:{".. context .."}\n")
		io.close(file)
		return
	end
end

function PlayAngle(event,tmpAngle,tmpVertical)

	local rootObject = truegear.find_effect(event);

	local angle = (tmpAngle - 22.5 > 0) and (tmpAngle - 22.5) or (360 - tmpAngle)
	
    local horCount = math.floor(angle / 45) + 1
	local verCount = (tmpVertical > 0.1) and -4 or (tmpVertical < 0 and 8 or 0)


	for kk, track in pairs(rootObject.tracks) do
        if tostring(track.action_type) == "Shake" then
            for i = 1, #track.index do
                if verCount ~= 0 then
                    track.index[i] = track.index[i] + verCount
                end
                if horCount < 8 then
                    if track.index[i] < 50 then
                        local remainder = track.index[i] % 4
                        if horCount <= remainder then
                            track.index[i] = track.index[i] - horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] - remainder + 99 + num1
                        else
                            track.index[i] = track.index[i] + 2
                        end
                    else
                        local remainder = 3 - (track.index[i] % 4)
                        if horCount <= remainder then
                            track.index[i] = track.index[i] + horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] + remainder - 99 - num1
                        else
                            track.index[i] = track.index[i] - 2
                        end
                    end
                end
            end
            if track.index then
                local filteredIndex = {}
                for _, v in pairs(track.index) do
                    if not (v < 0 or (v > 19 and v < 100) or v > 119) then
                        table.insert(filteredIndex, v)
                    end
                end
                track.index = filteredIndex
            end
        elseif tostring(track.action_type) ==  "Electrical" then
            for i = 1, #track.index do
                if horCount <= 4 then
                    track.index[i] = 0
                else
                    track.index[i] = 100
                end
            end
            if horCount == 1 or horCount == 8 or horCount == 4 or horCount == 5 then
                track.index = {0, 100}
            end
        end
    end

	truegear.play_effect_by_content(rootObject)



end

function IsPrimaryWeapon(item)
	local category =  item:get():GetPropertyValue("Category"):ToString()
	if string.find(category,"Rifle") or string.find(category,"Carbine") or string.find(category,"SMG") or string.find(category,"Shotgun") or string.find(category,"Sniper") or string.find(category,"LMG") then
		return true
	end
	return false
end

function IsWeapon(item)
	local category =  item:get():GetPropertyValue("Category"):ToString()
	if string.find(category,"Pistol") or string.find(category,"Rifle") or string.find(category,"Carbine") or string.find(category,"SMG") or string.find(category,"Shotgun") or string.find(category,"Sniper") or string.find(category,"LMG") then
		return true
	end
	return false
end

function SlotCheck(item)
	local category =  item:get():GetPropertyValue("Category"):ToString()
	if isRightHandMode == true then	
		if string.find(category,"Pistol") then
			return "RightHipSlot"
		elseif string.find(category,"Melee") then
			return "LeftHipSlot"
		elseif string.find(category,"Gadget") then
			return "TopChestSlot"
		elseif string.find(category,"Rifle") or string.find(category,"Carbine") or string.find(category,"SMG") or string.find(category,"Shotgun") or string.find(category,"Sniper") or string.find(category,"LMG") then
			return "RightHipSlot"
		else
			if inValue(primaryWeapon,item:get():GetFullName()) then 
				return "ChestSlot"
			else
				return "LeftHipSlot"
			end
		end			
	else
		if string.find(category,"Pistol") then
			return "LeftHipSlot"
		elseif string.find(category,"Melee") then
			return "RightHipSlot"
		elseif string.find(category,"Gadget") then
			return "TopChestSlot"
		elseif string.find(category,"Rifle") or string.find(category,"Carbine") or string.find(category,"SMG") or string.find(category,"Shotgun") or string.find(category,"Sniper") or string.find(category,"LMG") then
			return "LeftHipSlot"
		else
			if inValue(primaryWeapon,item:get():GetFullName()) then 
				return "ChestSlot"
			else
				return "RightHipSlot"
			end
		end
	end	
end

function RegisterHooks()

	if isFirst == true then
		isFirst = false
		local file = io.open("TrueGear.log", "w")
		if file then
			file:close()
		else
			print("无法打开文件")
		end
		
	end

	for k,v in pairs(hookIds) do
		UnregisterHook(k, v.id1, v.id2)
	end
		
	hookIds = {}

	local funcName = "/Game/Core/SaveGames/GameSettingSaveHelperFunctions.GameSettingSaveHelperFunctions_C:LoadIsRightHandWeaponMount"
	local hook1, hook2 = RegisterHook(funcName, LoadIsRightHandWeaponMount)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Script/ZomboyVR.ZomboyInteractableActor:ModifyGrabTransform"
	local hook1, hook2 = RegisterHook(funcName, OnGrabbed)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Script/ZomboyVR.ZomboyInteractableActor:CustomDropBehavior"
	local hook1, hook2 = RegisterHook(funcName, OnDropped)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/ZomboyVR.ZomboyInteractableActor:GetDropVelocity"
	local hook1, hook2 = RegisterHook(funcName, OnDropped)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/ZomboyVR.ZomboyGun:Fire"
	local hook1, hook2 = RegisterHook(funcName, Fire)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Core/Player/CS_Character.CS_Character_C:OnHit_BP"
	local hook1, hook2 = RegisterHook(funcName, OnHit)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Core/Player/CS_Character.CS_Character_C:LocalPlayerSetup"
	local hook1, hook2 = RegisterHook(funcName, LocalPlayerSetup)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Blueprints/GameModes/Survival/UI/Leaderboard/Survival_Leaderboard_PlayerInfo_Widget.Survival_Leaderboard_PlayerInfo_Widget_C:UpdateHealthBar"
	local hook1, hook2 = RegisterHook(funcName, HealthChange)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	-- local funcName = "/Game/Core/Player/CS_Character.CS_Character_C:ShowOnDeathUI"
	-- local hook1, hook2 = RegisterHook(funcName, Death)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	-- local funcName = "/Game/Core/Player/CS_Character.CS_Character_C:ShowPostGameUI"
	-- local hook1, hook2 = RegisterHook(funcName, Death)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }



	-- local funcName = "/Script/ZomboyVR.ZomboyGun:OnClipButtonPressed"
	-- local hook1, hook2 = RegisterHook(funcName, EjectClip)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/ZomboyVR.ZomboyGunClip:MoveBulletToChamber"
	local hook1, hook2 = RegisterHook(funcName, AddBulletToChamber)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/ZomboyVR.ZomboyAttachableInterface:OnDetach"
	local hook1, hook2 = RegisterHook(funcName, OnDetach)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/ZomboyVR.ZomboyAttachableInterface:OnAttach"
	local hook1, hook2 = RegisterHook(funcName, OnAttach)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/ZomboyVR.ZomboyBladeComponent:MultiSpawnMeleeHitEffect"
	local hook1, hook2 = RegisterHook(funcName, Melee)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Core/VRInteractables/Throwables/Grenades/ZomboyGrenadeBP.ZomboyGrenadeBP_C:OnRep_bSafetyPinPull"
	local hook1, hook2 = RegisterHook(funcName, OnRep_bSafetyPinPull)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Core/Player/Animtation/SlidingSoundPlayer.SlidingSoundPlayer_C:ExecuteUbergraph_SlidingSoundPlayer"
	local hook1, hook2 = RegisterHook(funcName, OnSlidingChanged)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Core/Player/CS_Character.CS_Character_C:OnDeathEvent"
	local hook1, hook2 = RegisterHook(funcName, Death2)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }





	local funcName = "/Game/Core/VRInteractables/Ninja/Bow.Bow_C:BndEvt__Bow_BowStringInteraction_K2Node_ComponentBoundEvent_1_OnTriggerReleased__DelegateSignature"
	local hook1, hook2 = RegisterHook(funcName, BowReleased)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/Core/VRInteractables/Ninja/Bow.Bow_C:BndEvt__BowAssistComp_K2Node_ComponentBoundEvent_2_OnHandInteractionBegin__DelegateSignature"
	local hook1, hook2 = RegisterHook(funcName, BowHandInteractionBegin)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
end

-- *******************************************************************

function BowReleased(self)
	canPullBowString = false
	if string.find(leftHandItem,"Bow_C") then
		SendMessage("--------------------------------")
		SendMessage("LeftHandArrowShoot")
		truegear.play_effect_by_uuid("LeftHandArrowShoot")
	elseif string.find(rightHandItem,"Bow_C") then
		SendMessage("--------------------------------")
		SendMessage("RightHandArrowShoot")
		truegear.play_effect_by_uuid("RightHandArrowShoot")
	end

	
end

function BowHandInteractionBegin(self)
	canPullBowString = true
	SendMessage("--------------------------------")
	SendMessage("BowHandInteractionBegin")
	
end



function LoadIsRightHandWeaponMount(self,__WorldContext,bIsEnabled)
	SendMessage("--------------------------------")
	SendMessage("LoadIsRightHandWeaponMount")
	SendMessage(tostring(bIsEnabled:get()))
	isRightHandMode = bIsEnabled:get()
end

function Death2(self,DeathPawn,KillingDamage,DamageEvent,InstigatingPawn,DamageCauser)


	local temp = self:get():GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex")	
	if temp ~= localPlayerId then
		return
	end
	canPullBowString = false

	SendMessage("--------------------------------")
	SendMessage("PlayerDeath")
	truegear.play_effect_by_uuid("PlayerDeath")

	local camera = self:get():GetPropertyValue("Controller"):GetPropertyValue("PlayerCameraManager")
	if camera:IsValid() ~= true then
		SendMessage("camera is not found")
		isdeath = true
		return
	end
	local view = camera:GetPropertyValue("ViewTarget")
	if view:IsValid() ~= true then
		SendMessage("view is not found")
		isdeath = true
		return
	end
	playerYaw = view.POV.Rotation.Yaw

	local enemy = DamageCauser:get():GetPropertyValue('Owner')
	if enemy:IsValid() == false then 
		SendMessage("PoisonDamage")
		truegear.play_effect_by_uuid("PoisonDamage")
		SendMessage("enemy is not found")
		isdeath = true
		return
	end	
	SendMessage(DamageCauser:get():GetFullName())
	SendMessage(DamageCauser:get():GetPropertyValue("Owner"):GetFullName())

	local targetRotation = enemy:GetPropertyValue("TargetRotation")
	if targetRotation:IsValid() == true then
		local angleYaw = playerYaw - targetRotation.Yaw
		angleYaw = angleYaw + 180
		if angleYaw > 360 then 
			angleYaw = angleYaw - 360
		elseif angleYaw < 0 then
			angleYaw = 360 + angleYaw
		end
		
		SendMessage("DefaultDamage," .. angleYaw .. ",0")
		PlayAngle("DefaultDamage",angleYaw,0)
		isdeath = true
		return
	end
	local enemyController = enemy:GetPropertyValue("Controller")
	if enemyController:IsValid() == false then
		SendMessage("enemyController is not found")
		isdeath = true
		return
	end
	local enemyPawn = enemyController:GetPropertyValue("Pawn")
	if enemyPawn:IsValid() == false then
		SendMessage("enemyPawn is not found")
		isdeath = true
		return
	end
	targetRotation = enemyPawn:GetPropertyValue("TargetRotation")
	if targetRotation:IsValid() == false then
		SendMessage("enemyPawn is not found")
		isdeath = true
		return
	end
	local angleYaw = playerYaw - targetRotation.Yaw
	angleYaw = angleYaw + 180
	if angleYaw > 360 then 
		angleYaw = angleYaw - 360
	elseif angleYaw < 0 then
		angleYaw = 360 + angleYaw
	end
	SendMessage("DefaultDamage," .. angleYaw .. ",0")
	OutputMessage("DefaultDamage," .. angleYaw .. ",0")
	PlayAngle("DefaultDamage",angleYaw,0)
	isdeath = true

end

function OnSlidingChanged(self,bSlide)
	local id = self:get():GetPropertyValue("Instigator"):GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex");
	if id == localPlayerId then
		if bSlide:get() < 100 then
			SendMessage("--------------------------------")
			SendMessage("Sliding")
			truegear.play_effect_by_uuid("Sliding")		
		end
		SendMessage(self:get():GetFullName())
		SendMessage("SlidingValue :" .. tostring(bSlide:get()))
	end	
end


function OnRep_bSafetyPinPull(self)
	if self:get():GetFullName() == leftHandItem then
		SendMessage("--------------------------------")
		SendMessage("RightHandPickupItem")
		truegear.play_effect_by_uuid("RightHandPickupItem")
	elseif self:get():GetFullName() == rightHandItem then
		SendMessage("--------------------------------")
		SendMessage("LeftHandPickupItem")
		truegear.play_effect_by_uuid("LeftHandPickupItem")
	end
end


function Melee(self)

	local tmpLeftItem = Split(leftHandItem,"/")
	local tmpRightItem = Split(rightHandItem,"/")

	if tmpLeftItem[3] ~= nil and string.find(self:get():GetFullName(),tmpLeftItem[3]) then		
		SendMessage("--------------------------------")
		SendMessage("LeftHandMeleeHit")
		truegear.play_effect_by_uuid("LeftHandMeleeHit")
	elseif tmpRightItem[3] ~= nil and string.find(self:get():GetFullName(),tmpRightItem[3]) then
		SendMessage("--------------------------------")
		SendMessage("RightHandMeleeHit")
		truegear.play_effect_by_uuid("RightHandMeleeHit")
	end

	
	SendMessage(self:get():GetFullName())
	SendMessage(tmpLeftItem[3])
	SendMessage(tmpRightItem[3])
end

function OnDetach(self,InteractableActor,AttachmentComponent)

	if canOutputItem == false then
		canOutputItem = true
		return
	end
	isOutputItem = true
end

LoopAsync(10, function()
	isOutputItem = false
end)

function OnAttach(self,InteractableActor,AttachmentComponent,AttachedSocket)

	local temp = InteractableActor:get():GetPropertyValue("Owner"):GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex")
	if temp ~= localPlayerId then
		return
	end

	if canInputItem == false then
		canInputItem = true
		return
	end
	local attachmentComponent = AttachmentComponent:get():GetFullName()

	
	SendMessage("--------------------------------")
	if string.find(attachmentComponent,"GunBodyMesh") then
		if leftHandItem ~= "" then
			SendMessage("LeftReloadAmmo")
			truegear.play_effect_by_uuid("LeftReloadAmmo")
			return
		elseif rightHandItem ~= "" then
			SendMessage("RightReloadAmmo")
			truegear.play_effect_by_uuid("RightReloadAmmo")
			return
		end
	end

	local slot = SlotCheck(InteractableActor)
	SendMessage("--------------------------------")
	SendMessage(slot .. "InputItem")
	truegear.play_effect_by_uuid(slot .. "InputItem")

	

	SendMessage(InteractableActor:get():GetFullName())	
	SendMessage(AttachmentComponent:get():GetFullName())	
	
end

-- function EjectClip(self)

-- 	local isLeft = true
-- 	if self:get():GetFullName() == leftHandItem then
-- 		isLeft = true
-- 	elseif self:get():GetFullName() == rightHandItem then
-- 		isLeft = false
-- 	else
-- 		return
-- 	end
-- 	canChamber = false
-- 	canOutputItem = false
-- 	if isLeft then
-- 		SendMessage("--------------------------------")
-- 		SendMessage("LeftMagazineEjected")		
-- 		truegear.play_effect_by_uuid("LeftMagazineEjected")
-- 	else
-- 		SendMessage("--------------------------------")
-- 		SendMessage("RightMagazineEjected")		
-- 		truegear.play_effect_by_uuid("RightMagazineEjected")
-- 	end
-- 	SendMessage(self:get():GetFullName())
-- end

function AddBulletToChamber(self)

	-- SendMessage("--------------------------------")
	-- SendMessage("Chamber")
	-- SendMessage(tostring(canChamber))	
	-- SendMessage(tostring(self:get():GetPropertyValue("Owner")))
	-- SendMessage(self:get():GetPropertyValue("Owner"):GetFullName())

	-- SendMessage(leftHandItem)
	-- SendMessage(rightHandItem)

	if canChamber == false then
		canChamber = true
		return
	end

	local isLeft = true
	if self:get():GetPropertyValue("Owner"):GetFullName() == leftHandItem then
		isLeft = true
	elseif self:get():GetPropertyValue("Owner"):GetFullName() == rightHandItem then
		isLeft = false
	else
		return
	end

	if isLeft then
		
		SendMessage("LeftDownReload")		
		truegear.play_effect_by_uuid("LeftDownReload")
	else
		SendMessage("RightDownReload")		
		truegear.play_effect_by_uuid("RightDownReload")
	end
end

function HealthChange(self)
	local character = self:get():GetPropertyValue('Character')
	local temp = character:GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex")	
	if temp ~= localPlayerId then
		return
	end

	-- SendMessage("--------------------------------")
	-- SendMessage("HealthChange")
	-- SendMessage(self:get():GetFullName())



	local tempHealth = character:GetPropertyValue('Health')
	local tempMaxHealth = character:GetPropertyValue('MaxHealth')

	health = tempHealth
	maxHealth = tempMaxHealth
	-- SendMessage(health)
	-- SendMessage(maxHealth)
end

function LocalPlayerSetup(self)
	isDeath = false
	SendMessage("--------------------------------")
	SendMessage("LocalPlayerSetup")
	health = 100
	maxHealth = 100	
	leftHandItem = ""
	rightHandItem = ""
	SendMessage(self:get():GetFullName())
	localPlayerId = self:get():GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex")
end

function OnHit(self,DamageTaken,DamageEvent,PawnInstigator,DamageCauser)
	local temp = self:get():GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex")	
	if temp ~= localPlayerId then
		return
	end


	local camera = self:get():GetPropertyValue("Controller"):GetPropertyValue("PlayerCameraManager")
	if camera:IsValid() ~= true then
		SendMessage("camera is not found")
		return
	end
	local view = camera:GetPropertyValue("ViewTarget")
	if view:IsValid() ~= true then
		SendMessage("view is not found")
		return
	end
	playerYaw = view.POV.Rotation.Yaw


	
	health = self:get():GetPropertyValue('Health')
	maxHealth = self:get():GetPropertyValue('MaxHealth')
	SendMessage("--------------------------------")
	-- SendMessage(DamageCauser:get():GetFullName())
	-- SendMessage(DamageCauser:get():GetClass():GetFullName())	
	-- SendMessage(self:get():GetFullName())
	-- SendMessage(tostring(self:get():GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex")))
	-- SendMessage(tostring(localPlayerId))
	SendMessage(tostring(health))
	SendMessage(tostring(maxHealth))

	local enemy = DamageCauser:get():GetPropertyValue('Owner')
	if enemy:IsValid() == false then 
		SendMessage("PoisonDamage")
		truegear.play_effect_by_uuid("PoisonDamage")
		SendMessage("enemy is not found")
		return
	end	
	SendMessage(DamageCauser:get():GetFullName())
	SendMessage(DamageCauser:get():GetPropertyValue("Owner"):GetFullName())

	local targetRotation = enemy:GetPropertyValue("TargetRotation")
	if targetRotation:IsValid() == true then
		local angleYaw = playerYaw - targetRotation.Yaw
		angleYaw = angleYaw + 180
		if angleYaw > 360 then 
			angleYaw = angleYaw - 360
		elseif angleYaw < 0 then
			angleYaw = 360 + angleYaw
		end
		SendMessage("DefaultDamage," .. angleYaw .. ",0")
		OutputMessage("DefaultDamage," .. angleYaw .. ",0")
		PlayAngle("DefaultDamage",angleYaw,0)
		return
	end
	local enemyController = enemy:GetPropertyValue("Controller")
	if enemyController:IsValid() == false then
		enemyController = DamageCauser:get():GetPropertyValue("Controller")
		if enemyController:IsValid() == false then
			SendMessage("enemyController is not found")
			return
		end
	end
	local enemyPawn = enemyController:GetPropertyValue("Pawn")
	if enemyPawn:IsValid() == false then
		SendMessage("enemyPawn is not found")
		return
	end
	targetRotation = enemyPawn:GetPropertyValue("TargetRotation")
	if targetRotation:IsValid() == false then
		SendMessage("enemyPawn is not found")
		return
	end
	local angleYaw = playerYaw - targetRotation.Yaw
	angleYaw = angleYaw + 180
	if angleYaw > 360 then 
		angleYaw = angleYaw - 360
	elseif angleYaw < 0 then
		angleYaw = 360 + angleYaw
	end
	SendMessage("DefaultDamage," .. angleYaw .. ",0")
	OutputMessage("DefaultDamage," .. angleYaw .. ",0")
	PlayAngle("DefaultDamage",angleYaw,0)
	

end

	
	-- local enemyController = enemy:GetPropertyValue('Controller')
	-- if enemyController:IsValid() == false then 
	-- 	enemyController = enemy
	-- 	if enemyController:IsValid() == false then
	-- 		SendMessage("enemyController is not found")
	-- 		return
	-- 	end
	-- end
	-- local enemyRotation = enemyController:GetPropertyValue('ControlRotation')
	-- if enemyRotation:IsValid() == false then 
	-- 	enemyYaw = enemyController:GetPropertyValue('ControlRotationYaw')
	-- 	if enemyRotation:IsValid() == false and enemyYaw == 999 then 
	-- 		SendMessage("enemyRotation is not found")
	-- 		return
	-- 	end		
	-- end
	
	-- local playerController = self:get():GetPropertyValue('Controller')
	-- if playerController:IsValid() == false then 
	-- 	playerController = self:get()
	-- 	if playerController:IsValid() == false then 
	-- 		SendMessage("playerController is not found")
	-- 		return
	-- 	end
	-- end

	-- local camera = self:get():GetPropertyValue("Owner"):GetPropertyValue("Controller"):GetPropertyValue("PlayerCameraManager")
	-- if camera:IsValid() ~= true then
	-- 	SendMessage("camera is not found")
	-- 	return
	-- end
	-- local view = camera:GetPropertyValue("ViewTarget")
	-- if view:IsValid() ~= true then
	-- 	SendMessage("view is not found")
	-- 	return
	-- end
	-- playerYaw = view.POV.Rotation.Yaw


	-- local playerRotation = playerController:GetPropertyValue('ControlRotation')
	-- if playerRotation:IsValid() == false then 
	-- 	playerYaw = playerController:GetPropertyValue('ControlRotationYaw')
	-- 	if playerRotation:IsValid() == false and playerYaw == 999 then 
	-- 		SendMessage("playerRotation is not found")
	-- 		return
	-- 	else
	-- 		SendMessage(tostring(playerYaw))
	-- 		SendMessage(tostring(enemyYaw))
	-- 		local angleYaw = playerYaw - enemyYaw
	-- 		angleYaw = angleYaw + 180
	-- 		if angleYaw > 360 then 
	-- 			angleYaw = angleYaw - 360
	-- 		elseif angleYaw < 0 then
	-- 			angleYaw = 360 + angleYaw
	-- 		end
	-- 		SendMessage("DefaultDamage," .. angleYaw .. ",0")
	-- 		OutputMessage("DefaultDamage," .. angleYaw .. ",0")
	-- 	end		
	-- else
	-- 	if enemyYaw == 999 then
	-- 		SendMessage(playerRotation.Yaw)
	-- 		SendMessage(enemyRotation.Yaw)
	-- 		local angleYaw = playerRotation.Yaw - enemyRotation.Yaw
	-- 		angleYaw = angleYaw + 180
	-- 		if angleYaw > 360 then 
	-- 			angleYaw = angleYaw - 360
	-- 		elseif angleYaw < 0 then
	-- 			angleYaw = 360 + angleYaw
	-- 		end
	-- 		SendMessage("DefaultDamage," .. angleYaw .. ",0")
	-- 		OutputMessage("DefaultDamage," .. angleYaw .. ",0")
	-- 	else
	-- 		SendMessage(playerRotation.Yaw)
	-- 		SendMessage(enemyYaw)
	-- 		local angleYaw = playerRotation.Yaw - enemyYaw
	-- 		angleYaw = angleYaw + 180
	-- 		if angleYaw > 360 then 
	-- 			angleYaw = angleYaw - 360
	-- 		elseif angleYaw < 0 then
	-- 			angleYaw = 360 + angleYaw
	-- 		end
	-- 		SendMessage("DefaultDamage," .. angleYaw .. ",0")
	-- 		OutputMessage("DefaultDamage," .. angleYaw .. ",0")
	-- 	end
		
	-- end

	-- SendMessage("--------------------------------")
	-- SendMessage("OnHit")
	-- SendMessage(self:get():GetFullName())
	-- SendMessage(DamageCauser:get():GetFullName())

-- end

-- function Death(self)

-- 	SendMessage(self:get():GetFullName())
-- 	local lastTakeHitInfo = self:get():GetPropertyValue("LastTakeHitInfo")
-- 	if lastTakeHitInfo:IsValid() ~= true then
-- 		SendMessage("lastTakeHitInfo is not found")
-- 		return
-- 	end
-- 	local damageCauser = lastTakeHitInfo.DamageCasuer
-- 	SendMessage(damageCauser:GetFullName())

-- 	SendMessage("--------------------------------")
-- 	SendMessage("PlayerDeath")
-- 	OutputMessage("PlayerDeath")
-- 	leftHandItem = ""
-- 	rightHandItem = ""
-- 	isDeath = true
-- end

function Fire(self)

	

	canChamber = false

	local weaponType = self:get():GetPropertyValue("OverlayType")
	local temp = self:get():GetPropertyValue("Owner"):GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex")	
	if temp ~= localPlayerId then
		return
	end
	local isTwoHand = true

	local leftGrabed = self:get():GetPropertyValue("Owner"):GetPropertyValue("LeftObjectHolder"):GetPropertyValue("AttachParent")
	if leftGrabed:IsValid() == true then
		isTwoHand = false
	end
	local rightGrabed = self:get():GetPropertyValue("Owner"):GetPropertyValue("RightObjectHolder"):GetPropertyValue("AttachParent")
	if rightGrabed:IsValid() == true then
		isTwoHand = false
	end

	if leftHandItem ~= "" and rightHandItem ~= "" then
		isTwoHand = false
	end	

	-- if primGripType ~= 1 then
	-- 	return
	-- end
	if self:get():GetFullName() ~= leftHandItem and self:get():GetFullName() ~= rightHandItem then
		if leftHandItem ~= "" then
			leftHandItem = self:get():GetFullName()
			SendMessage("reflash leftHandItem")
		else
			rightHandItem = self:get():GetFullName()
			SendMessage("reflash rightHandItem")
		end
	end	
	
	local isLeft = true
	if self:get():GetFullName() == leftHandItem then
		isLeft = true
	elseif self:get():GetFullName() == rightHandItem then
		isLeft = false
	end

	local category = self:get():GetPropertyValue("Category"):ToString()

	if isTwoHand == true then
		if category == "Shotgun" then
			SendMessage("--------------------------------")
			SendMessage("LeftHandShotgunShoot")
			truegear.play_effect_by_uuid("LeftHandShotgunShoot")
			SendMessage("RightHandShotgunShoot")
			truegear.play_effect_by_uuid("RightHandShotgunShoot")
			
		elseif category == "Sniper" then
			SendMessage("--------------------------------")
			SendMessage("LeftHandShotgunShoot")
			truegear.play_effect_by_uuid("LeftHandShotgunShoot")
			SendMessage("RightHandShotgunShoot")
			truegear.play_effect_by_uuid("RightHandShotgunShoot")
		elseif category == "Rifle" then
			SendMessage("--------------------------------")
			SendMessage("LeftHandRifleShoot")
			truegear.play_effect_by_uuid("LeftHandRifleShoot")
			SendMessage("RightHandRifleShoot")
			truegear.play_effect_by_uuid("RightHandRifleShoot")
		elseif category == "Carbine" then
			SendMessage("--------------------------------")
			SendMessage("LeftHandRifleShoot")
			truegear.play_effect_by_uuid("LeftHandRifleShoot")
			SendMessage("RightHandRifleShoot")
			truegear.play_effect_by_uuid("RightHandRifleShoot")
		elseif category == "SMG" then
			SendMessage("--------------------------------")
			SendMessage("LeftHandSMGShoot")
			truegear.play_effect_by_uuid("LeftHandSMGShoot")
			SendMessage("RightHandSMGShoot")
			truegear.play_effect_by_uuid("RightHandSMGShoot")
		else
			SendMessage("--------------------------------")
			SendMessage("LeftHandPistolShoot")
			truegear.play_effect_by_uuid("LeftHandPistolShoot")
			SendMessage("RightHandPistolShoot")
			truegear.play_effect_by_uuid("RightHandPistolShoot")
		end
		-- if weaponType == 0 then 
		-- 	SendMessage("--------------------------------")
		-- 	SendMessage("LeftHandRifleShoot")
		-- 	truegear.play_effect_by_uuid("LeftHandRifleShoot")
		-- 	SendMessage("RightHandRifleShoot")
		-- 	truegear.play_effect_by_uuid("RightHandRifleShoot")

		-- elseif weaponType == 1 or weaponType == 2 then
		-- 	SendMessage("--------------------------------")
		-- 	SendMessage("LeftHandPistolShoot")
		-- 	truegear.play_effect_by_uuid("LeftHandPistolShoot")
		-- 	SendMessage("RightHandPistolShoot")
		-- 	truegear.play_effect_by_uuid("RightHandPistolShoot")
		-- else
		-- 	SendMessage("--------------------------------")
		-- 	SendMessage("LeftHandShotgunShoot")
		-- 	truegear.play_effect_by_uuid("LeftHandShotgunShoot")
		-- 	SendMessage("RightHandShotgunShoot")
		-- 	truegear.play_effect_by_uuid("RightHandShotgunShoot")
		-- end
	else
		if isLeft then
			if category == "Shotgun" then
				SendMessage("--------------------------------")
				SendMessage("LeftHandShotgunShoot")
				truegear.play_effect_by_uuid("LeftHandShotgunShoot")
				
			elseif category == "Sniper" then
				SendMessage("--------------------------------")
				SendMessage("LeftHandShotgunShoot")
				truegear.play_effect_by_uuid("LeftHandShotgunShoot")
			elseif category == "Rifle" then
				SendMessage("--------------------------------")
				SendMessage("LeftHandRifleShoot")
				truegear.play_effect_by_uuid("LeftHandRifleShoot")
			elseif category == "Carbine" then
				SendMessage("--------------------------------")
				SendMessage("LeftHandRifleShoot")
				truegear.play_effect_by_uuid("LeftHandRifleShoot")
			elseif category == "SMG" then
				SendMessage("--------------------------------")
				SendMessage("LeftHandSMGShoot")
				truegear.play_effect_by_uuid("LeftHandSMGShoot")
			else
				SendMessage("--------------------------------")
				SendMessage("LeftHandPistolShoot")
				truegear.play_effect_by_uuid("LeftHandPistolShoot")
			end
		else
			if category == "Shotgun" then
				SendMessage("--------------------------------")
				SendMessage("RightHandShotgunShoot")
				truegear.play_effect_by_uuid("RightHandShotgunShoot")
				
			elseif category == "Sniper" then
				SendMessage("--------------------------------")
				SendMessage("RightHandShotgunShoot")
				truegear.play_effect_by_uuid("RightHandShotgunShoot")
			elseif category == "Rifle" then
				SendMessage("--------------------------------")
				SendMessage("RightHandRifleShoot")
				truegear.play_effect_by_uuid("RightHandRifleShoot")
			elseif category == "Carbine" then
				SendMessage("--------------------------------")
				SendMessage("RightHandRifleShoot")
				truegear.play_effect_by_uuid("RightHandRifleShoot")
			elseif category == "SMG" then
				SendMessage("--------------------------------")
				SendMessage("RightHandSMGShoot")
				truegear.play_effect_by_uuid("RightHandSMGShoot")
			else
				SendMessage("--------------------------------")
				SendMessage("RightHandPistolShoot")
				truegear.play_effect_by_uuid("RightHandPistolShoot")
			end
		end
		
	end
	SendMessage(self:get():GetFullName())
	SendMessage(tostring(self:get():GetPropertyValue("Category"):ToString()))
	SendMessage(tostring(self:get():GetPropertyValue("OverlayType")))
	SendMessage(tostring(self:get():GetPropertyValue("PrimGripComponent"):GetPropertyValue("CurrentGripType")))
	SendMessage(tostring(self:get():GetPropertyValue("ForeGripComponent"):GetPropertyValue("CurrentGripType")))
	
end

function OnGrabbed(self)
	local temp = self:get():GetPropertyValue("Owner"):GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex")	
	if temp ~= localPlayerId then
		return
	end

	
	local leftPress = self:get():GetPropertyValue("Owner"):GetPropertyValue("bLeftGripPressed")
	local rightPress = self:get():GetPropertyValue("Owner"):GetPropertyValue("bRightGripPressed")

	local rightTriggerValue = self:get():GetPropertyValue("Owner"):GetPropertyValue("RightTriggerCapTouchRaw")
	local leftTriggerValue = self:get():GetPropertyValue("Owner"):GetPropertyValue("LeftTriggerCapTouchRaw")

	local leftGrabed = self:get():GetPropertyValue("Owner"):GetPropertyValue("LeftObjectHolder"):GetPropertyValue("AttachParent")
	local rightGrabed = self:get():GetPropertyValue("Owner"):GetPropertyValue("RightObjectHolder"):GetPropertyValue("AttachParent")
	
	if self:get():GetFullName() == leftHandItem or self:get():GetFullName() == rightHandItem then
		
		if leftGrabed:IsValid() ~= true and rightGrabed:IsValid() ~= true and canWeaponTwoHand == true then
			if weaponTwoHand == "LeftHand" then
				SendMessage("--------------------------------")
				SendMessage("RightHandPickupItem1")
				truegear.play_effect_by_uuid("RightHandPickupItem")
			elseif weaponTwoHand == "RightHand" then
				SendMessage("--------------------------------")
				SendMessage("LeftHandPickupItem1")
				truegear.play_effect_by_uuid("LeftHandPickupItem")
			end
			canWeaponTwoHand = false
		elseif leftGrabed:IsValid() == true or rightGrabed:IsValid() == true then
			canWeaponTwoHand = true
		end
		return
	end

	if isOutputItem == true then
		local slot = SlotCheck(self)
		SendMessage("--------------------------------")
		SendMessage(slot .. "OutputItem")
		truegear.play_effect_by_uuid(slot .. "OutputItem")
		isOutputItem = false
	end

	if leftHandItem == "" and (leftPress == true or leftTriggerValue > 0.9) then		
		if rightIsPrimaryWeapon == true then
			rightHandItem = self:get():GetFullName()
			-- SendMessage("--------------------------------")
			-- SendMessage("RightHandPickupItem2")
			-- truegear.play_effect_by_uuid("RightHandPickupItem")
			if IsWeapon(self) then 
				weaponTwoHand = "RightHand"
			end
		else
			SendMessage("--------------------------------")
			SendMessage("LeftHandPickupItem2")
			truegear.play_effect_by_uuid("LeftHandPickupItem")	
			if IsWeapon(self) then 
				weaponTwoHand = "LeftHand"
			end
			leftIsPrimaryWeapon = IsPrimaryWeapon(self)
			leftHandItem = self:get():GetFullName()
			SendMessage(self:get():GetFullName())
			SendMessage("leftItem: " .. leftHandItem)
			SendMessage("rightItem: " .. rightHandItem)	
		end
			
	elseif rightHandItem == "" and (rightPress == true or rightTriggerValue > 0.9) then
		if leftIsPrimaryWeapon == true then
			leftHandItem = self:get():GetFullName()
			-- SendMessage("--------------------------------")
			-- SendMessage("LeftHandPickupItem2")
			-- truegear.play_effect_by_uuid("LeftHandPickupItem")	
			if IsWeapon(self) then 
				weaponTwoHand = "LeftHand"
			end
		else
			SendMessage("--------------------------------")
			SendMessage("RightHandPickupItem2")
			truegear.play_effect_by_uuid("RightHandPickupItem")
			if IsWeapon(self) then 
				weaponTwoHand = "RightHand"
			end
			rightIsPrimaryWeapon = IsPrimaryWeapon(self)
			rightHandItem = self:get():GetFullName()
			SendMessage(self:get():GetFullName())
			SendMessage("leftItem: " .. leftHandItem)
			SendMessage("rightItem: " .. rightHandItem)
		end
		
	end

	SendMessage("Category: " .. self:get():GetPropertyValue("Category"):ToString())	
end

function OnDropped(self)
	local temp = self:get():GetPropertyValue("Owner"):GetPropertyValue("Owner"):GetPropertyValue("NetPlayerIndex")	
	if temp ~= localPlayerId then
		return
	end

	canPullBowString = false

	if self:get():GetFullName() == leftHandItem then	
		leftHandItem = ""	
		leftIsPrimaryWeapon = false
		SendMessage("--------------------------------")
		SendMessage("OnDropped")		
		SendMessage("leftItem: " .. leftHandItem)
		SendMessage("rightItem: " .. rightHandItem)		
	elseif self:get():GetFullName() == rightHandItem then
		rightHandItem = ""
		rightIsPrimaryWeapon = false
		SendMessage("--------------------------------")
		SendMessage("OnDropped")		
		SendMessage("leftItem: " .. leftHandItem)
		SendMessage("rightItem: " .. rightHandItem)	
	end
	-- local item = self:get()
	-- if string.find(item:GetFullName(),'Clip') then
	-- 	SendMessage(tostring(item:GetPropertyValue("Owner"):GetFullName()))
	-- 	if item:GetPropertyValue("Owner"):GetPropertyValue("OverlayType"):IsValid() then
	-- 		local isLeft = true
	-- 		if self:get():GetFullName() == leftHandItem then
	-- 			isLeft = true
	-- 		elseif self:get():GetFullName() == rightHandItem then
	-- 			isLeft = false
	-- 		else
	-- 			return
	-- 		end
	-- 		if isLeft then
	-- 			SendMessage("LeftReloadAmmo")
	-- 			truegear.play_effect_by_uuid("LeftReloadAmmo")
	-- 		else
	-- 			SendMessage("RightReloadAmmo")
	-- 			truegear.play_effect_by_uuid("RightReloadAmmo")
	-- 		end
	-- 	end
	-- end
end

-- function HeartBeat()
-- 	if type(health) ~= "number" or type(maxHealth) ~= "number" then
-- 		return
-- 	end
-- 	if health < maxHealth / 3 then
-- 		SendMessage("--------------------------------")
-- 		SendMessage("HeartBeat")
-- 		truegear.play_effect_by_uuid("HeartBeat")
-- 	end
-- end


function PullBowString()
	if canPullBowString then
		SendMessage("--------------------------------")
		SendMessage("PullBowString")
		truegear.play_effect_by_uuid("PullBowString")
	end
end

truegear.seek_by_uuid("DefaultDamage")
truegear.init("963930", "ContractorsVR")

function CheckPlayerSpawned()
	RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
		if resetHook then
			local ran, errorMsg = pcall(RegisterHooks)
			if ran then
				SendMessage("--------------------------------")
				SendMessage("HeartBeat")
				truegear.play_effect_by_uuid("HeartBeat")
				resetHook = false
			else
				print(errorMsg)
			end
		end		
	end)
end

SendMessage("TrueGear Mod is Loaded");
CheckPlayerSpawned()


-- LoopAsync(1000, HeartBeat)
LoopAsync(110, PullBowString)