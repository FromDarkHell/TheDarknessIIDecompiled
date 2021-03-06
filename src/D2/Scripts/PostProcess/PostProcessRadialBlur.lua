delay = 0
changeTime = 1
finalValue = 1
function RadialBlur()
  while delay > 0 do
    delay = delay - DeltaTime()
    Sleep(0)
  end
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local startBlur = postProcess.radialBlurStrength
  local t = 0
  local val
  while t < 1 do
    val = Lerp(startBlur, finalValue, t)
    postProcess.radialBlurStrength = val
    t = t + DeltaTime() / changeTime
    Sleep(0)
  end
end
