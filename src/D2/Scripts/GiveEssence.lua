essence = 0
function GiveEssence()
  local players = gRegion:GetHumanPlayers()
  for i = 1, #players do
    local playerAvatar = players[i]:GetAvatar()
    local inventory = playerAvatar:ScriptInventoryControl()
    inventory:GiveXP(essence)
  end
end
