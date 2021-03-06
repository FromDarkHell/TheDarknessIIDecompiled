flashTime = 0.75
maxRadius = 35
jackieType = WeakResource()
darklingAvatarType = WeakResource()
function SetPlayerFlash(entity)
  local player = gRegion:GetLocalPlayer()
  if not IsNull(player) and player:IsA(jackieType) then
    player:FlashBang(entity)
  end
  entity:Destroy()
end
function Start(entity)
  local player = gRegion:GetLocalPlayer()
  local playerFlashFunction = Symbol("SetPlayerFlash")
  local playerFlashed = false
  local avatars = gRegion:GetAvatars()
  for i = 1, #avatars do
    local av = avatars[i]
    if not IsNull(av) and av:IsA(darklingAvatarType) then
      if Distance(entity:GetPosition(), av:GetPosition()) < maxRadius then
        av:Damage(200, Game.DT_INFERON)
      end
      break
    end
  end
  local t = 0
  local r
  while t < 1 do
    r = Lerp(2, maxRadius, t)
    if playerFlashed == false then
      local d = Distance(player:GetPosition(), entity:GetPosition())
      if r >= d and not IsNull(player) and player:IsA(jackieType) then
        entity:ScriptRunChildScript(playerFlashFunction, false)
      end
    end
    t = t + DeltaTime() / flashTime
    Sleep(0)
  end
  if playerFlashed == false then
    entity:Destroy()
  end
end
