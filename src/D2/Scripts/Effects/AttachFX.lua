typeToKill = Type()
typeToAttach = Type()
attachToThis = Instance()
attachToArray = {
  Instance()
}
isAttachedToThis = Instance()
attachPos = Vector()
attachRot = Rotation()
function KillAttached()
  local temp = isAttachedToThis:GetAttachment(typeToKill)
  if not IsNull(temp) then
    temp:Destroy()
  end
end
function Attach()
  if not IsNull(attachToThis) then
    attachToThis:Attach(typeToAttach, Symbol(), attachPos, attachRot)
  end
end
function AttachArray()
  if not IsNull(attachToArray) then
    for count = 1, #attachToArray do
      attachToArray[count]:Attach(typeToAttach, Symbol(), attachPos, attachRot)
    end
  end
end
