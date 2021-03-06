victorType = Type()
maxIndex = 2
movementDistance = 10
waypointLayer1Array = {
  Instance()
}
waypointLayer2Array = {
  Instance()
}
waypointLayer3Array = {
  Instance()
}
waypointLayer4Array = {
  Instance()
}
finalWaypoint = Instance()
conversationLength = 10
destroyAtEnd = true
local findArray
function findArray()
  local index = 0
  if 0 < #waypointLayer1Array then
    index = 1
  end
  if 0 < #waypointLayer2Array then
    index = 2
  end
  if 0 < #waypointLayer3Array then
    index = 3
  end
  if 0 < #waypointLayer4Array then
    index = 5
  end
  return index
end
local getArrayFromIndex
function getArrayFromIndex(arrayIndex)
  if arrayIndex == 1 then
    return waypointLayer1Array
  end
  if arrayIndex == 2 then
    return waypointLayer2Array
  end
  if arrayIndex == 3 then
    return waypointLayer3Array
  end
  if arrayIndex == 4 then
    return waypointLayer4Array
  end
end
local moveToWaypointInBand
function getNextWaypointInBand(array, avatarTarget)
  local nearestWaypoint
  local nearestDistance = 9999
  local nearestIndex = 1
  for i = 1, #array do
    local wp = array[i]:GetPosition()
    local distance = Distance(avatarTarget:GetPosition(), wp)
    if nearestDistance > distance then
      nearestWaypoint = wp
      nearestDistance = distance
      nearestIndex = i
    end
  end
  local randomVal = RandomInt(0, #array - 1)
  local nextVal = 1 + (randomVal + nearestIndex) % #array
  return array[nextVal]
end
function VictorDialogueMovement()
  local gameRules = gRegion:GetGameRules()
  local convTime = 0
  local player = gRegion:GetPlayerAvatar()
  local victorAvatar = gRegion:FindNearest(victorType, Vector())
  while IsNull(victorAvatar) do
    Sleep(0.1)
    victorAvatar = gRegion:FindNearest(victorType, Vector())
  end
  local currentIndex = 1
  maxIndex = findArray() + 1
  local playerInv = player:ScriptInventoryControl()
  local finished = false
  local currentWaypoint
  while not finished do
    Sleep(0)
    local playerDist = Distance(victorAvatar:GetPosition(), player:GetPosition())
    convTime = convTime + DeltaTime()
    if IsNull(victorAvatar) then
      return
    end
    local agent = victorAvatar:GetAgent()
    if not IsNull(agent:GetTarget()) then
      agent:SetLookAtTarget(player, Vector())
    end
    if convTime > conversationLength then
      finished = true
    else
      if playerDist < movementDistance then
        currentIndex = currentIndex + 1
        if currentIndex < maxIndex then
          local array = getArrayFromIndex(currentIndex)
          local waypoint = getNextWaypointInBand(array, victorAvatar)
          if not IsNull(waypoint) then
            if not waypoint == currentWaypoint or IsNull(currentWaypoint) then
              agent:SetLookAtTarget(player, Vector())
              agent:MoveTo(waypoint, false, true, true)
              currentWaypoint = waypoint
            else
              agent:MoveTo(finalWaypoint, false, true, true)
              agent:GetAvatar():SetHidden(true)
              currentWaypoint = waypoint
            end
          else
            agent:MoveTo(finalWaypoint, false, true, true)
            agent:GetAvatar():SetHidden(true)
            currentWaypoint = waypoint
          end
        else
          agent:MoveTo(finalWaypoint, false, true, true)
          agent:GetAvatar():SetHidden(true)
        end
      end
      if playerInv:GetAimEndPointEntity() == victorAvatar then
        local array = getArrayFromIndex(currentIndex)
        local waypoint = getNextWaypointInBand(array, victorAvatar)
        if not waypoint == currentWaypoint or IsNull(currentWaypoint) then
          agent:MoveTo(waypoint, false, true, true)
          agent:SetLookAtTarget(player, Vector())
          currentWaypoint = waypoint
        else
          agent:MoveTo(finalWaypoint, false, true, true)
          agent:GetAvatar():SetHidden(true)
          currentWaypoint = waypoint
        end
      end
    end
  end
  local agent = victorAvatar:GetAgent()
  agent:MoveTo(finalWaypoint, false, true, true)
  agent:SetLookAtTarget(agent:GetTarget(), Vector())
  if destroyAtEnd then
    victorAvatar:Destroy()
  end
end
