startDelay = 0.5
soundDelay = 1
waypointDesired = Instance()
numberTeleports = 5
teleportDelay = 0.5
victorType = Type()
soundArray = {
  Resource()
}
waypointArray = {
  Instance()
}
function DarknessThreat()
  Sleep(0.1)
  local playerAvatar = gRegion:GetPlayerAvatar()
  for i = 1, #soundArray do
    playerAvatar:PlaySound(soundArray[i], true)
    Sleep(soundDelay)
    i = i + 1
  end
end
function VictorAlley()
  local avatars = gRegion:FindAll(victorType, Vector(0, 0, 0), 0, INF)
  local victorAvatar = avatars[1]
  local agent = victorAvatar:GetAgent()
  local player = gRegion:GetPlayerAvatar()
  local minDist = 20
  local playerDist = Distance(victorAvatar:GetPosition(), player:GetPosition())
  for i = 1, #soundArray do
    playerDist = Distance(victorAvatar:GetPosition(), player:GetPosition())
    if i == 3 or i == 5 and minDist < playerDist then
      while minDist < playerDist do
        Sleep(0.1)
        playerDist = Distance(victorAvatar:GetPosition(), player:GetPosition())
      end
    end
    victorAvatar:PlaySound(soundArray[i], true)
    Sleep(soundDelay)
    i = i + 1
  end
end
function SingleDialogue()
  Sleep(0.1)
  local playerAvatar = gRegion:GetPlayerAvatar()
  for i = 1, #soundArray do
    playerAvatar:PlaySound(soundArray[i], false)
    Sleep(soundDelay)
    i = i + 1
  end
end
function VictorTeleport()
  Sleep(0.1)
  local avatar = gRegion:FindNearest(victorType, Vector())
  local agent = avatar:GetAgent()
  agent:ReturnToAiControl()
  agent:SetDesiredWaypoint(waypointDesired)
end
function VictorRandomTeleport()
  Sleep(0.1)
  local victorAvatar = gRegion:FindNearest(victorType, Vector())
  local agent = victorAvatar:GetAgent()
  local waypoint, previousWaypoint
  agent:ReturnToAiControl()
  while numberTeleports > 0 do
    waypoint = RandomInt(1, #waypointArray)
    while waypoint == previousWaypoint do
      waypoint = RandomInt(1, #waypointArray)
    end
    agent:SetDesiredWaypoint(waypointArray[waypoint])
    previousWaypoint = waypoint
    Sleep(teleportDelay)
    numberTeleports = numberTeleports - 1
  end
end
