delay = 0
attachmentType = Type()
decoration = Instance()
boneToAttachTo = Symbol()
offsetPosition = Vector(0, 0, 0)
offsetRotation = Rotation(0, 0, 0)
function AddAttachment()
  local attachment = decoration:GetAttachment(attachmentType)
  decoration:Attach(attachmentType, boneToAttachTo, offsetPosition, offsetRotation)
end
