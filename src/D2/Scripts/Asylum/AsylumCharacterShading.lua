avatarType = Type()
npcSpawnControlType = Type()
npcSpawnTest = Instance()
spawnPointTest = Instance()
function OnAgentSpawned(entity)
  print("lolwut")
  local avatar = gRegion:FindNearest(avatarType, entity:GetPosition(), 5)
  if IsNull(avatar) == false then
    print("AGENTSPAWNED: " .. avatar:GetName())
  else
    print("NILLAGENTOMGWTFBBQ")
  end
end
function Start()
  ObjectPortHandler(npcSpawnTest, "OnAgentSpawned")
  print("Registered GlobalPortHandler")
  local avatars = gRegion:FindAll(avatarType, Vector(), 0, INF)
  for i = 1, #avatars do
  end
end
