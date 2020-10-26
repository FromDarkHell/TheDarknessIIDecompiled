local LIB = require("D2.Menus.SharedLibrary")
local interpolator = require("D2.Menus.Interpolator")
local CalloutBarLibrary = require("D2.Menus.CalloutBar")
soundFocus = Resource()
binksToPreprocess = {
  WeakResource()
}
relicDescriptionAudio = {
  Resource()
}
lobbyGameRules = WeakResource()
turfGameRules = WeakResource()
local relicIdsToTrack = {}
local sharedCRLN = ""
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusCycle = "/D2/Language/Menu/RelicBrowser_BrowseRelics"
local statusList = {}
local mLocalPlayers = {}
local mAvatar, mInventoryController, mProfileData, mGameRules, mMovie
local inputBlocked = false
local mRelics = {}
local mActiveRelic, mHowManyRelics
local mRadiansBetweenRelics = 0
local mScrollSpeed = 300
local mScrollDirection = 0
local mCurrentScroll = 0
local mMaxScroll = 0
local mVisibleDescriptionHeight = 330
local mOriginalRelicY, mTitleAndNameDeltaY, mActiveMovieRes, mQueueBink
local mBinkWaitTime = 1
local mRemainingBinkWaitTime = 0
local mRelicDescriptionAudioInstance
local mRelicDescriptionRequiredChapter = 5
local mSkipNextScrub = false
local GetBinkNameForRelic = function(relicName)
  return (string.format("/D2/Videos/Relics/%s_slow.bik", relicName))
end
local function SetCurrentScroll(newScroll, skipScrollBarUpdate)
  mCurrentScroll = Clamp(newScroll, 0, mMaxScroll)
  mMovie:SetVariable("Popup.Description._y", -mCurrentScroll)
  if not skipScrollBarUpdate then
    FlashMethod(mMovie, "Popup.Scroll.ScrollClass.SetScrubberPos", mCurrentScroll / mMaxScroll * 100)
    mSkipNextScrub = true
  end
end
local function UpdateDescriptionScroll(delta)
  if not inputBlocked and mScrollDirection ~= 0 then
    if mScrollDirection < 0 and mCurrentScroll <= 0 or 0 < mScrollDirection and mCurrentScroll >= mMaxScroll then
      return
    end
    SetCurrentScroll(mCurrentScroll + mScrollDirection * mScrollSpeed * delta)
  end
end
function DescriptionScrubberMoveCallback()
  if mSkipNextScrub then
    mSkipNextScrub = false
    return
  end
  local v = tonumber(mMovie:GetVariable("Popup.Scroll.ScrollClass.mPosition"))
  if not IsNull(v) then
    print("what is v?" .. tostring(v))
    SetCurrentScroll(v / 100 * mMaxScroll, true)
  end
end
local function StopRelicDescriptionAudio()
  if not IsNull(mRelicDescriptionAudioInstance) then
    mRelicDescriptionAudioInstance:Stop(true)
  end
  mRelicDescriptionAudioInstance = nil
end
local function PlayRelicDescriptionAudio()
  local chapterNum = gRegion:GetLevelInfo():GetChapterNumber()
  if chapterNum == 0 or chapterNum > mRelicDescriptionRequiredChapter then
    StopRelicDescriptionAudio()
    if mActiveRelic ~= nil and mRelics[mActiveRelic] ~= nil then
      mRelicDescriptionAudioInstance = gRegion:PlaySound(mRelics[mActiveRelic].sound, Vector(), false)
    end
  end
