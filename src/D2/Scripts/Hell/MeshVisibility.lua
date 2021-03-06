hideMeshes = {
  Instance()
}
showMeshes = {
  Instance()
}
testMode = false
testHideMaterial = Resource()
testShowMaterial = Resource()
function MeshVisibility()
  if _T.gResetMeshes == true then
    local temp = hideMeshes
    hideMeshes = showMeshes
    showMeshes = temp
    _T.gResetMeshes = false
  end
  if testMode then
    Broadcast("MeshVisibility.lua test mode is on")
    if not IsNull(hideMeshes) then
      for i = 1, #hideMeshes do
        if not IsNull(hideMeshes[i]) then
          hideMeshes[i]:SetVisibility(true)
          hideMeshes[i]:SetOverrideMaterial(0, testHideMaterial)
        end
      end
    end
    if not IsNull(showMeshes) then
      for i = 1, #showMeshes do
        if not IsNull(showMeshes[i]) then
          showMeshes[i]:SetVisibility(true)
          showMeshes[i]:SetOverrideMaterial(0, testShowMaterial)
        end
      end
    end
  else
    if not IsNull(hideMeshes) then
      for i = 1, #hideMeshes do
        if not IsNull(hideMeshes[i]) then
          hideMeshes[i]:SetVisibility(false)
        end
      end
    end
    if not IsNull(showMeshes) then
      for i = 1, #showMeshes do
        if not IsNull(showMeshes[i]) then
          showMeshes[i]:SetVisibility(true)
        end
      end
    end
  end
end
function CheckpointReset()
  _T.gResetMeshes = true
end
