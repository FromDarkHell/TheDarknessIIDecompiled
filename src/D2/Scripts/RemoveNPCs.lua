npcAvatarType = Type()
cullRadius = 20
function RemoveNPCs(entity)
  local playerAvatar = gRegion:GetPlayerAvatar()
  while true do
    local npc
    if IsNull(entity) == false and entity:IsA(npcAvatarType) then
      npc = entity
    else
    end
    if IsNull(npc) == false then
      local d = Distance(playerAvatar:GetPosition(), npc:GetPosition())
      if d > cullRadius then
        npc:Destroy()
      end
    end
    Sleep(0)
  end
end
