moverArray = {
  Instance()
}
jointType = Type()
blockType = Type()
moverSleepTime = 4
local moverObjectArray = {}
local currentMover = 1
local function CreateBlock(mover, index)
  Sleep(0)
  mover:FirePort("Start")
  Sleep(0)
  local pos = mover:GetPosition()
  local rot = mover:GetRotation()
  local joint = gRegion:CreateJoint(jointType)
  moverObjectArray[index].joint = joint
  rot.bank = rot.bank + 160
  local block = gRegion:CreateEntity(blockType, pos, rot)
  if IsNull(block) == false then
    ObjectPortHandler(block, "OnPickedUp")
  end
  moverObjectArray[index].block = block
  joint:SetAttached(0, mover)
  joint:SetAttached(1, block)
end
local function FindMoverBlock(block)
  for i = 1, #moverObjectArray do
    if moverObjectArray[i].block == block then
      return i
    end
  end
  return 10
end
local function FindMover(mover)
  for i = 1, #moverObjectArray do
    if moverObjectArray[i].mover == mover then
      return i
    end
  end
  return 10
end
function OnPickedUp(entity)
  local currMover = FindMoverBlock(entity)
  moverObjectArray[currMover].joint:CleanUp()
end
function OnDone(entity)
  local playerAvatar = gRegion:GetPlayerAvatar()
  local currMover = FindMover(entity)
  moverObjectArray[currMover].joint:CleanUp()
  moverObjectArray[currMover].joint = nil
  if IsNull(moverObjectArray[currMover].block) == false and playerAvatar:GetCarriedEntity() ~= moverObjectArray[currMover].block then
    moverObjectArray[currMover].block:Destroy()
    moverObjectArray[currMover].block = nil
  end
  if _T.gStopConveyor == true then
    moverObjectArray[currMover].mover:FirePort("Destroy")
  else
    CreateBlock(moverArray[currMover], currMover)
  end
end
function StartBlocks()
  for i = 1, #moverArray do
    ObjectPortHandler(moverArray[i], "OnDone")
  end
  for i = 1, #moverArray do
    moverObjectArray[i] = {
      mover = moverArray[i],
      joint = nil,
      block = nil
    }
    CreateBlock(moverArray[i], i)
    Sleep(moverSleepTime)
  end
  _T.gStopConveyor = false
end
function StopBlocks()
  _T.gStopConveyor = true
end
