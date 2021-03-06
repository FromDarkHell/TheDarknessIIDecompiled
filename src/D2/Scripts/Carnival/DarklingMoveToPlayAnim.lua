npcAvatarType = Type()
destination = Instance()
run = false
loop = false
anim = Resource()
sound = Resource()
soundDelay = 0
function MoveAgentToPoint(agent)
  local avatar
  Sleep(0)
  if IsNull(agent) then
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    while IsNull(avatar) do
      Sleep(0.1)
      avatar = gRegion:FindNearest(npcAvatarType, Vector())
    end
    agent = avatar:GetAgent()
  else
    avatar = agent:GetAvatar()
  end
  agent:MoveTo(destination, run, true, true)
  Sleep(0)
  if not IsNull(anim) then
    if not loop then
      agent:PlayAnimation(anim, false, false)
    else
      agent:LoopAnimation(anim)
    end
  end
  Sleep(soundDelay)
  if not IsNull(sound) then
    agent:PlaySpeech(sound, false)
  end
  while loop and not IsNull(agent) do
    Sleep(1)
  end
end
