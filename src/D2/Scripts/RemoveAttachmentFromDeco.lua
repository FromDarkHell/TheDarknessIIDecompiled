attachmentType = Type()
decoration = Instance()
function RemoveAttachment()
  local attachment
  if IsNull(decoration) == false then
    attachment = decoration:GetAttachment(attachmentType)
  end
  if IsNull(attachment) == false then
    attachment:Destroy()
  end
end
