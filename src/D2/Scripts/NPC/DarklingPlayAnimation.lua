idleAnim = Resource()
nextAnim = Resource()
delay = 0
function DarklingPlayAnim(agent)
  local avatar = agent:GetAvatar()
  avatar:LoopAnimation(idleAnim)
  Sleep(delay)
  avatar:PlayAnimation(nextAnim, true)
end
