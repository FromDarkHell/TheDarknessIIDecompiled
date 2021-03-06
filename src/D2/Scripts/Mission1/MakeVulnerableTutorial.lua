meleeAvatarType = Type()
waypoint = Instance()
MakeVulnerableDialog = Instance()
GrabVulnerableDialog = Instance()
blockingVolume = Instance()
pistolPickupInstance = Instance()
pistolPickupType = Type()
pistolPickupDialog = Instance()
portTimer = Instance()
jackieModifier = Instance()
function OnPickedUp(entity)
  local playerAvatar = gRegion:GetPlayerAvatar()
  pistolPickupDialog:FirePort("Close")
  portTimer:FirePort("Start")
end
function MakeVulnerable()
  if IsNull(pistolPickupInstance) == false then
    ObjectPortHandler(pistolPickupInstance, "OnPickedUp")
  end
  local playerAvatar = gRegion:GetPlayerAvatar()
  local meleeAvatar = gRegion:FindNearest(meleeAvatarType, waypoint:GetPosition(), 2)
  local initialHealth = 0
  local currentHealth = 0
  if not IsNull(meleeAvatar) then
    initialHealth = meleeAvatar:GetHealth()
    currentHealth = meleeAvatar:GetHealth()
  end
  local carriedEntity = playerAvatar:GetCarriedEntity()
  while not IsNull(meleeAvatar) and 0 < meleeAvatar:GetHealth() do
    if meleeAvatar:GetHealth() ~= initialHealth then
      MakeVulnerableDialog:FirePort("Close")
      GrabVulnerableDialog:FirePort("Open")
      meleeAvatar:SetHealth(initialHealth)
    end
    carriedEntity = playerAvatar:GetCarriedEntity()
    if IsNull(carriedEntity) == false and carriedEntity:IsA(meleeAvatarType) then
      break
    end
    Sleep(0)
  end
  GrabVulnerableDialog:FirePort("Close")
  jackieModifier:FirePort("Activate")
  Sleep(1)
end
