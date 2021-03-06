idleIntervalMax = 8
idleIntervalMin = 6
delay = 3
loop = true
trigger = Instance()
randomize = false
darklingBarks = {
  Resource()
}
darklingAvatarType = Type()
function PlayDarklingBark()
  local avatar, damageController, idleTime
  if idleIntervalMax < idleIntervalMin then
    idleIntervalMax = idleIntervalMin
  end
  Sleep(delay)
  if not randomize then
    for i = 1, #darklingBarks do
      if not trigger:IsEnabled() then
        break
      end
      while IsNull(avatar) do
        avatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
        Sleep(0)
        if not IsNull(avatar) then
          damageController = avatar:DamageControl()
        end
      end
      damageController:SetDamageMultiplier(0)
      avatar:PlaySound(darklingBarks[i], true)
      damageController:SetDamageMultiplier(1)
      idleTime = math.random(idleIntervalMin, idleIntervalMax)
      Sleep(idleTime)
      avatar = nil
    end
  end
  while loop and trigger:IsEnabled() do
    while IsNull(avatar) do
      avatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
      Sleep(0)
      if not IsNull(avatar) then
        damageController = avatar:DamageControl()
      end
    end
    damageController:SetDamageMultiplier(0)
    if randomize then
      avatar:PlaySound(darklingBarks[math.random(1, #darklingBarks)], true)
    else
      avatar:PlaySound(darklingBarks[#darklingBarks], true)
    end
    damageController:SetDamageMultiplier(1)
    idleTime = math.random(idleIntervalMin, idleIntervalMax)
    Sleep(idleTime)
    avatar = nil
  end
end
