decorations = {
  Instance()
}
emissiveValue = 1
duration = 1
currentEmissive = 0
delay = 0
function SetEmissive()
  Sleep(delay)
  for i = 1, #decorations do
    decorations[i]:SetMaterialParam("EmissiveMapAtten", emissiveValue)
  end
end
function RampEmissive()
  local elapsedTime = 0
  local val
  Sleep(delay)
  while elapsedTime < duration do
    val = Lerp(currentEmissive, emissiveValue, elapsedTime / duration)
    for i = 1, #decorations do
      decorations[i]:SetMaterialParam("EmissiveMapAtten", val)
    end
    Sleep(0)
    elapsedTime = elapsedTime + DeltaTime()
  end
  for i = 1, #decorations do
    decorations[i]:SetMaterialParam("EmissiveMapAtten", emissiveValue)
  end
end
