delayAtFull = 1
changeTime = 2
bloomValue = 2
blurValue = 0.6
brightScaleValue = 2
function LightningStrikePost()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local finalValue = postProcess.bloom
  local brightScaleFinal = postProcess.brightScale
  postProcess.bloom = bloomValue
  postProcess.ghostBlur = blurValue
  postProcess.brightScale = brightScaleValue
  Sleep(delayAtFull)
  local t = 0
  local bloomVal, blurVal, brightScaleVal
  while t < changeTime do
    bloomVal = Lerp(bloomValue, finalValue, t / changeTime)
    postProcess.bloom = bloomVal
    brightScaleVal = Lerp(brightScaleValue, brightScaleFinal, t / changeTime)
    postProcess.brightScale = brightScaleVal
    blurVal = Lerp(blurValue, 0, t / changeTime)
    postProcess.ghostBlur = blurVal
    t = t + DeltaTime()
    Sleep(0)
  end
end
