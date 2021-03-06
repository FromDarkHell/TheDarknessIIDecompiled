delay = 0
changeTime = 1
startValue = 0.88
finalValue = 1
function GhostBlur()
  while delay > 0 do
    delay = delay - DeltaTime()
    Sleep(0)
  end
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local startBlur = postProcess.ghostBlur
  local t = 0
  local val
  while t < 1 do
    val = Lerp(startBlur, finalValue, t)
    postProcess.ghostBlur = val
    t = t + DeltaTime() / changeTime
    Sleep(0)
  end
end
function GhostBlurWithStart()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local t = 0
  local val
  while t < changeTime do
    val = Lerp(startValue, finalValue, t / changeTime)
    postProcess.ghostBlur = val
    t = t + DeltaTime()
    Sleep(0)
  end
end
