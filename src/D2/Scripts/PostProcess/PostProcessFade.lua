delay = 0
changeTime = 1
finalValue = 1
startValue = 1
fadeSound = Resource()
loadTrigger = Instance()
function Fade()
  if delay > 0 then
    Sleep(delay)
  end
  local playerAvatar = gRegion:GetLocalPlayer()
  if IsNull(playerAvatar) then
    print("PostProcessFade.lua - could not find local player")
    return
  end
  local postProcess = playerAvatar:CameraControl():ScriptGetCurrentPostProcessInfo()
  local startFade = postProcess.fade
  if changeTime == 0 then
    postProcess.fade = finalValue
    return
  end
  local t = 0
  local val
  if IsNull(fadeSound) == false then
    playerAvatar:PlaySound(fadeSound, false)
  end
  while t < 1 do
    val = Lerp(startFade, finalValue, t)
    postProcess.fade = val
    t = t + DeltaTime() / changeTime
    Sleep(0)
  end
  postProcess.fade = finalValue
  Sleep(0)
  if IsNull(loadTrigger) == false then
    loadTrigger:FirePort("LoadImmediate")
  end
end
function FadeIn()
  if delay > 0 then
    Sleep(delay)
  end
  local playerAvatar = gRegion:GetLocalPlayer()
  if IsNull(playerAvatar) then
    print("PostProcessFade.lua - could not find local player")
    return
  end
  local postProcess = playerAvatar:CameraControl():ScriptGetCurrentPostProcessInfo()
  local endFade = postProcess.fade
  if changeTime == 0 then
    postProcess.fade = endFade
    return
  end
  local t = 0
  local val
  if IsNull(fadeSound) == false then
    playerAvatar:PlaySound(fadeSound, false)
  end
  while t < 1 do
    val = Lerp(startValue, endFade, t)
    postProcess.fade = val
    t = t + DeltaTime() / changeTime
    Sleep(0)
  end
  postProcess.fade = endFade
  Sleep(0)
  if IsNull(loadTrigger) == false then
    loadTrigger:FirePort("LoadImmediate")
  end
end
