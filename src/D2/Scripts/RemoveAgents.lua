spawnerType = Type()
initialDelay = 0
function RemoveAgents()
  Sleep(initialDelay)
  local spawners = gRegion:FindAll(spawnerType, Vector(), 0, INF)
  for i = 1, #spawners do
    if IsNull(spawners[i]) == false then
      spawners[i]:RemoveAgents()
    end
  end
end
