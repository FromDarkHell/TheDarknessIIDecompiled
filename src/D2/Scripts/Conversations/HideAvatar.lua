avatarType = Type()
positionHint = Vector()
intialDelay = 0
visible = false
function Start()
  Sleep(intialDelay)
  local avatar = gRegion:FindNearest(avatarType, positionHint, INF)
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(avatarType, positionHint, INF)
    Sleep(0)
  end
  avatar:SetVisibility(visible)
end
