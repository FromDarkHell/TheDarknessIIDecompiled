spawners = {
  Instance()
}
sleep = false
sleepTime = 3
function KillSpawners()
  if sleep == true then
    Sleep(sleepTime)
  end
  for i = 1, #spawners do
    spawners[i]:FirePort("Stop")
    spawners[i]:FirePort("Kill Agents")
  end
end
