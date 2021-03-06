wireDecoType = Type()
wireDecoInstance = Instance()
wireSearchRadius = 20
currentEmissive = 1
endEmissive = 0
duration = 2
function GeneratorWire(entity)
  local location = entity:GetPosition()
  local wire = gRegion:FindNearest(wireDecoType, location, wireSearchRadius)
  local elapsedTime = 0
  local val
  if not IsNull(wire) then
    while elapsedTime < duration do
      val = Lerp(currentEmissive, endEmissive, elapsedTime / duration)
      wire:SetMaterialParam("EmissiveMapAtten", val)
      Sleep(0)
      elapsedTime = elapsedTime + DeltaTime()
    end
    wire:SetMaterialParam("EmissiveMapAtten", endEmissive)
  end
end
function GeneratorWireInstance()
  local elapsedTime = 0
  local val
  if not IsNull(wireDecoInstance) then
    while elapsedTime < duration do
      val = Lerp(currentEmissive, endEmissive, elapsedTime / duration)
      wireDecoInstance:SetMaterialParam("EmissiveMapAtten", val)
      Sleep(0)
      elapsedTime = elapsedTime + DeltaTime()
    end
    wireDecoInstance:SetMaterialParam("EmissiveMapAtten", endEmissive)
  end
end
