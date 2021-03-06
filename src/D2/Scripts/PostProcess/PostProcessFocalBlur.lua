delay = 0
changeTime = 1
finalValue = 1
function FocalBlur()
  while delay > 0 do
    delay = delay - DeltaTime()
    Sleep(0)
  end
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local startBlur = postProcess.focalBlur
  if finalValue > 1 then
    finalValue = 1
    Broadcast("Post Process Script: Maximum focal blur value is 1, CLAMPING NOW")
  end
  local t = 0
  local val
  while t < 1 do
    val = Lerp(startBlur, finalValue, t)
    postProcess.focalBlur = val
    t = t + DeltaTime() / changeTime
    Sleep(0)
  end
end
