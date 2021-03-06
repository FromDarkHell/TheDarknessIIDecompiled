targetAvatar = Instance()
ragdollType = Type()
local SwitchToRagdoll = function(severBones)
  if IsCensored() == false then
    local ragdoll = gRegion:CreateEntityWithCreator(ragdollType, targetAvatar:GetPosition(), targetAvatar:GetRotation(), targetAvatar)
    if severBones ~= nil then
      for i = 1, #severBones do
        ragdoll:SeverBone(severBones[i])
      end
    end
  end
end
function SwitchToUpperHalfRagdoll()
  if IsCensored() == false then
    local upperBodySevers = {
      Symbol("GAME_L1_LEG1"),
      Symbol("GAME_R1_LEG1")
    }
    SwitchToRagdoll(upperBodySevers)
  end
end
function SwitchToLowerHalfRagdoll()
  if IsCensored() == false then
    local lowerBodySevers = {
      Symbol("GAME_C1_SPINE1")
    }
    SwitchToRagdoll(lowerBodySevers)
  end
end
function SwitchToWholeRagdoll()
  if IsCensored() == false then
    SwitchToRagdoll(nil)
  end
end
