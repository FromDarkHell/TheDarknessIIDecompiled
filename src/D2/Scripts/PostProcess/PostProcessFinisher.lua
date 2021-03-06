startChangeTime = 1
endChangeTime = 2
initialBrightScale = 0.01
peakBrightScale = 1
initialSaturation = 1
minSaturation = 0.975
initialDesaturateColor = Color(255, 255, 255, 255)
peakDesaturateColor = Color(255, 0, 0, 255)
initialRadialBlurStrength = 0
peakRadialBlurStrength = 0
initialBlurStrength = 0
peakBlurStrength = 0
initialFocalFarPlane = 1000
peakFocalFarPlane = 2
initialFocalFarDepth = 0
peakFocalFarDepth = 1
local Apply = function(initialAlpha, targetAlpha, changeTime)
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local alpha = initialAlpha
  local brightScale = initialBrightScale
  local saturation = initialSaturation
  local desaturateColor = initialDesaturateColor
  local focalFarPlane = initialFocalFarPlane
  local focalFarDepth = initialFocalFarDepth
  local radialBlurStrength = initialRadialBlurStrength
  local blurStrength = initialBlurStrength
  while alpha ~= targetAlpha do
    alpha = Converge(alpha, targetAlpha, DeltaTime() / changeTime)
    brightScale = Lerp(initialBrightScale, peakBrightScale, alpha)
    saturation = Lerp(initialSaturation, minSaturation, alpha)
    desaturateColor = initialDesaturateColor:Lerp(peakDesaturateColor, alpha)
    focalFarPlane = Lerp(initialFocalFarPlane, peakFocalFarPlane, alpha)
    focalFarDepth = Lerp(initialFocalFarDepth, peakFocalFarDepth, alpha)
    radialBlurStrength = Lerp(initialRadialBlurStrength, peakRadialBlurStrength, alpha)
    blurStrength = Lerp(initialBlurStrength, peakBlurStrength, alpha)
    postProcess.brightScale = brightScale
    postProcess.saturation = saturation
    postProcess.desaturateColor = desaturateColor
    postProcess.radialBlurStrength = radialBlurStrength
    postProcess.focalFarPlane = focalFarPlane
    postProcess.focalFarDepth = focalFarDepth
    postProcess.blur = blurStrength
    Sleep(0)
  end
end
function Start()
  local postProcess = gRegion:GetLevelInfo().postProcess
  _T.origbrightScale = postProcess.brightScale
  _T.origsaturation = postProcess.saturation
  _T.origdesaturateColor = postProcess.desaturateColor
  _T.origfocalFarPlane = postProcess.radialBlurStrength
  _T.origfocalFarDepth = postProcess.focalFarPlane
  _T.origradialBlurStrength = postProcess.focalFarDepth
  _T.origblurStrength = postProcess.blur
  Apply(0, 1, startChangeTime)
end
function End()
  Apply(1, 0, endChangeTime)
  local postProcess = gRegion:GetLevelInfo().postProcess
  postProcess.brightScale = _T.origbrightScale
  postProcess.saturation = _T.origsaturation
  postProcess.desaturateColor = _T.origdesaturateColor
  postProcess.radialBlurStrength = _T.origfocalFarPlane
  postProcess.focalFarPlane = _T.origfocalFarDepth
  postProcess.focalFarDepth = _T.origradialBlurStrength
  postProcess.blur = _T.origblurStrength
end
