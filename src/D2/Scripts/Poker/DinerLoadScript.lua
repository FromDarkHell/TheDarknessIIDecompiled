loadTrigger = Instance()
breakableDoorDeco = Instance()
darknessVoiceScriptTrigger = Instance()
lockPlayerModifier = Instance()
local dialogFinished = false
local doorDestroyed = false
function JackieDarknessConvo()
  ObjectPortHandler(breakableDoorDeco, "OnDestroyed")
  ObjectPortHandler(darknessVoiceScriptTrigger, "OnEnded")
  while doorDestroyed == false do
    Sleep(0)
  end
  lockPlayerModifier:FirePort("Activate")
  while dialogFinished == false do
    Sleep(0)
  end
  loadTrigger:FirePort("Load")
end
function OnDestroyed(entity)
  doorDestroyed = true
end
function OnEnded(entity)
  dialogFinished = true
end
