lights = {
  Instance()
}
brightnessDecrement = 0.1
function DimLight()
  local brightness, newBrightness
  for i = 1, #lights do
    brightness = lights[i]:GetBrightness()
    newBrightness = brightness - brightnessDecrement
    if newBrightness < 0 then
      newBrightness = 0
    end
    lights[i]:SetBrightness(newBrightness)
  end
end
