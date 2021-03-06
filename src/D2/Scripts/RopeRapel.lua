ropes = {
  Instance()
}
spawnController = Instance()
animStart = Resource()
animEnd = Resource()
animLoop = Resource()
spawnTrigger = Instance()
startDelay = 0
riseDelay = 0
hideDelay = 0
local spawnEnemies = false
function OnTouched(entity)
  if entity == spawnTrigger then
    spawnEnemies = true
  end
end
function StartRapel()
  ObjectPortHandler(spawnTrigger, "OnTouched")
  local skel
  for i = 1, #ropes do
    skel = ropes[i]
    skel:LoopAnimation(animLoop)
    skel:FirePort("Show")
  end
  while spawnEnemies == false do
    Sleep(0)
  end
  Sleep(startDelay)
  spawnController:FirePort("Start")
  for i = 1, #ropes do
    skel = ropes[i]
    Sleep(0.2)
    skel:PlayAnimation(animStart, false)
  end
  Sleep(riseDelay)
  for i = 1, #ropes do
    skel = ropes[i]
    Sleep(0.3)
    skel:PlayAnimation(animEnd, false)
  end
  Sleep(hideDelay)
  for i = 1, #ropes do
    skel = ropes[i]
    skel:FirePort("Hide")
  end
end
