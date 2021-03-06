mixerArray = {
  Resource()
}
sequencer = Instance()
maxCut = -60
fadeOutTime = 3
fadeInTime = 1
waitTime = 0
local SetGain = function(mixerArray, amount)
  for i = 1, #mixerArray do
    mixerArray[i]:SetGainBias(amount)
  end
end
local SetOcclusion = function(mixerArray, amount)
  for i = 1, #mixerArray do
    mixerArray[i]:SetOcclusionBias(amount)
  end
end
local SetPitch = function(mixerArray, amount)
  for i = 1, #mixerArray do
    mixerArray[i]:SetPitchBias(amount)
  end
end
local UpdateMixer = function(mixerArray, mixerFunc, startVal, endVal, fadeTime)
  local t = 1
  while 0 < t do
    local amount = Lerp(endVal, startVal, t)
    mixerFunc(mixerArray, amount)
    t = t - RealDeltaTime() / fadeTime
    Sleep(0)
  end
end
function FadeOut()
  if IsNull(mixerArray) then
    return
  end
  UpdateMixer(mixerArray, SetGain, 0, maxCut, fadeOutTime)
end
function FadeIn()
  if IsNull(mixerArray) then
    return
  end
  UpdateMixer(mixerArray, SetGain, maxCut, 0, fadeInTime)
end
function OcclusionOn()
  if IsNull(mixerArray) then
    return
  end
  UpdateMixer(mixerArray, SetOcclusion, 0, maxCut, fadeOutTime)
end
function OcclusionOff()
  if IsNull(mixerArray) then
    return
  end
  UpdateMixer(mixerArray, SetOcclusion, maxCut, 0, fadeInTime)
end
function FadeOutWaitFadeIn()
  if IsNull(mixerArray) then
    return
  end
  UpdateMixer(mixerArray, SetGain, 0, maxCut, fadeOutTime)
  Sleep(waitTime)
  UpdateMixer(mixerArray, SetGain, maxCut, 0, fadeInTime)
end
