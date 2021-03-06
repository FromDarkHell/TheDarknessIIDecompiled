pauseMovie = Resource()
videoTrigger = Instance()
function Start()
  local levelInfo = gRegion:GetLevelInfo()
  local gameRules = gRegion:GetGameRules()
  gFlashMgr:GotoMovie(pauseMovie)
  while gameRules:Paused() == true do
    Sleep(0)
  end
  if IsNull(videoTrigger) == false then
    videoTrigger:FirePort("PlayImmediate")
  end
end
