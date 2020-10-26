darklingAvatarType = Type()
damageMultiplier = 0
function Start()
  local darklingAvatar
  while IsNull(darklingAvatar) == true do
    darklingAvatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
    Sleep(0)
  end
  local darklingDamageController = darklingAvatar:DamageControl()
  darklingDamageController:SetDamageMultiplier(damageMultiplier)
end
