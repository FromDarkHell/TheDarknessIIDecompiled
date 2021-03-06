initialFade = 0
finalFade = 0
initialGain = -7
finalGain = -48
transitionTime = 2
fadeSound = Resource()
masterMixer = Resource()
loadTrigger = Instance()
videoTrigger = Instance()
function Transition()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local playerAvatar = gRegion:GetPlayerAvatar()
  postProcess.fade = initialFade
  Sleep(0)
  local t = 0
  local fadeVal, mixerVal
  if transitionTime ~= 0 then
    if IsNull(fadeSound) == false then
      playerAvatar:PlaySound(fadeSound, false)
    end
    while t < 1 do
      fadeVal = Lerp(initialFade, finalFade, t)
      mixerVal = Lerp(initialGain, finalGain, t)
      postProcess.fade = fadeVal
      masterMixer:SetGain(mixerVal)
      t = t + RealDeltaTime() / transitionTime
      Sleep(0)
    end
  end
  postProcess.fade = finalFade
  masterMixer:SetGain(finalGain)
  if IsNull(videoTrigger) == false then
    videoTrigger:FirePort("PlayImmediate")
  end
  if IsNull(loadTrigger) == false then
    loadTrigger:FirePort("LoadImmediate")
  end
end
