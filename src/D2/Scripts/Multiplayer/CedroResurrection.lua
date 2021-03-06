npcAvatarCedro = Type()
healthThreshold = 25
effectType = Type()
timeToDissolve = 1
function CheckHealth()
  local dead = false
  local avatarCedro = gRegion:FindNearest(npcAvatarCedro, Vector())
  local agentCedro = avatarCedro:GetAgent()
  local dissolve
  local timeElapsed = 0
  local pos
  while dead == false do
    local cedroHealth = avatarCedro:GetHealth()
    if cedroHealth < healthThreshold then
      avatarCedro:DamageControl():SetDamageMultiplier(0)
      pos = avatarCedro:GetPosition()
      gRegion:CreateEntity(effectType, pos, Rotation())
      while timeElapsed < timeToDissolve do
        dissolve = Lerp(0, 1, timeElapsed / timeToDissolve)
        avatarCedro:SetDissolve(dissolve)
        timeElapsed = timeElapsed + DeltaTime()
        Sleep(0)
      end
      avatarCedro:SetDissolve(1)
      avatarCedro:Destroy()
      dead = true
    end
    Sleep(0)
  end
end
