desiredPosition = Instance()
delay = 0.5
function TeleportMe(agent)
  local dest = desiredPosition:GetPosition()
  local avatar = agent:GetAvatar()
  Sleep(delay)
  avatar:Teleport(dest)
end
