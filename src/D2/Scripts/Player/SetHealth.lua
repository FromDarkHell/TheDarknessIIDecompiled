delay = 1
newHealth = 200
fullHealth = false
function Tutorial()
  Sleep(delay)
  local player = gRegion:GetPlayerAvatar()
  if fullHealth then
    player:SetHealth(player:GetMaxHealth())
  else
    player:SetHealth(newHealth)
  end
end
