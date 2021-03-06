attachmentType = Type()
avatarType = Type()
destroyAvatar = true
function RemoveAttachment()
  local avatar = gRegion:FindNearest(avatarType, Vector(), INF)
  while IsNull(avatar) == true do
    avatar = gRegion:FindNearest(avatarType, Vector(), INF)
    Sleep(1)
  end
  local attachment = avatar:GetAttachment(attachmentType)
  if IsNull(attachment) == false then
    attachment:Destroy()
  end
  if destroyAvatar == true and avatar ~= nil then
    avatar:Destroy()
  end
end
