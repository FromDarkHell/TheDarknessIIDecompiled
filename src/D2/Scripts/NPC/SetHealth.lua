initialDelay = 0
avatarType = Type()
newHealth = 200
function SetHealth()
  Sleep(initialDelay)
  local avatar = gRegion:FindNearest(avatarType, Vector(), INF)
  avatar:SetHealth(newHealth)
end
function SetAgentHealth(agent)
  Sleep(initialDelay)
  local avatar = agent:GetAvatar()
  avatar:SetHealth(newHealth)
end
