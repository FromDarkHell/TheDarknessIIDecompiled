hitProxyType = Type()
function Start(entity)
  local proxy = entity:GetAttachment(hitProxyType)
  while IsNull(proxy) == false do
    Sleep(0)
  end
  entity:SetMaterialParam("EmissiveMapAtten", 0)
end
