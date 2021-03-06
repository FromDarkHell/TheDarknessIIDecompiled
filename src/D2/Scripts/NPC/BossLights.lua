lightType = Type()
lightColor = {
  Color()
}
damageFX = {
  Type()
}
healthStage = {
  500,
  200,
  0
}
bossAvatar = Type()
applyFXFirst = false
function BossLights()
  local avatar = gRegion:FindNearest(bossAvatar, Vector(), INF)
  local light = avatar:Attach(lightType, Symbol(), Vector(0, 1, 0))
  local damageFXInstances = {}
  local fx
  for i = 1, #damageFX do
    fx = avatar:Attach(damageFX[i], Symbol(), Vector(0, 1, 0))
    table.insert(damageFXInstances, fx)
  end
  for i = 1, #healthStage do
    if applyFXFirst then
      if not IsNull(damageFXInstances[i]) then
        damageFXInstances[i]:Enable()
      end
      if 1 < i and not IsNull(damageFXInstances[i - 1]) then
        damageFXInstances[i - 1]:Destroy()
      end
    end
    if not IsNull(lightColor[i]) then
      light:SetColor(lightColor[i])
    end
    while not IsNull(avatar) and avatar:GetHealth() > healthStage[i] do
      Sleep(0)
    end
    if IsNull(avatar) then
      break
    end
    if not applyFXFirst then
      if not IsNull(damageFXInstances[i]) then
        damageFXInstances[i]:Enable()
      end
      if 1 < i and not IsNull(damageFXInstances[i - 1]) then
        damageFXInstances[i - 1]:Destroy()
      end
    end
  end
  if not IsNull(light) then
    light:Destroy()
  end
end
