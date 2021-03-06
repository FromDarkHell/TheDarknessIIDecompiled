subwayLightTag = Symbol()
function Start()
  local subwayLights = gRegion:FindTagged(subwayLightTag)
  local lightType = Type("/EE/Types/Engine/Light")
  local t = 0
  while true do
    for i = 1, #subwayLights do
      local light = gRegion:FindNearest(lightType, subwayLights[i]:GetPosition(), 1)
      local l = 0
      if IsNull(light) == false then
        l = light:GetSourceLuminance()
      end
      subwayLights[i]:SetMaterialParam("EmissiveMapAtten", l * 10)
    end
    Sleep(0)
    t = 0
  end
end
