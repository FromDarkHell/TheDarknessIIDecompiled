delay = 0
damageAmount = 200
function DamagePlayer()
  Sleep(delay)
  local player = gRegion:GetPlayerAvatar()
  player:Damage(damageAmount)
end
