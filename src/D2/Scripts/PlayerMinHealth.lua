minimumHealth = 50
function SetPlayerMinHealth()
  local player = gRegion:GetPlayerAvatar()
  while true do
    if player:GetHealth() < minimumHealth then
      player:SetHealth(minimumHealth)
    end
    Sleep(0)
  end
end
