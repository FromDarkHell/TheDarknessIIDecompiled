lightLength = 5
lightBrightness = 1
delay = 0
function LightFade(light)
  Sleep(delay)
  local t = 0
  local toFade = lightBrightness
  while t < lightLength do
    toFade = (1 - t / lightLength) * lightBrightness
    light:SetBrightness(toFade)
    t = t + DeltaTime()
    Sleep(0)
  end
end
