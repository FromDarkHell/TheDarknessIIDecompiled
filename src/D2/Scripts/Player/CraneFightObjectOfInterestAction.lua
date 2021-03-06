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
objectLookOffset = Vector()
objectIsStatic = true
nearbyPlayersSearchOrigin = Instance()
maxEnableDistance = 0
enableForNearestPlayerOnly = false
npcOfInterestAvatarType = Type()
npcSearchOrigin = Instance()
initialDelay = 2
intervalTime = 10
focusDetectTime = 0.5
local tankSpawned = false
function OnObjectSpawned(entity)
  tankSpawned = true
end
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
  return object
end
function CraneObjectOfInterestAction()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local focusTime = 0
  while IsNull(_T.gTankSpawner) do
    Sleep(0)
  end
  ObjectPortHandler(_T.gTankSpawner, "OnObjectSpawned")
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
      local c = 0
      while c < initialDelay do
        c = c + 1
        Sleep(1)
        if tankSpawned == true or _T.gWave > 4 then
          return
        end
      end
      while tankSpawned == false and _T.gWave < 5 do
        local w = _T.gWave
        local targetObject = FindTarget(objectOfInterest, npcOfInterestAvatarType, npcSearchOrigin)
        objectOfInterestAction:Enable(targetObject, actionParams)
        local t = 0
        while tankSpawned == false and _T.gWave < 5 and t < timeout do
          Sleep(0.1)
          t = t + 0.1
          focusTime = objectOfInterestAction:GetTotalExecutionTime()
          if focusTime > focusDetectTime then
            objectOfInterestAction:Disable()
            return
          end
        end
        objectOfInterestAction:Disable()
        local d = 0
        while d < intervalTime do
          d = d + 0.1
          Sleep(0.1)
          if tankSpawned == true or _T.gWave > 4 or w < _T.gWave then
            return
          end
        end
        Sleep(0)
      end
    end
  end
end
