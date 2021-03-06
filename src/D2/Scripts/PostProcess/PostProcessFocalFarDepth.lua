delay = 0
changeTime = 1
finalValue = 200
function FocalFarDepth()
  while delay > 0 do
    delay = delay - DeltaTime()
    Sleep(0)
  end
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local changeRate = Abs((postProcess.focalFarDepth - finalValue) / changeTime)
  if finalValue > 1000 then
    finalValue = 1000
    Broadcast("Post Process Script: Maximum value is 1000, CLAMPING NOW")
  end
  if postProcess.focalFarDepth > finalValue then
    while postProcess.focalFarDepth > finalValue do
      postProcess.focalFarDepth = postProcess.focalFarDepth - DeltaTime() * changeRate
      Sleep(0)
    end
  else
    while postProcess.focalFarDepth < finalValue do
      postProcess.focalFarDepth = postProcess.focalFarDepth + DeltaTime() * changeRate
      Sleep(0)
    end
  end
end
