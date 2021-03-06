minTurnToFaceTime = 0.15
maxTurnToFaceTime = 0.25
timeout = 3
activeTime = 3
dofTransitionTime = 0.25
focalNearPlane = 0
focalNearDepth = 0
focalFarPlane = 0
focalFarDepth = 0
FOV = 0
activeRadius = 0
objectOfInterest = Instance()
objectOfInterestType = Type()
objectLookOffset = Vector()
objectIsStatic = true
nearbyPlayersSearchOrigin = Instance()
maxEnableDistance = 0
enableForNearestPlayerOnly = false
npcOfInterestAvatarType = Type()
npcSearchOrigin = Instance()
autoDisable = false
autoDisableTime = 0.5
local FindTarget = function(object, npcAvatarType, searchOrigin)
  if not IsNull(npcAvatarType) then
    local origin = Vector()
    if not IsNull(searchOrigin) then
      origin = searchOrigin:GetPosition()
    end
    local npcAvatar = gRegion:FindNearest(npcAvatarType, origin, INF)
    if not IsNull(npcAvatar) then
      return npcAvatar
    end
  end
  if not IsNull(objectOfInterestType) then
    local foundObj = gRegion:FindNearest(objectOfInterestType, gRegion:GetPlayerAvatar():GetPosition(), INF)
    if not IsNull(foundObj) then
      object = foundObj
    else
      print("EnableObjectOfInterestAction: Unable to find an instance of " .. objectOfInterestType:GetFullName())
    end
  end
  return object
end
function EnableObjectOfInterestAction(instigator)
  local playerAvatar
  if instigator:IsA(Type("/EE/Types/Game/Avatar")) then
    playerAvatar = instigator
  end
  if IsNull(playerAvatar) then
    playerAvatar = gRegion:GetPlayerAvatar()
  end
  if not IsNull(playerAvatar) then
    local objectOfInterestAction = playerAvatar:GetObjectOfInterestAction()
    if not IsNull(objectOfInterestAction) then
      local actionParams = objectOfInterestAction:NewActionParams()
      actionParams.minTurnToFaceTime = minTurnToFaceTime
      actionParams.maxTurnToFaceTime = maxTurnToFaceTime
      actionParams.timeout = timeout
      actionParams.activeTime = activeTime
      actionParams.dofTransitionTime = dofTransitionTime
      actionParams.focalNearPlane = focalNearPlane
      actionParams.focalNearDepth = focalNearDepth
      actionParams.focalFarPlane = focalFarPlane
      actionParams.focalFarDepth = focalFarDepth
      actionParams.FOV = FOV
      actionParams.activeRadiusSqr = activeRadius * activeRadius
      actionParams.objectIsStatic = objectIsStatic
      actionParams.objectLookOffset = objectLookOffset
      local targetObject = FindTarget(objectOfInterest, npcOfInterestAvatarType, npcSearchOrigin)
      objectOfInterestAction:Enable(targetObject, actionParams)
    end
    if autoDisable == true then
      if timeout == 0 then
        return
      end
      local t = 0
      local focusTime = 0
      while t < timeout do
        Sleep(0.1)
        t = t + 0.1
        focusTime = objectOfInterestAction:GetTotalExecutionTime()
        if focusTime > autoDisableTime then
          objectOfInterestAction:Disable()
          return
        end
      end
    end
  end
end
function EnableObjectOfInterestForNearbyPlayers()
  local allPlayers = gRegion:GetHumanPlayers()
  local enableList = {}
  local enableListIndex = 1
  if not IsNull(allPlayers) then
    for i = 1, #allPlayers do
      local playerAvatar = allPlayers[i]:GetAvatar()
      if not IsNull(playerAvatar) then
        if IsNull(nearbyPlayersSearchOrigin) then
          enableList[enableListIndex] = {player = playerAvatar, distance = 0}
          enableListIndex = enableListIndex + 1
        else
          local newItem = {
            player = playerAvatar,
            distance = Distance(playerAvatar:GetPosition(), nearbyPlayersSearchOrigin:GetPosition())
          }
          if newItem.distance <= maxEnableDistance or 0 >= maxEnableDistance then
            if enableForNearestPlayerOnly then
              if enableList[1] == nil or newItem.distance < enableList[1].distance then
                enableList[1] = newItem
              end
            else
              enableList[enableListIndex] = newItem
              enableListIndex = enableListIndex + 1
            end
          end
        end
      end
    end
  end
  if not IsNull(enableList) then
    for i = 1, #enableList do
      local objectOfInterestAction = enableList[i].player:GetObjectOfInterestAction()
      if not IsNull(objectOfInterestAction) then
        local actionParams = objectOfInterestAction:NewActionParams()
        actionParams.minTurnToFaceTime = minTurnToFaceTime
        actionParams.maxTurnToFaceTime = maxTurnToFaceTime
        actionParams.timeout = timeout
        actionParams.activeTime = activeTime
        actionParams.dofTransitionTime = dofTransitionTime
        actionParams.focalNearPlane = focalNearPlane
        actionParams.focalNearDepth = focalNearDepth
        actionParams.focalFarPlane = focalFarPlane
        actionParams.focalFarDepth = focalFarDepth
        actionParams.FOV = FOV
        actionParams.activeRadiusSqr = activeRadius * activeRadius
        actionParams.objectIsStatic = objectIsStatic
        actionParams.objectLookOffset = objectLookOffset
        local targetObject = FindTarget(objectOfInterest, npcOfInterestAvatarType, npcSearchOrigin)
        objectOfInterestAction:Enable(targetObject, actionParams)
      end
    end
  end
end
function DisableObjectOfInterestAction(instigator)
  local playerAvatar
  if instigator:IsA(Type("/EE/Types/Game/Avatar")) then
    playerAvatar = instigator
  end
  if IsNull(playerAvatar) then
    playerAvatar = gRegion:GetPlayerAvatar()
  end
  if not IsNull(playerAvatar) then
    local objectOfInterestAction = playerAvatar:GetObjectOfInterestAction()
    if not IsNull(objectOfInterestAction) then
      objectOfInterestAction:Disable()
    end
  end
end
function DisableObjectOfInterestActionForAllPlayers()
  local allPlayers = gRegion:GetHumanPlayers()
  if not IsNull(allPlayers) then
    for i = 1, #allPlayers do
      local playerAvatar = allPlayers[i]:GetAvatar()
      if not IsNull(playerAvatar) then
        local objectOfInterestAction = playerAvatar:GetObjectOfInterestAction()
        if not IsNull(objectOfInterestAction) then
          objectOfInterestAction:Disable()
        end
      end
    end
  end
end
