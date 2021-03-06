object = Instance()
audio = Resource()
anim = Resource()
anims = {
  Resource()
}
loop = false
attachmentType = Type()
loopLast = false
function PlayAnimOnObject()
  local skel = object
  if not IsNull(attachmentType) then
    skel = object:GetAttachment(attachmentType)
  end
  if not loop then
    skel:PlayAnimation(anim, false)
  else
    skel:LoopAnimation(anim)
  end
  if not IsNull(audio) then
    skel:PlaySound(audio, false)
  end
end
function PlaySequenceAnimsOnObject()
  local skel = object
  if not IsNull(attachmentType) then
    skel = object:GetAttachment(attachmentType)
  end
  for i = 0, #anims do
    if loopLast and i == #anims then
      skel:LoopAnimation(anims[i])
    else
      skel:PlayAnimation(anims[i], true)
    end
  end
end
