civilianAvatarType = Type()
cullRadius = 20
function RemoveCivilians(entity)
  local playerAvatar = gRegion:GetPlayerAvatar()
  while true do
    local civ = gRegion:FindNearest(civilianAvatarType, entity:GetPosition(), 5)
    if IsNull(civ) == false then
      local d = Distance(playerAvatar:GetPosition(), civ:GetPosition())
      if d > cullRadius then
        civ:Destroy()
      end
    end
    Sleep(0)
  end
end
