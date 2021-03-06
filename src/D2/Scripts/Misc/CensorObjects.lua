objectArray = {
  Instance()
}
meshSwapArray = {
  Resource()
}
invisMaterial = Resource()
function HideObjects()
  if IsCensored() then
    for i = 1, #objectArray do
      if IsNull(objectArray[i]) == false then
        local obj = objectArray[i]
        if IsNull(invisMaterial) == false then
          obj:SetOverrideMaterial(0, invisMaterial)
          obj:SetOverrideMaterial(1, invisMaterial)
        end
        obj:SetVisibility(false)
        obj:Destroy()
      end
    end
  else
  end
end
function MeshSwap()
  if IsCensored() then
    for i = 1, #objectArray do
      objectArray[i]:SetMesh(meshSwapArray[i], false, false)
    end
  else
  end
end
