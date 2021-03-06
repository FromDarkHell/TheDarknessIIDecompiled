teleportWaypoints = {
  Instance()
}
delay = 0
function Teleport()
  local players = gRegion:GetHumanPlayers()
  Sleep(delay)
  for i = 1, #players do
    local playerAvatar = players[i]:GetAvatar()
    if not IsNull(playerAvatar) and not playerAvatar:IsKilled() and not playerAvatar:DamageControl():IsPreDeath() then
      local waypointPos = teleportWaypoints[i]:GetPosition()
      playerAvatar:Teleport(waypointPos)
    end
  end
end
