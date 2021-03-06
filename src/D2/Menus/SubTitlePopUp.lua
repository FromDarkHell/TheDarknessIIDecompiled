avatarRandomized = WeakResource()
avatarJackie = WeakResource()
conversationVisibilityRadius = 8
waitBeforeFadeOut = 1.5
local mLocalPlayers, mAvatar
local mAvatarIsJackie = false
local mConversationHeader = {
  STATE_FadeIn = 0,
  STATE_Show = 1,
  STATE_FadeOut = 2,
  STATE_Hide = 3,
  title = "",
  entity = nil,
  state = STATE_Hide
}
local mSubTitleText
local mWaitBeforeFadeOut = -1
local mFrameCount = 0
local mExplicitHeaderText = ""
function Initialize(movie)
  mExplicitHeaderText = ""
  mFrameCount = 0
  mConversationHeader = {
    STATE_FadeIn = 0,
    STATE_Show = 1,
    STATE_FadeOut = 2,
    STATE_Hide = 3,
    title = "",
    entity = nil,
    state = 0
  }
  mConversationHeader.state = mConversationHeader.STATE_Hide
  mLocalPlayers = gRegion:ScriptGetLocalPlayers()
  mAvatar = mLocalPlayers[1]:GetAvatar()
  mWaitBeforeFadeOut = -1
  mAvatarIsJackie = false
end
local function _SetExplicitHeaderText(newText)
  mExplicitHeaderText = newText
end
function SetExplicitHeaderText(movie, newText)
  _SetExplicitHeaderText(newText)
end
local function UpdateConversationHeader(movie, avatar, targetEntity, hasWeapons, weaponMode)
  local newState = mConversationHeader.STATE_FadeOut
  if mConversationHeader.state == mConversationHeader.STATE_Hide then
    newState = mConversationHeader.STATE_Hide
  end
  local isTENull = IsNull(targetEntity)
  if not isTENull or mExplicitHeaderText ~= "" then
    newState = mConversationHeader.STATE_FadeIn
  elseif mConversationHeader.state == mConversationHeader.STATE_Show then
    if mWaitBeforeFadeOut < 0 then
      mWaitBeforeFadeOut = waitBeforeFadeOut
    end
    mWaitBeforeFadeOut = mWaitBeforeFadeOut - RealDeltaTime()
    if 0 < mWaitBeforeFadeOut then
      return
    end
  end
  if newState == mConversationHeader.STATE_FadeOut and mConversationHeader.state == mConversationHeader.STATE_Show then
    FlashMethod(movie, "ConversationHeader.Container.gotoAndPlay", "FadeOut")
    mConversationHeader.title = ""
    newState = mConversationHeader.STATE_Hide
  elseif newState == mConversationHeader.STATE_FadeIn and mConversationHeader.state == mConversationHeader.STATE_Hide then
    FlashMethod(movie, "ConversationHeader.Container.gotoAndPlay", "FadeIn")
    mWaitBeforeFadeOut = -1
    newState = mConversationHeader.STATE_Show
  else
    if mConversationHeader.state == mConversationHeader.STATE_Show then
      local conversationTitle = mExplicitHeaderText
      if not isTENull and targetEntity:IsA(avatarRandomized) then
        conversationTitle = targetEntity:GetAvatarName()
        _SetExplicitHeaderText("")
      end
      local titlesAreDifferent = conversationTitle ~= mConversationHeader.title
      if titlesAreDifferent and (mConversationHeader.state == mConversationHeader.STATE_Show or mConversationHeader == mConversationHeader.STATE_FadeIn) then
        movie:SetVariable("ConversationHeader.Container.Text.text", conversationTitle)
        mConversationHeader.title = conversationTitle
      end
    end
    return
  end
  mConversationHeader.state = newState
end
function NameTagLayoutChange(movie, arg)
  FlashMethod(movie, "ConversationHeader.gotoAndPlay", arg)
end
function OnAvatarChange(movie)
  mAvatarIsJackie = false
  mLocalPlayers = gRegion:ScriptGetLocalPlayers()
  if mLocalPlayers == nil then
    return
  end
  mAvatar = mLocalPlayers[1]:GetAvatar()
  if not IsNull(mAvatar) then
    mAvatarIsJackie = mAvatar:IsA(avatarJackie)
  end
end
function Update(movie)
  if mFrameCount < 2 then
    mFrameCount = mFrameCount + 1
    return
  end
  mFrameCount = 0
  if mAvatarIsJackie and not IsNull(mAvatar) then
    local targetEntity
    local nearestNamedAvatar = mAvatar:FindNearestNamedAvatar()
    if not IsNull(nearestNamedAvatar) then
      targetEntity = nearestNamedAvatar
    end
    UpdateConversationHeader(movie, mAvatar, targetEntity)
  end
end
function DisplaySubTitle(movie, subTitleText)
  if mSubTitleText ~= subTitleText then
    if subTitleText == nil then
      subTitleText = ""
    end
    local darknessText = ""
    local regularText = ""
    if string.char(string.byte(subTitleText, 1)) == "#" then
      darknessText = string.sub(subTitleText, 2)
    else
      regularText = subTitleText
    end
    movie:SetLocalized("SubTitleDarkness.Text.text", darknessText)
    movie:SetLocalized("SubTitleRegular.text", regularText)
    mSubTitleText = subTitleText
  end
  return true
end
