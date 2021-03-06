waypoint = Instance()
waypointArray = {
  Instance()
}
sleepTimes = {0}
exitRadius = 10
timeout = 0
function SetSingleLocation(agent)
  agent:ReturnToAiControl()
  agent:SetDesiredWaypoint(waypoint)
end
function SetSingleLocationExitRadius(agent)
  agent:ReturnToAiControl()
  agent:SetDesiredWaypoint(waypoint)
  local t = 0
  while not IsNull(agent) and t < timeout do
    local player = gRegion:GetPlayerAvatar()
    local avatar = agent:GetAvatar()
    local playerPos = player:GetPosition()
    local avatarPos = avatar:GetPosition()
    if 0 < timeout then
      t = t + DeltaTime()
    end
    if Distance(playerPos, avatarPos) < exitRadius then
      break
    end
    Sleep(0)
  end
  agent:SetDesiredWaypoint(nil)
  agent:ReturnToAiControl()
end
function SetMultipleLocations(agent)
  agent:ReturnToAiControl()
  for i = 1, #waypointArray do
    agent:SetDesiredWaypoint(waypointArray[i])
    if IsNull(sleepTimes[i]) == false then
      Sleep(sleepTimes[i])
    else
      Sleep(0)
    end
  end
end
