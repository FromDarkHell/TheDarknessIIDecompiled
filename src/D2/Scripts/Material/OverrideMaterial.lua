decoration = Instance()
material = Resource()
slot = 1
function OverrideMaterial()
  decoration:SetOverrideMaterial(slot, material)
end
