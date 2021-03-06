blockVoiceBox = true
avatarType = Type()
blockTeam = false
delay = 0
function SpawnControllerStart(agent)
  agent:SetBlockVoiceBarks(blockVoiceBox, Engine.BLOCK_SOLO)
end
function SearchAvatarStart()
  Sleep(delay)
  local playerAvatar = gRegion:GetLocalPlayer()
  if IsNull(playerAvatar) then
    return
  end
  local avatar = gRegion:FindNearest(avatarType, playerAvatar:GetPosition(), INF)
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(avatarType, playerAvatar:GetPosition(), INF)
    Sleep(0)
  end
  local agent = avatar:GetAgent()
  if blockTeam then
    agent:SetBlockVoiceBarks(blockVoiceBox, Engine.BLOCK_TEAM)
  else
    agent:SetBlockVoiceBarks(blockVoiceBox, Engine.BLOCK_SOLO)
  end
end
