lightToFade = Instance()
transitionTime = 1
brightnessAfterFade = 0
turnOffLightWhenFinished = false
function FadeLight()
  local newLightBrightness = lightToFade:GetBrightness()
  local brightnessDelta = lightToFade:GetBrightness() - brightnessAfterFade
  if brightnessDelta < 0 then
    brightnessDelta = brightnessDelta * -1
  end
  local transitionRate = brightnessDelta / transitionTime
  if lightToFade.on == false then
    lightToFade.on = true
  end
  if lightToFade:GetBrightness() > brightnessAfterFade then
    while newLightBrightness > brightnessAfterFade do
      lightToFade:SetBrightness(newLightBrightness)
      newLightBrightness = newLightBrightness - DeltaTime() * transitionRate
      Sleep(0)
    end
  else
    while newLightBrightness < brightnessAfterFade do
      lightToFade:SetBrightness(newLightBrightness)
      newLightBrightness = newLightBrightness + DeltaTime() * transitionRate
      Sleep(0)
    end
  end
  if turnOffLightWhenFinished == true then
    lightToFade.on = false
  end
end
