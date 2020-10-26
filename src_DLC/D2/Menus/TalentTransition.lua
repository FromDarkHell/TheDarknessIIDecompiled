talentsMovie = Resource()
transitionSound = Resource()
desiredBlur = 10
blurTransitionRate = 100
desiredBloom = 1
bloomTransitionRate = 10
desiredSaturation = 0
saturationTransitionRate = 10
desaturationColor = Color()
transitionInDuration = 1
local mOrigBlur = 0
local mOrigBloom = 0
local mOrigSaturation = 0
local mOrigDesaturationColor
local mCurBackgroundAlpha = 0
local mIsTransitionDone = false
local mCurTransitionTime = 0
function Initialize(movie)
  local postProcess = gRegion:GetPlayerAvatar():CameraControl():GetPostProcessInfo()
  mOrigBlur = postProcess.radialBlurStrength
  mOrigBloom = postProcess.bloom
  mOrigSaturation = postProcess.saturation
  mOrigDesaturationColor = postProcess.desaturateColor
  mCurBackgroundAlpha = 0
  mCurTransitionTime = 0
  mIsTransitionDone = false
  if not IsNull(transitionSound) then
    gRegion:PlaySound(transitionSound, Vector(), false)
  end
end
function Update(movie)
  if mIsTransitionDone then
    if not gFlashMgr:FindMovie(talentsMovie) then
      movie:Close()
    end
    return
  end
  local delta = DeltaTime()
  mCurTransitionTime = mCurTransitionTime + delta
  local postProcess = gRegion:GetPlayerAvatar():CameraControl():GetPostProcessInfo()
  local curBlur = postProcess.radialBlurStrength
  local curBloom = postProcess.bloom
  local curSaturation = postProcess.saturation
  curBloom = curBloom + delta * bloomTransitionRate
  if curBloom > desiredBloom then
    curBloom = desiredBloom
  end
  curSaturation = curSaturation - delta * saturationTransitionRate
  if curSaturation < desiredSaturation then
    curSaturation = desiredSaturation
  end
  mCurBackgroundAlpha = mCurBackgroundAlpha + delta * blurTransitionRate * 0.04
  if 1 < mCurBackgroundAlpha then
    mCurBackgroundAlpha = 1
  end
  movie:SetBackgroundAlpha(mCurBackgroundAlpha)
  curBlur = curBlur + delta * blurTransitionRate * 5
  if mCurTransitionTime > transitionInDuration then
    if not mIsTransitionDone then
      postProcess.radialBlurStrength = mOrigBlur
      postProcess.bloom = mOrigBloom
      postProcess.saturation = mOrigSaturation
      postProcess.desaturateColor = mOrigDesaturationColor
      gFlashMgr:GotoMovie(talentsMovie)
      mIsTransitionDone = true
    end
  else
    postProcess.radialBlurStrength = curBlur
    postProcess.bloom = curBloom
    postProcess.saturation = curSaturation
    postProcess.desaturateColor = desaturationColor
  end
end
