delay = 0
decorationToAttach = Type()
npcAvatarType = Type()
boneToAttachTo = Symbol()
offsetPosition = Vector(0, 0, 0)
offsetRotation = Rotation(0, 0, 0)
AttachToAllExistingTypes = false
function AttachDecorationToAvatar()
  Sleep(delay)
  local headBone = Symbol("GAME_C1_HEAD1")
  local avatar
  if AttachToAllExistingTypes then
    avatar = gRegion:FindAll(npcAvatarType, Vector(), 0, INF)
    for i = 1, #avatar do
      avatar[i]:Attach(decorationToAttach, boneToAttachTo, offsetPosition, offsetRotation)
    end
  else
    avatar = gRegion:FindNearest(npcAvatarType, Vector(), INF)
    if not IsNull(avatar) then
      avatar:Attach(decorationToAttach, boneToAttachTo, offsetPosition, offsetRotation)
    end
  end
end
function DestroyAttachedDecoration()
  Sleep(delay)
  local avatar = gRegion:FindNearest(npcAvatarType, Vector(), INF)
  local attachments
  if IsNull(avatar) then
    print("AttachDecorationToAvatar: Avatar not found")
    return
  end
  attachments = avatar:GetAllAttachments(decorationToAttach)
  if not IsNull(attachments) then
    for i = 1, #attachments do
      attachments[i]:FirePort("Destroy")
    end
  end
end
