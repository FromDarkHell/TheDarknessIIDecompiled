usePush = true
useAvoidance = false
function AvatarPushOtherControllers(agent)
  local avatar = agent:GetAvatar()
  agent:UseAvoidance(useAvoidance)
  avatar:PushOtherControllers(usePush)
end
