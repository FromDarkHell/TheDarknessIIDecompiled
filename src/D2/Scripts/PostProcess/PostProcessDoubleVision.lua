initialDelay = 0
changeTime = 1
flashVector = Vector(1, 1, 1)
flashPower = 1
waitTime = 1
pulseNum = 2
local LerpDoubleVision = function(startVector, endVector, startPower, endPower)
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local t = 0
  local powerVal, vectorVal
  while t < 1 do
    powerVal = Lerp(startPower, endPower, t)
    vectorVal = LerpVector(startVector, endVector, t)
    postProcess:SetFlash(vectorVal, powerVal)
    t = t + DeltaTime() / changeTime
    Sleep(0)
  end
end
function DoubleVision()
  Sleep(initialDelay)
  for i = 1, pulseNum do
    LerpDoubleVision(Vector(), flashVector, 0, flashPower)
    Sleep(waitTime)
    LerpDoubleVision(flashVector, Vector(), flashPower, 0)
    Sleep(waitTime)
  end
end
