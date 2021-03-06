npcAvatarType = Type()
timeToReachDestination = 5
jackieModifier = Instance()
function PlayerMatchSpeed()
  local player = gRegion:GetPlayerAvatar()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector(), INF)
  local currentTime = 0
  local timeCheckInterval = 0.5
  local speedMult, distToPlayer, playerPos, agentPos
  while currentTime < timeToReachDestination do
    agentPos = avatar:GetPosition()
    playerPos = player:GetPosition()
    distToPlayer = Distance(playerPos, agentPos)
    speedMult = distToPlayer / 5
    if 0.8 < speedMult then
      speedMult = 0.8
    elseif speedMult < 0.25 then
      speedMult = 0.25
    end
    player:SetSpeedMultiplier(speedMult)
    currentTime = currentTime + timeCheckInterval
    Sleep(timeCheckInterval)
  end
  player:SetSpeedMultiplier(1)
end
