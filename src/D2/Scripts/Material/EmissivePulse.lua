decoArray = {
  Instance()
}
minEmissive = 0.2
maxEmissive = 0.9
emissiveScale = 2
function Start(entity)
  local t = 0
  local emissiveFlip = 1
  while true do
    if 1 < t or t < 0 then
      emissiveFlip = emissiveFlip * -1
    end
    entity:SetMaterialParam("EmissiveMapAtten", t * emissiveScale)
    t = t + DeltaTime() * emissiveFlip
    Sleep(0)
  end
end
function ScriptTriggerArrayPulse()
  local t = 0
  local emissiveFlip = 1
  while true do
    if 1 < t or t < 0 then
      emissiveFlip = emissiveFlip * -1
    end
    for i = 1, #decoArray do
      local e = math.max(minEmissive, t * emissiveScale)
      e = math.min(e, maxEmissive)
      decoArray[i]:SetMaterialParam("EmissiveMapAtten", e)
    end
    t = t + DeltaTime() * emissiveFlip
    Sleep(0)
  end
end
