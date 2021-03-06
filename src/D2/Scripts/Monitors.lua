monitors = {
  Instance()
}
errorMaterial = Resource()
damagedMaterial = Resource()
decorationType = Type()
function intialization()
  _T.monitorDamaged = {}
  for i = 1, #monitors do
    _T.monitorDamaged[monitors[i]:GetFullName()] = false
  end
  GlobalPortHandler(decorationType, "OnDamaged")
end
function OnDamaged(entity)
  _T.monitorDamaged[entity:GetFullName()] = true
end
function shutDownServer()
  for i = 1, #monitors do
    if not _T.monitorDamaged[monitors[i]:GetFullName()] and IsNull(_T.gBinkPlayed) then
      monitors[i]:SetOverrideMaterial(0, errorMaterial)
      _T.gBinkPlayed = true
    end
  end
end
