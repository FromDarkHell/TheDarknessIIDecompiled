shakeTime = 3
shakeMultiplier = 10
shakeIndefinitely = false
rumble = true
rumbleDuration = 2
local StartCameraShakeInternal = function()
  local t = 0
  local levelInfo = gRegion:GetLevelInfo()
  local players = gRegion:GetHumanPlayers()
  _T.gStopCameraShake = false
  if rumble == true then
    for i = 1, #players do
      players[i]:PlayForceFeedback(0.5, 0.5, rumbleDuration)
    end
  end
  if shakeIndefinitely then
    shakeTime = t + 1
  end
  while t < shakeTime and not _T.gStopCameraShake do
    levelInfo.postProcess.viewShake.mShakeAmbient = Abs(Sin(t)) * shakeMultiplier
    t = t + DeltaTime()
    if shakeIndefinitely then
      shakeTime = t + 1
    end
    Sleep(0)
  end
  levelInfo.postProcess.viewShake.mShakeAmbient = 0
end
function StartCameraShake()
  StartCameraShakeInternal()
end
function StartCameraShakeOnDestroy(instigator)
  if not IsNull(instigator) and instigator:GetHealth() < 0 then
    StartCameraShakeInternal()
  end
end
function StopCameraShake()
  _T.gStopCameraShake = true
end
