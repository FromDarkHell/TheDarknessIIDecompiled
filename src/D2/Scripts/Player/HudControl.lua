function RemoveHud()
  local players = gRegion:ScriptGetLocalPlayers()
  local hudStatus = players[1]:GetHudStatus()
  hudStatus:SetVisible(false)
end
function RestoreHud()
  local players = gRegion:ScriptGetLocalPlayers()
  local hudStatus = players[1]:GetHudStatus()
  hudStatus:SetVisible(false)
end
