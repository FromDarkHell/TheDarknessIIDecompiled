attachmentInstance = Instance()
attachmentTarget = Instance()
boneName = Symbol()
positionOffset = Vector()
rotationOffset = Rotation()
function AttachEntity()
  if boneName == nil then
    boneName = Symbol()
  end
  attachmentTarget:AttachEntity(attachmentInstance, boneName, positionOffset, rotationOffset)
end
