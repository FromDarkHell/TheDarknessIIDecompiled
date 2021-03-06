wakeUpAnim = Resource()
idleAnim = Resource()
crawlLeftAnim = Resource()
crawlRightAnim = Resource()
coughAnim = Resource()
local nextAnim
local animCount = 0
function Initialize()
  nextAnim = crawlRightAnim
  local playerAvatar = gRegion:GetPlayerAvatar()
  if not IsNull(playerAvatar) then
    playerAvatar:PlayFPAnimation(wakeUpAnim, true)
    playerAvatar:PlayFPAnimation(coughAnim, true)
    playerAvatar:PlayFPAnimation(idleAnim, false)
  end
end
function OnMoveForward()
  local playerAvatar = gRegion:GetPlayerAvatar()
  if not IsNull(playerAvatar) and nextAnim ~= nil then
    animCount = animCount + 1
    playerAvatar:PlayFPAnimation(nextAnim, true)
    if nextAnim == crawlRightAnim then
      nextAnim = crawlLeftAnim
    else
      nextAnim = crawlRightAnim
    end
    if 5 <= animCount then
      nextAnim = idleAnim
    end
    playerAvatar:PlayFPAnimation(idleAnim, false)
  end
end
