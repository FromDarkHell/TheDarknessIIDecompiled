backgroundSound = Resource()
endPost = Resource()
delay = 2
colorCorrectionMultiplier = 2
radialBlurMultiplier = 10
viewShakeMultiplier = 10
bloomMultiplier = 1
local levelInfo = gRegion:GetLevelInfo()
local playerAvatar = gRegion:GetPlayerAvatar()
local LerpPost = function(startPost, endPost)
  local levelInfo = gRegion:GetLevelInfo()
  local postProcessInfo = levelInfo.postProcess
  local t = 0
  while t < 1 do
    postProcessInfo:SetMixedColorCorrection(startPost, endPost, t)
    t = t + DeltaTime()
    Sleep(0)
  end
end
function Stoned()
  Sleep(delay)
  local postProcessInfo = levelInfo.postProcess
  if IsNull(playerAvatar) then
    playerAvatar = gRegion:GetPlayerAvatar()
  end
  local player = playerAvatar:GetPlayer()
  local soundInstance = playerAvatar:PlaySound(backgroundSound, false)
  local t = 0
  local postProcessInfo = levelInfo.postProcess
  local initialBloom = postProcessInfo.bloom
  local cameraController = gRegion:GetPlayerAvatar():CameraControl()
  _T.gStopStonedEffect = false
  while not _T.gStopStonedEffect do
    if IsNull(soundInstance) then
      soundInstance = playerAvatar:PlaySound(backgroundSound, false)
    end
    local amplitude = soundInstance:GetCurAmplitude()
    local gain = soundInstance:GetMixedGain()
    local pitch = soundInstance:GetPitch()
    local occlusion = soundInstance:GetOcclusion()
    local timeRemaining = soundInstance:GetTimeRemaining()
    cameraController:SetColorCorrectionOpacity(endPost, Pow(amplitude, 4) * colorCorrectionMultiplier)
    if 0 < viewShakeMultiplier then
      postProcessInfo.viewShake.mShakeAmbient = viewShakeMultiplier
      postProcessInfo.viewShake.mShakeDampening = 5
      postProcessInfo.viewShake.mShakeFactorPos = 1
      postProcessInfo.viewShake.mShakeFactorRot = Rotation(0.3, 0.3, 0.3)
      postProcessInfo.viewShake.mShakeSpeed = 0.2
      postProcessInfo.viewShake.mSwayAmplitude = 1
      postProcessInfo.viewShake.mSwaySpeed = 0.1
    end
    postProcessInfo.radialBlurStrength = amplitude * radialBlurMultiplier
    postProcessInfo.bloom = initialBloom * (amplitude * bloomMultiplier)
    Sleep(0)
  end
  soundInstance:Stop(true)
  postProcessInfo.radialBlurStrength = 0
  postProcessInfo.viewShake.mShakeAmbient = 0
  postProcessInfo.bloom = initialBloom
end
function StopStonedEffect()
  Sleep(delay)
  _T.gStopStonedEffect = true
end
