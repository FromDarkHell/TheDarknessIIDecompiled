avatarTypes = {
  Type()
}
waypoints = {
  Instance()
}
maxDistanceFromPlayer = 50
minDistanceFromPlayer = 0
retreatAudio = Resource()
function KillRemainingAgents()
  local avatarsLeft = {}
  local avatars
  local player = gRegion:GetPlayerAvatar()
  local temp = waypoints
  local retreatAudioPlayed = false
  for i = 1, #avatarTypes do
    avatars = gRegion:FindAll(avatarTypes[i], player:GetPosition(), minDistanceFromPlayer, maxDistanceFromPlayer)
    if not IsNull(avatars) and 0 < #avatars then
      for k = 1, #avatars do
        if not retreatAudioPlayed then
          avatars[k]:PlaySound(retreatAudio, false)
          retreatAudioPlayed = true
        end
        avatars[k]:ScriptRunChildScript(Symbol("MoveToAndRemove"), false)
      end
    end
  end
end
function MoveToAndRemove(entity)
  local agent = entity:GetAgent()
  if not IsNull(waypoints) and #waypoints > 0 then
    agent:MoveTo(waypoints[math.random(1, #waypoints)], true, true, true)
  end
  entity:Destroy()
end
