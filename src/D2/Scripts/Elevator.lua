elevator = Instance()
ElevatorLeftDoor = Type()
ElevatorRightDoor = Type()
timeToOpen = 1
startDelay = 0
function CloseDoors()
  local leftDoor = elevator:GetAttachment(ElevatorLeftDoor)
  local rightDoor = elevator:GetAttachment(ElevatorRightDoor)
  local position
  local t = 0
  if 0 < startDelay then
    Sleep(startDelay)
  end
  while t < 1 do
    t = t + DeltaTime() / timeToOpen
    position = LerpVector(Vector(-1, 0, 0), Vector(), t)
    rightDoor:SetAttachLocalSpace(position, Rotation())
    position = LerpVector(Vector(1, 0, 0), Vector(), t)
    leftDoor:SetAttachLocalSpace(position, Rotation())
    Sleep(0)
  end
end
function OpenDoors()
  local leftDoor = elevator:GetAttachment(ElevatorLeftDoor)
  local rightDoor = elevator:GetAttachment(ElevatorRightDoor)
  local position
  local t = 0
  if 0 < startDelay then
    Sleep(startDelay)
  end
  while t < 1 do
    t = t + DeltaTime() / timeToOpen
    position = LerpVector(Vector(), Vector(-1, 0, 0), t)
    rightDoor:SetAttachLocalSpace(position, Rotation())
    position = LerpVector(Vector(), Vector(1, 0, 0), t)
    leftDoor:SetAttachLocalSpace(position, Rotation())
    Sleep(0)
  end
end
