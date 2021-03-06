delay = 0
changeTime = 1
finalValue = 1
function Bloom()
  while delay > 0 do
    delay = delay - DeltaTime()
    Sleep(0)
  end
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local changeRate = Abs((postProcess.brightScale - finalValue) / changeTime)
  if finalValue > 2 then
    finalValue = 2
    Broadcast("Post Process Script: Maximum bloom value is 2, CLAMPING NOW")
  end
  if postProcess.bloom > finalValue then
    while postProcess.bloom > finalValue do
      postProcess.bloom = postProcess.bloom - DeltaTime() * changeRate
      Sleep(0)
    end
  else
    while postProcess.bloom < finalValue do
      postProcess.bloom = postProcess.bloom + DeltaTime() * changeRate
      Sleep(0)
    end
  end
end
