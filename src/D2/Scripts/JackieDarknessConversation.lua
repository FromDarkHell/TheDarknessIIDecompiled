dialogue = {
  Resource()
}
padding = {0.25}
delay = 2
loadTrigger = Instance()
breakableDoorDeco = Instance()
local dialogFinished = false
function JackieDarknessConvo()
  local defaultPadding = 0.25
  local playerAvatar = gRegion:GetPlayerAvatar()
  if IsNull(breakableDoorDeco) == false then
    ObjectPortHandler(breakableDoorDeco, "OnDestroyed")
  end
  Sleep(delay)
  for i = 1, #dialogue do
    playerAvatar:PlaySound(dialogue[i], true)
    if i > #padding then
      Sleep(defaultPadding)
    else
      Sleep(padding[i])
    end
  end
  dialogFinished = true
end
function OnDestroyed(entity)
  while dialogFinished == false do
    Sleep(0)
  end
  if loadTrigger ~= nil then
    loadTrigger:FirePort("Load")
  end
end
