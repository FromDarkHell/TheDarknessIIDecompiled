mixerArray = {
  Resource()
}
mixer = Resource()
enterLightLowPassFilterBias = -20
multiplayerEnterLightLowPassFilterBias = -10
transitionSpeed = 0.1
mpGameRules = WeakResource()
local mCurrentLPFBias = 0
local mStartLPF = 0
local mTargetLPF = 0
local mLerpDelta = 0
function Initialize()
  mCurrentLPFBias = 0
  mStartLPF = 0
  mTargetLPF = 0
  mLerpDelta = 0
end
function OnEnteredLight()
  local targetLPFBias = enterLightLowPassFilterBias
  local gameRules = gRegion:GetGameRules()
  if not IsNull(gameRules) and not IsNull(mpGameRules) and gameRules:IsA(mpGameRules) then
    targetLPFBias = multiplayerEnterLightLowPassFilterBias
  end
  mStartLPF = mCurrentLPFBias
  mTargetLPF = targetLPFBias
  mLerpDelta = 0
end
function OnEnteredDarkness()
  mStartLPF = mCurrentLPFBias
  mTargetLPF = 0
  mLerpDelta = 0
end
function Update()
  if mCurrentLPFBias ~= mTargetLPF then
    local delta = DeltaTime()
    mLerpDelta = Clamp(mLerpDelta + delta * 2, 0, 1)
    mCurrentLPFBias = Lerp(mStartLPF, mTargetLPF, mLerpDelta)
    if not IsNull(mixer) then
      mixer:SetOcclusionBias(mCurrentLPFBias)
    end
    for i = 1, #mixerArray do
      mixerArray[i]:SetOcclusionBias(mCurrentLPFBias)
    end
  end
end