end
function Update()
  local rt = RealDeltaTime()
  interpolator:Update(mMovie, rt)
  UpdateDescriptionScroll(rt)
  if not IsNull(mQueueBink) then
    mRemainingBinkWaitTime = mRemainingBinkWaitTime - rt
    if mRemainingBinkWaitTime <= 0 then
      mActiveMovieRes = Resource(mQueueBink)
      if not IsNull(mActiveMovieRes) then
        print("start a new video " .. mQueueBink)
        mMovie:SetTexture("RelicBinkPlaceholder.png", mActiveMovieRes)
        gRegion:StartVideoTexture(mActiveMovieRes)
        interpolator:Interpolate(mMovie, "Bink", interpolator.LINEAR, {"_alpha"}, {100}, 0.25)
        PlayRelicDescriptionAudio()
      end
      mQueueBink = nil
    end
  end
end
function Shutdown(movie)
  StopRelicDescriptionAudio()
end
local function Close()
  inputBlocked = true
  local function exitCallback()
    mMovie:Close()
  end
  interpolator:Interpolate(mMovie, "Popup", interpolator.EASE_OUT, {"_alpha"}, {0}, 0.25, 0, exitCallback)
end
local function InitRelics(movie)
  local trackRelics = {
    "Tomahawk",
    "NautilusShell",
    "OldBible",
    "GlyphTablet",
    "LongNeckBust",
    "Phurba",
    "GoldenRamHead",
    "AsianBell",
    "DeathMask",
    "AztecTotem",
    "Thumbscrews",
    "FistReliquary",
    "WingedDemon",
    "TorturePear",
    "CrematoryBox",
    "EngravedSkull",
    "AntiqueLantern",
    "IndianWarclub",
    "HandCanon",
    "Scimitar",
    "TibetanPitcher",
    "MaskOfInfamy",
    "ShrunkenHead",
    "ChristsBloodReliquary",
    "IronGag",
    "DragonGlove",
    "Khurdi",
    "CrematoryBoxPointed",
    "CrucifixSunReliquary"
  }
  mRelics = {}
  local foundRelics = 0
  if not IsNull(mProfileData) then
    for i = 1, #trackRelics do
      local relic = {}
      relic.id = D2_Game[trackRelics[i]]
      relic.name = trackRelics[i]
      relic.found = mInventoryController:HasFoundRelic(relic.id)
      if relic.found then
        foundRelics = foundRelics + 1
      end
      relic.sound = relicDescriptionAudio[i]
      table.insert(mRelics, relic)
    end
  end
  mHowManyRelics = #mRelics
  local strFmt = mMovie:GetLocalized("/D2/Language/Menu/RelicsBrowser_RelicCount")
  mMovie:SetVariable("Relics.text", string.format(strFmt, foundRelics, mHowManyRelics))
end
local function InitRelicWheel()
  local originalClipName = "relicCircle.icon1"
  local clipName, fullClipName, clip
  mRadiansBetweenRelics = math.pi * 2 / mHowManyRelics
  local circleRadius = 489
  local directionInRadians = 0
  for i = 1, mHowManyRelics do
    clipName = "icon" .. i
    fullClipName = "relicCircle." .. clipName
    clip = mMovie:GetVariable(fullClipName)
    if IsNull(clip) or tostring(clip) == "undefined" then
      FlashMethod(mMovie, originalClipName .. ".duplicateMovieClip", clipName, i)
    end
    directionInRadians = -mRadiansBetweenRelics * (i - 1)
    mMovie:SetVariable(fullClipName .. "._x", math.floor(math.cos(directionInRadians) * circleRadius))
    mMovie:SetVariable(fullClipName .. "._y", math.floor(math.sin(directionInRadians + math.pi) * circleRadius))
    mMovie:SetVariable(fullClipName .. ".directionInDegrees", 360 + 180 / math.pi * directionInRadians)
    local frame = "Locked"
    if mRelics[i].found then
      frame = mRelics[i].name
    end
    FlashMethod(mMovie, fullClipName .. ".gotoAndStop", frame)
    mMovie:SetVariable(fullClipName .. ".frame.text", i)
  end
