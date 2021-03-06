damageAmount = 5
timeToWait = 0.5
initialDelay = 1
local damagePlayer = false
function OnTouched(object)
  damagePlayer = true
end
function OnUntouched(object)
  damagePlayer = false
end
function DamageOverTime(entity)
  ObjectPortHandler(entity, "OnTouched")
  ObjectPortHandler(entity, "OnUntouched")
  local player = gRegion:GetPlayerAvatar()
  local firstRun = true
  while true do
    if damagePlayer == true then
      if firstRun == true then
        Sleep(initialDelay)
        firstRun = false
      end
      player:Damage(damageAmount)
    end
    Sleep(timeToWait)
  end
end
