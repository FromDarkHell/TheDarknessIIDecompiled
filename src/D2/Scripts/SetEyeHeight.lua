eyeHeight = 1.75
usePostAnimDelay = false
function SetEyeHeight()
  if usePostAnimDelay then
    Sleep(0)
    Sleep(0)
  end
  local avatar = gRegion:GetLocalPlayer()
  if not IsNull(avatar) then
    local offset = Vector(0, eyeHeight, 0)
    avatar:SetEyePosition(offset)
  end
  Sleep(0)
end