end
local function SetActiveRelic(newRelic)
  if mActiveRelic == newRelic then
    return
  end
  StopRelicDescriptionAudio()
  inputBlocked = true
  mActiveRelic = newRelic
  gRegion:PlaySound(soundFocus, Vector(), false)
  if IsNull(mOriginalRelicY) then
    mOriginalRelicY = tonumber(mMovie:GetVariable("RelicName._y"))
  end
  if IsNull(mTitleAndNameDeltaY) then
    mTitleAndNameDeltaY = mOriginalRelicY - tonumber(mMovie:GetVariable("Title._y"))
  end
  local nameTag = "/D2/Language/Menu/RelicBrowser_Locked"
  if mRelics[mActiveRelic].found then
    nameTag = "/D2/Language/Relics/Relic_" .. mRelics[mActiveRelic].name .. "_Title"
  end
  mMovie:SetLocalized("RelicName.Container.Label.text", nameTag)
  local titleLines = tonumber(mMovie:GetVariable("RelicName.Container.Label.textLines"))
  local newRelicNameY = mOriginalRelicY - (titleLines - 1) * 20
  mMovie:SetVariable("RelicName._y", newRelicNameY)
  mMovie:SetVariable("RelicCount.Container.Label.text", mActiveRelic .. "/" .. mHowManyRelics)
  local function rotationDoneCallback()
    if mRelics[mActiveRelic].found then
      mQueueBink = GetBinkNameForRelic(mRelics[mActiveRelic].name)
      mRemainingBinkWaitTime = mBinkWaitTime
      local str = mMovie:GetLocalized("/D2/Language/Relics/Relic_" .. mRelics[mActiveRelic].name)
      str = str .. sharedCRLN .. sharedCRLN .. sharedCRLN .. sharedCRLN .. sharedCRLN
      mMovie:SetLocalized("Popup.Description.Label.text", str)
    else
      mQueueBink = nil
      mMovie:SetVariable("Popup.Description.Label.text", "")
    end
    local descriptionScale = tonumber(mMovie:GetVariable("Popup.Description._xscale")) / 100
    local textHeight = tonumber(mMovie:GetVariable("Popup.Description.Label.textHeight"))
    local totalHeight = textHeight * descriptionScale
    print("totalHeight=" .. tostring(totalHeight))
    mMaxScroll = math.floor(totalHeight - mVisibleDescriptionHeight)
    print("mMaxScroll=" .. tostring(mMaxScroll))
    if mMaxScroll < 0 then
      mMaxScroll = 0
    end
    SetCurrentScroll(0)
    inputBlocked = false
    interpolator:Interpolate(mMovie, "Popup", interpolator.LINEAR, {"_alpha"}, {100}, 0.1)
    FlashMethod(mMovie, "StatusBar.StatusBarClass.Clear")
    statusList = {statusCycle, statusBack}
    if 0 < mMaxScroll and gFlashMgr:GetInputDeviceIconType() ~= DIT_PC then
      table.insert(statusList, 2, "/D2/Language/Menu/RelicBrowser_Scroll")
    end
    for i = 1, #statusList do
      FlashMethod(mMovie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] == statusCycle or statusList[i] == statusBack)
    end
    FlashMethod(mMovie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
    mMovie:SetVariable("Popup.Scroll._visible", 0 < mMaxScroll)
  end
  local turnDuration = 0.1
  interpolator:Interpolate(mMovie, "Popup", interpolator.LINEAR, {"_alpha"}, {0}, turnDuration)
  local currentRotation = math.floor(tonumber(mMovie:GetVariable("relicCircle._rotation")))
  local newRotation = tonumber(mMovie:GetVariable("relicCircle.icon" .. mActiveRelic .. ".directionInDegrees"))
  if 180 < newRotation - currentRotation then
    newRotation = newRotation - 360
  end
  interpolator:Interpolate(mMovie, "relicCircle", interpolator.LINEAR, {"_rotation"}, {newRotation}, turnDuration, 0, rotationDoneCallback)
  local clipName
  for i = 1, mHowManyRelics do
    clipName = "relicCircle.icon" .. i
    interpolator:Interpolate(mMovie, clipName, interpolator.LINEAR, {"_rotation"}, {
      -newRotation
    }, turnDuration)
  end
  if not IsNull(mActiveMovieRes) then
    local function binkCallback()
      print("stop the video")
      gRegion:StopVideoTexture(mActiveMovieRes)
      mActiveMovieRes = nil
    end
    interpolator:Interpolate(mMovie, "Bink", interpolator.LINEAR, {"_alpha"}, {0}, turnDuration, 0, binkCallback)
  end
end
function Initialize(movie)
  sharedCRLN = movie:GetLocalized("/D2/Language/Menu/Shared_CRLN")
  mMovie = movie
  mActiveRelic = nil
  local players = gRegion:ScriptGetLocalPlayers()
  mAvatar = players[1]:GetAvatar()
  mInventoryController = mAvatar:ScriptInventoryControl()
  mProfileData = mInventoryController:GetProfileDataForTalents()
  mGameRules = gRegion:GetGameRules()
  mMovie:SetVariable("bink._alpha", 0)
  mMovie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/RelicBrowser_Title")
  mMovie:SetVariable("Popup.Scroll._visible", false)
  FlashMethod(mMovie, "Popup.Scroll.ScrollClass.SetRange", 100)
  FlashMethod(mMovie, "Popup.Scroll.ScrollClass.SetScrubberPos", 0)
  FlashMethod(mMovie, "Popup.Scroll.ScrollClass.SetButton0PressedCallback", "DescriptionScrubberMoveCallback")
  FlashMethod(mMovie, "Popup.Scroll.ScrollClass.SetButton1PressedCallback", "DescriptionScrubberMoveCallback")
  FlashMethod(mMovie, "Popup.Scroll.ScrollClass.SetScrubberPressedCallback", "DescriptionScrubberMoveCallback")
  FlashMethod(mMovie, "Popup.Scroll.ScrollClass.SetScrubberMoveCallback", "DescriptionScrubberMoveCallback")
  InitRelics()
  InitRelicWheel()
  SetActiveRelic(1)
end
local function HandleMovement(dir)
  if inputBlocked then
    return true
  end
  local direction = 0
  if dir == "up" then
    direction = -1
  elseif dir == "down" then
    direction = 1
  end
  if direction ~= 0 then
    local newValue = mActiveRelic + direction
    local minValue = 1
    local maxValue = mHowManyRelics
    if direction == 1 and newValue > maxValue then
      newValue = minValue
    elseif direction == -1 and minValue > newValue then
      newValue = maxValue
    end
    SetActiveRelic(Clamp(newValue, minValue, maxValue))
  end
  return true
end
function onKeyDown_MENU_DOWN_FROM_ANALOG()
  return HandleMovement("down")
end
function onKeyDown_MENU_DOWN()
  return HandleMovement("down")
end
function onKeyDown_MENU_UP_FROM_ANALOG()
  return HandleMovement("up")
end
function onKeyDown_MENU_UP()
  return HandleMovement("up")
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG()
  return HandleMovement("right")
end
function onKeyDown_MENU_RIGHT(mMovie)
  return HandleMovement("right")
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(mMovie)
  return HandleMovement("left")
end
function onKeyDown_MENU_LEFT(mMovie)
  return HandleMovement("left")
end
function onKeyDown_MENU_CANCEL()
  if not inputBlocked then
    Close()
  end
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusCycle then
    HandleMovement("up")
  elseif statusList[index] == statusBack then
    Close()
  end
end
local function SetScrollDirection(dir)
  mScrollDirection = dir
end
function onKeyDown_MENU_RIGHT_Y(deviceId, id, yPos)
  if not inputBlocked then
    SetScrollDirection(-tonumber(yPos))
  end
  return true
end
function onKeyUp_MENU_RIGHT_Y(deviceId, yPos)
  if not inputBlocked then
    SetScrollDirection(0)
  end
  return true
end
