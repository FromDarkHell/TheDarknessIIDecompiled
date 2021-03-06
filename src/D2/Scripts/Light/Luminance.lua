light = Instance()
decoration = Instance()
emissMult = 3
local lightTurnedOff = false
function OnTurnedOff(entity)
  lightTurnedOff = true
end
function Start()
  if IsNull(light) == false then
    ObjectPortHandler(light, "OnTurnedOff")
  end
  while lightTurnedOff == false do
    local l = light:GetSourceLuminance()
    decoration:SetMaterialParam("EmissiveMapAtten", l * emissMult)
    Sleep(0)
  end
end
