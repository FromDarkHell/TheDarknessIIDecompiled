idleAnimation = Resource()
pushOthers = false
exitOnDamage = false
sound01 = Resource()
sound02 = Resource()
sound03 = Resource()
sound04 = Resource()
function LoopIdle(agent)
  local avatar = agent:GetAvatar()
  avatar:PushOtherControllers(pushOthers)
  agent:LoopAnimation(idleAnimation)
end
function PlayIdle(agent)
  while true do
    if agent:HasActions() == false then
      agent:PlayAnimation(idleAnimation, false)
      Sleep(0)
    end
  end
end
function LoopIdlePlaySounds(agent)
  local avatar = agent:GetAvatar()
  avatar:PushOtherControllers(pushOthers)
  agent:LoopAnimation(idleAnimation)
  agent:SetExitOnDamage(exitOnDamage)
  agent:PlaySpeech(sound01, true)
  Sleep(1)
  agent:PlaySpeech(sound02, true)
  Sleep(1.5)
  agent:PlaySpeech(sound03, true)
  Sleep(1)
  agent:PlaySpeech(sound04, true)
end
