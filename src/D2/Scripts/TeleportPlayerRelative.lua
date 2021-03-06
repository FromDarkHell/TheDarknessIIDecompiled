teleportOriginWaypoint = Instance()
teleportEndWaypoint = Instance()
function Teleport()
  local player = gRegion:GetPlayerAvatar()
  local originPoint = teleportOriginWaypoint:GetPosition()
  local endPoint = teleportEndWaypoint:GetPosition()
  local playerPos = player:GetPosition()
  local xOffset = playerPos.x - originPoint.x
  local zOffset = playerPos.z - originPoint.z
  local teleportLocation = Vector(xOffset + endPoint.x, endPoint.y, zOffset + endPoint.z)
  player:Teleport(teleportLocation)
end
