minAggro = 0
maxAggro = 1
spawnControls = {
  Instance()
}
aggroRange = Range()
avatarType = Type()
function ForceAggro(spawnPoint)
  for i = 1, #spawnControls do
    spawnControls[i]:SetForcedAggroRange(Clamp(minAggro, 0, maxAggro), Clamp(maxAggro, minAggro, 1))
  end
end
function TurnOffForcedAggro(spawnPoint)
  for i = 1, #spawnControls do
    spawnControls[i]:TurnOffForcedAggro()
  end
end
function ForcedAggroForAgentsOfType(spawnPoint)
  if IsNull(avatarType) == false then
    local avatars = gRegion:FindAll(avatarType, Vector(0, 0, 0), 0, INF)
    for i = 1, #avatars do
      local avatar = avatars[i]
      if IsNull(avatar) == false then
        local agent = avatar:GetAgent()
        if IsNull(agent) == false then
          agent:SetForcedAggroRange(Range(Clamp(minAggro, 0, maxAggro), Clamp(maxAggro, minAggro, 1)))
        end
      end
    end
  end
end
