explosion = Instance()
loadTrigger = Instance()
modifier = Instance()
videoTrigger = Instance()
function Boom()
  explosion:FirePort("Enable")
end
function slomo()
  local gameRules = gRegion:GetGameRules()
  gameRules:RequestSlomo()
  modifier:FirePort("Activate")
end
function loadNext()
  loadTrigger:FirePort("Load")
end
function PlayDemoMovie()
  local levelInfo = gRegion:GetLevelInfo()
  local gameRules = gRegion:GetGameRules()
  gameRules:CancelSlomo()
  if IsNull(videoTrigger) == false then
    videoTrigger:FirePort("PlayImmediate")
  end
  loadTrigger:FirePort("Stream")
end
