delay = 0
changeTime = 1
finalValue = 200
function FocalFarPlane()
  while delay > 0 do
    delay = delay - DeltaTime()
    Sleep(0)
  end
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local changeRate = Abs((postProcess.focalFarPlane - finalValue) / changeTime)
  if finalValue > 1000 then
    finalValue = 1000
    Broadcast("Post Process Script: Maximum bloom value is 1000, CLAMPING NOW")
  end
  if postProcess.focalFarPlane > finalValue then
    while postProcess.focalFarPlane > finalValue do
      postProcess.focalFarPlane = postProcess.focalFarPlane - DeltaTime() * changeRate
      Sleep(0)
    end
  else
    while postProcess.focalFarPlane < finalValue do
      postProcess.focalFarPlane = postProcess.focalFarPlane + DeltaTime() * changeRate
      Sleep(0)
    end
  end
end
