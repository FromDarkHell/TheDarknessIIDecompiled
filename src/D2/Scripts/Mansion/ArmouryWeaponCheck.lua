lowerWeaponsModifier = Instance()
raiseWeaponsModifier = Instance()
lookTrigger = Instance()
dirTrigger = Instance()
raiseWeaponsDelay = 1
initialRaiseWeaponsDelay = 2
local lookTriggerRearmTime = 1
local dirTriggerPassed = false
local lookTriggerActive = false
function OnPassedThrough()
  dirTriggerPassed = true
end
function OnPassedBack()
  dirTriggerPassed = false
end
function Activated()
  lookTriggerActive = true
  Sleep(lookTriggerRearmTime)
  lookTriggerActive = false
end
function ArmouryWeaponCheck()
  ObjectPortHandler(lookTrigger, "Activated")
  ObjectPortHandler(dirTrigger, "OnPassedThrough")
  ObjectPortHandler(dirTrigger, "OnPassedBack")
  lowerWeaponsModifier:FirePort("Activate")
  Sleep(initialRaiseWeaponsDelay)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  while true do
    if IsNull(playerProfile) then
      return
    end
    if dirTriggerPassed == true then
      lowerWeaponsModifier:FirePort("Activate")
    elseif lookTriggerActive == true then
      lowerWeaponsModifier:FirePort("Activate")
    else
      raiseWeaponsModifier:FirePort("Activate")
    end
    Sleep(0)
  end
end
