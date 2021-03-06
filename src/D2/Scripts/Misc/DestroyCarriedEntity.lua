function Start()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local carriedEntity = playerAvatar:GetCarriedEntity()
  if IsNull(carriedEntity) == false then
    local carriedEntityType = carriedEntity:GetType()
    if carriedEntity:IsA(Type("/EE/Types/Engine/HitProxyPhysics")) then
      local carriedRagdoll = carriedEntity:GetRagdoll()
      carriedRagdoll:Destroy()
    else
      carriedEntity:Destroy()
    end
  end
end
