local GetGameState = function()
  local player = gRegion:GetLocalPlayer()
  local teamId = player:GetPlayer():GetTeam()
  return gRegion:GetGameRules():GetGameState(teamId)
end
function TrackAliveNpcs()
  local gameState = GetGameState()
  gameState:TrackAllAliveAvatars(true)
end
function StopTrackingAliveNpcs()
  local gameState = GetGameState()
  gameState:TrackAllAliveAvatars(false)
end
