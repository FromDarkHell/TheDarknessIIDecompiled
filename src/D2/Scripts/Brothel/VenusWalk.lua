venusAvatarType = Type()
elevatorStartTrigger = Instance()
elevatorSleepTime = 10
local beginSleep = false
function OnTouched()
  beginSleep = true
end
function Start()
  local venusAvatar = gRegion:FindNearest(venusAvatarType, Vector(), INF)
  local playerAvatar = gRegion:GetPlayerAvatar()
  local d = Distance(venusAvatar:GetPosition(), playerAvatar:GetPosition())
  if IsNull(elevatorStartTrigger) == false then
    ObjectPortHandler(elevatorStartTrigger, "OnTouched")
  end
  while IsNull(venusAvatar) == false do
    if beginSleep then
      beginSleep = false
      Sleep(elevatorSleepTime)
    end
    d = Distance(venusAvatar:GetPosition(), playerAvatar:GetPosition())
    local speed = d / 6
    if 0.5 <= speed then
      speed = 0.5
    end
    playerAvatar:SetSpeedMultiplier(speed)
    Sleep(0)
  end
end
