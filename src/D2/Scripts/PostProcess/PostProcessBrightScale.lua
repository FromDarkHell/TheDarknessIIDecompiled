delay = 0
changeTime = 1
finalValue = 1
function BrightScale()
  while delay > 0 do
    delay = delay - DeltaTime()
    Sleep(0)
  end
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local changeRate = Abs((postProcess.brightScale - finalValue) / changeTime)
  if finalValue > 2 then
    finalValue = 2
    Broadcast("Post Process Script: Maximum bright scale value is 2, CLAMPING NOW")
  end
  if postProcess.brightScale > finalValue then
    while postProcess.brightScale > finalValue do
      postProcess.brightScale = postProcess.brightScale - DeltaTime() * changeRate
      Sleep(0)
    end
  else
    while postProcess.brightScale < finalValue do
      postProcess.brightScale = postProcess.brightScale + DeltaTime() * changeRate
      Sleep(0)
    end
  end
end
