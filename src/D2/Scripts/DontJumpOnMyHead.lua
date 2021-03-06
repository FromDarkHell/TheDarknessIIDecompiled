tooCloseDistance = 2
farEnoughDistance = 6
yThreshold = 2
pushDuration = 0.1
pushAcceleration = 10
function PushPlayer(trigger)
  local localAvatar = gRegion:GetLocalPlayer()
  local distance = 0
  while distance < farEnoughDistance do
    local pushDirection = Vector(1, 0, 0)
    pushDirection = localAvatar:GetPosition() - trigger:GetPosition()
    if pushDirection.y > yThreshold then
      Sleep(0.1)
    else
      pushDirection.y = 0
      distance = Length(pushDirection)
      Normalize(pushDirection)
      if distance < tooCloseDistance then
        localAvatar:ApplyPushAcceleration(pushAcceleration, pushDirection, 0.1)
        Sleep(0.3)
      end
      Sleep(0.1)
    end
  end
end
