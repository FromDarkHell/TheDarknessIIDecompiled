initialSpawn = Instance()
introCinematic = Instance()
reinforcementSpawn = Instance()
initialVOList = {
  Resource()
}
reinforcementVOList = {
  Resource()
}
bindGrabbedVOList = {
  Resource()
}
bindObject = Instance()
adaptiveHintScriptTrigger = Instance()
adaptiveHintWave = 3
adaptiveHintEndRepeatTime = 16
enableBindTimeout = 5
delayBeforeRepeatingBindVO = 10
delayAfterWave = {
  8,
  8,
  8,
  0
}
waveLimit = 4
local spawnReinforcements = true
local numEnemies = 0
local wave = 1
local soundPlaying = false
local bindGrabbed = false
local playBindVO = true
local bindDestroyed = false
local bindGrabbable = false
local function PlayVO(sounds, wait)
  local player = gRegion:GetPlayerAvatar()
  while soundPlaying == true do
    Sleep(1)
  end
  soundPlaying = true
  for i = 1, #sounds do
    player:PlaySound(sounds[i], wait)
    Sleep(0.2)
  end
  soundPlaying = false
end
local function PlayRandomVO(sounds)
  local player = gRegion:GetPlayerAvatar()
  local n = 0
  while n < 1 or n > #sounds do
    n = math.random(#sounds)
  end
  while soundPlaying == true do
    Sleep(0)
  end
  if spawnReinforcements == false then
    return
  end
  soundPlaying = true
  player:PlaySound(sounds[n], true)
  Sleep(0.2)
  soundPlaying = false
end
local function DetachBind()
  local player = gRegion:GetPlayerAvatar()
  Sleep(0.5)
  player:Damage(1)
  bindGrabbed = false
end
local function CheckNumEnemies()
  numEnemies = 0
  numEnemies = numEnemies + initialSpawn:GetActiveCount()
  numEnemies = numEnemies + reinforcementSpawn:GetActiveCount()
end
function StartArenaFight()
  bindGrabbable = false
  ObjectPortHandler(bindObject, "OnDestroyed")
  ObjectPortHandler(bindObject, "OnPickedUp")
  while introCinematic:IsPlaying() do
    Sleep(0)
  end
  PlayVO(initialVOList, false)
  initialSpawn:FirePort("Start")
  Sleep(0.5)
  local t = 0
  CheckNumEnemies()
  while 0 < numEnemies and t < enableBindTimeout do
    t = t + 0.1
    Sleep(0.1)
    CheckNumEnemies()
  end
  bindGrabbable = true
  while spawnReinforcements == true and bindDestroyed == false do
    if wave < waveLimit then
      CheckNumEnemies()
      if numEnemies < 1 then
        if wave >= adaptiveHintWave then
          adaptiveHintScriptTrigger:FirePort("Execute")
        end
        local count = 0
        while count < delayAfterWave[wave] and spawnReinforcements == true do
          Sleep(1)
          count = count + 1
        end
        if spawnReinforcements == true then
          reinforcementSpawn:FirePort("Reset")
          PlayRandomVO(reinforcementVOList)
          wave = wave + 1
        end
      end
    else
      spawnReinforcements = false
    end
    Sleep(0)
  end
  local c = 0
  while bindDestroyed == false do
    CheckNumEnemies()
    if numEnemies < 1 then
      c = c + 1
      if c > adaptiveHintEndRepeatTime then
        adaptiveHintScriptTrigger:FirePort("Execute")
        c = 0
      end
    end
    Sleep(1)
  end
  local t = bindGrabbedVOList
  t = delayBeforeRepeatingBindVO
end
function OnDestroyed(entity)
  spawnReinforcements = false
  reinforcementSpawn:FirePort("Stop")
  initialSpawn:FirePort("Stop")
  local player = gRegion:GetPlayerAvatar()
  player:SetHealth(200)
  bindDestroyed = true
end
function OnPickedUp(entity)
  bindGrabbed = true
  if bindGrabbable == true then
    CheckNumEnemies()
    if playBindVO == true and numEnemies < 1 then
      playBindVO = false
      PlayVO(bindGrabbedVOList, true)
      Sleep(delayBeforeRepeatingBindVO)
      playBindVO = true
    else
      DetachBind()
    end
  else
    DetachBind()
  end
end
