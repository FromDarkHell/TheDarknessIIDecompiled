dest = Instance()
agentAnim = Resource()
playerAnim = Resource()
avatarSound = Resource()
avatarType = Type()
agentAnimDelay = 0
agentMoveDelay = 0
agentSoundDelay = 0
playerAnimDelay = 0
run = false
align = true
function MoveTo()
  local avatars = gRegion:FindAll(avatarType, Vector(0, 0, 0), 0, INF)
  local agent = avatars[1]:GetAgent()
  Sleep(agentMoveDelay)
  agent:MoveTo(dest, run, align, true)
end
function MoveToSpeak()
  local avatars = gRegion:FindAll(avatarType, Vector(0, 0, 0), 0, INF)
  local avatar = avatars[1]
  local agent = avatar:GetAgent()
  Sleep(agentMoveDelay)
  agent:MoveTo(dest, run, align, false)
  Sleep(agentSoundDelay)
  avatar:PlaySound(avatarSound, false)
end
function PlayAnimation()
  local avatars = gRegion:FindAll(avatarType, Vector(0, 0, 0), 0, INF)
  local avatar = avatars[1]
  local agent = avatar:GetAgent()
  local player = gRegion:GetPlayerAvatar()
  if playerAnim ~= nil then
    Sleep(playerAnimDelay)
    player:PlayFPAnimation(playerAnim, false)
  end
  if agentAnim ~= nil then
    Sleep(agentAnimDelay)
    agent:PlayAnimation(agentAnim, false)
  end
end
