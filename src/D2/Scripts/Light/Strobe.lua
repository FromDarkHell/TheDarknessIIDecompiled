lightBrightness = 1
flashTime = 0.05
sleepTime = 1
function StrobeLight(light)
  while true do
    light:SetBrightness(lightBrightness)
    Sleep(flashTime)
    light:SetBrightness(0)
    Sleep(sleepTime)
  end
end
