eyeTracking = true
headTracking = true
objectType = Type()
object = Instance()
offset = Vector()
function SetTracking(agent)
  local player = gRegion:GetPlayerAvatar()
  local objectToTrack
  if not IsNull(objectType) then
    objectToTrack = gRegion:FindNearest(objectType, player:GetPosition(), INF)
  elseif not IsNull(object) then
    objectToTrack = object
  else
    objectToTrack = player
  end
  if eyeTracking then
    agent:SetEyeTarget(objectToTrack, offset)
  end
  if headTracking then
    agent:SetLookAtTarget(objectToTrack, offset)
  end
end
function ClearTracking(agent)
  agent:ClearLookAtTarget()
  agent:ClearEyeTarget()
end
