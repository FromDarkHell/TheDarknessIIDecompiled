npcAvatarAmelie = Type()
npcAvatarJeanLuc = Type()
waypointAmelie = Instance()
waypointJeanLuc = Instance()
healthThreshold = 900
waypointsToDisable = {
  Instance()
}
function CheckHealth()
  local teleported = false
  local waypointPositionAmelie = waypointAmelie:GetPosition()
  local waypointPositionJeanLuc = waypointJeanLuc:GetPosition()
  local avatarAmelie = gRegion:FindNearest(npcAvatarAmelie, Vector())
  local avatarJeanLuc = gRegion:FindNearest(npcAvatarJeanLuc, Vector())
  local agentAmelie = avatarAmelie:GetAgent()
  local agentJeanLuc = avatarJeanLuc:GetAgent()
  while teleported == false do
    local dudesHealthAmelie = avatarAmelie:GetHealth()
    local dudesHealthJeanLuc = avatarJeanLuc:GetHealth()
    if dudesHealthAmelie < healthThreshold or dudesHealthJeanLuc < healthThreshold then
      avatarAmelie:DamageControl():SetDamageMultiplier(0)
      avatarJeanLuc:DamageControl():SetDamageMultiplier(0)
      agentAmelie:MoveTo(waypointAmelie, false, true, true)
      for i = 1, #waypointsToDisable do
        waypointsToDisable[i]:FirePort("Disable")
      end
      agentJeanLuc:MoveTo(waypointJeanLuc, false, true, true)
      if not IsNull(avatarAmelie) then
        avatarAmelie:DamageControl():SetDamageMultiplier(1)
      end
      if not IsNull(avatarJeanLuc) then
        avatarJeanLuc:DamageControl():SetDamageMultiplier(1)
      end
      teleported = true
      local time = 0
      while time < 10 do
        for i = 1, #waypointsToDisable do
          waypointsToDisable[i]:FirePort("Disable")
          time = time + DeltaTime()
          Sleep(0)
        end
      end
    end
    Sleep(0)
  end
end
