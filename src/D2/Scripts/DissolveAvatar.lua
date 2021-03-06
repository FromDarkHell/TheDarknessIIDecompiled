avatarType = Type()
timeToDissolve = 3
function DissolveAvatar()
  local elapsedTime = 0
  local avatar = gRegion:FindNearest(avatarType, Vector(), INF)
  local dissolve = 0
  while elapsedTime < timeToDissolve do
    elapsedTime = elapsedTime + DeltaTime()
    dissolve = Lerp(0, 1, elapsedTime / timeToDissolve)
    avatar:SetDissolve(dissolve)
    Sleep(0)
  end
end
