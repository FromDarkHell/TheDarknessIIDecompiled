decoration = Instance()
binkMaterial = Resource()
binkTexture = Resource()
slot = 1
function StartBink()
  decoration:SetOverrideMaterial(slot, binkMaterial)
  gRegion:StartVideoTexture(binkTexture)
end
function StopBink()
  gRegion:StopVideoTexture(binkTexture)
end
