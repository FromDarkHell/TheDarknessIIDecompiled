teleportWaypoint = Instance()
delay = 0
function Teleport()
  local player = gRegion:GetPlayerAvatar()
  local pos = teleportWaypoint:GetPosition()
  local rot = teleportWaypoint:GetRotation()
  Sleep(delay)
  player:Teleport(pos)
  player:SetView(rot)
end
