light = Instance()
decorations = {
  Instance()
}
multiplier = 0.25
function SetEmissive()
  local b = light:GetBrightness()
  for i = 1, #decorations do
    decorations[i]:SetMaterialParam("EmissiveMapAtten", b * multiplier)
  end
end
