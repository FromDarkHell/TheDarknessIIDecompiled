supportLightType = Type()
navmeshVolume = Instance()
initialDelay = 3
local lightOn = true
function OnTurnedOff()
  lightOn = false
end
function SupportControlNavVolume(agent)
  Sleep(initialDelay)
  local avatar = agent:GetAvatar()
  local light = gRegion:FindNearest(supportLightType, avatar:GetPosition(), INF)
  if not IsNull(light) then
    ObjectPortHandler(light, "OnTurnedOff")
    while lightOn do
      Sleep(0)
    end
  end
  navmeshVolume:FirePort("Enable")
end
