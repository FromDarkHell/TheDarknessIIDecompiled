avatarType = WeakResource()
function MatchTagEvent(player, tag)
  local avatar = player:GetAvatar()
  if not IsNull(avatar) and avatar:IsA(avatarType) then
    return true
  end
  return false
end
