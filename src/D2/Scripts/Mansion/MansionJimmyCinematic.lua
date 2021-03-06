jimmyCinOpenDoor = Instance()
jimmyCinBeckon = Instance()
jimmyCinIdle = Instance()
enterRoomTrigger = Instance()
local enteredRoom = false
local beckonTime = 3.5
local openDoorEnded = false
function OnTouched(entity)
  if entity == enterRoomTrigger then
    enteredRoom = true
  end
end
function OnStopped(entity)
  if entity == jimmyCinOpenDoor then
    openDoorEnded = true
  end
end
function MansionJimmyCinematic()
  ObjectPortHandler(enterRoomTrigger, "OnTouched")
  ObjectPortHandler(jimmyCinOpenDoor, "OnStopped")
  ObjectPortHandler(jimmyCinBeckon, "OnStopped")
  jimmyCinOpenDoor:FirePort("StartPlaying")
  while openDoorEnded == false do
    Sleep(0)
  end
  if enteredRoom == false then
    jimmyCinBeckon:FirePort("StartPlaying")
    local t = 0
    while t < beckonTime do
      t = t + 0.1
      Sleep(0.1)
    end
    while enteredRoom == false do
      Sleep(0)
    end
  end
  jimmyCinBeckon:FirePort("StopPlaying")
  jimmyCinIdle:FirePort("StartPlaying")
  local t = jimmyCinIdle
end
