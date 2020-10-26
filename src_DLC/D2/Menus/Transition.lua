local LIB = require("D2.Menus.SharedLibrary")
backgroundTextures = {
  Resource()
}
transitionTextures = {
  Resource()
}
confirmMovie = WeakResource()
transitionScreenStartingAlpha = 20
soundRes = Resource()
local mTexture
local mPlayingNewGameVideo = false
local LoadLevel = function(theLevel)
  local openArgs = Engine.OpenLevelArgs()
  openArgs:SetLevel(theLevel)
  openArgs.saveOnStart = true
  openArgs.migrateServer = false
  Engine.OpenLevel(openArgs)
  gFlashMgr:CloseAllMovies()
end
local function StartNewGame(movie)
  if gFlashMgr:FindMovie(confirmMovie) then
    print("Transition.lua StartNewGame(): confirmation popup still on screen. Aborting new game so user can respond to it.")
    local displayOptions = movie:GetParent()
    if not IsNull(displayOptions) then
      local mainMenu = displayOptions:GetParent()
      if not IsNull(mainMenu) then
        displayOptions:Close()
        mainMenu:Execute("RestartBackgroundVideo", "1")
        mainMenu:SetVariable("._alpha", 100)
      else
        displayOptions:SetVariable("._alpha", 100)
      end
    end
    movie:Close()
    return
  end
  if Engine.GetPlayerProfileMgr():IsLoggedIn() then
    local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    if not IsNull(profile) then
      local profileData = profile:GetGameSpecificData()
      if not IsNull(profileData) then
        profileData:ClearTalents(D2_Game.JACKIE)
      end
    end
  end
  LIB.StopGlobalMusicTrack()
  local defaultGameRules = gGameConfig:GetDefaultGameRules()
  local demoLevels = defaultGameRules.mLevels
  local levelNames = demoLevels:GetLevelNames(false)
  LoadLevel(levelNames[1])
end
function Initialize(thisMovie)
  thisMovie:SetVariable("._alpha", 0)
  thisMovie:SetBackgroundAlpha(0)
end
function PlayTransition(thisMovie, destinationScreenName, videoTextureIndex)
  while _T.doingTransition ~= nil and _T.doingTransition == true do
    Sleep(0.1)
  end
  _T.doingTransition = true
  mTexture = transitionTextures[tonumber(videoTextureIndex)]
  gRegion:StartVideoTexture(mTexture)
  thisMovie:SetTexture("BinkPlaceholder.png", mTexture)
  thisMovie:SetBackgroundAlpha(0)
  repeat
    Sleep(0.1)
  until not gRegion:IsVideoTextureAsyncLoadPending()
  thisMovie:SetVariable("._alpha", transitionScreenStartingAlpha)
  gRegion:PlaySound(soundRes, Vector(), false)
  local destination
  local fadeToBlack = false
  if destinationScreenName == LIB.TRANSITION_DESTINATON_CONTINUE_LAST_SAVE or destinationScreenName == LIB.TRANSITION_DESTINATON_START_NEW_GAME or destinationScreenName == LIB.TRANSITION_DESTINATON_PLAY_NEW_GAME_VIDEO then
    fadeToBlack = true
  elseif destinationScreenName ~= LIB.TRANSITION_DESTINATON_PARENT_SCREEN and destinationScreenName ~= nil then
    destination = WeakResource(destinationScreenName)
  end
  local oldScreenAlpha = 100
  local transitionScreenAlpha = transitionScreenStartingAlpha
  local parentAlpha = 0
  local needStopPrevBink = true
  local parentInstance
  if not IsNull(thisMovie:GetParent()) then
    parentInstance = thisMovie:GetParent():GetParent()
  end
  local transitioningToGameplay = destinationScreenName == LIB.TRANSITION_DESTINATON_CONTINUE_LAST_SAVE or destinationScreenName == LIB.TRANSITION_DESTINATON_START_NEW_GAME or destinationScreenName == LIB.TRANSITION_DESTINATON_PLAY_NEW_GAME_VIDEO
  local origMusicGain = LIB.GetGlobalMusicTrackGain()
  while true do
    local delta = RealDeltaTime()
    oldScreenAlpha = Clamp(oldScreenAlpha - delta * 100, 0, 100)
    if not IsNull(thisMovie:GetParent()) then
      thisMovie:GetParent():SetVariable("._alpha", oldScreenAlpha)
      thisMovie:GetParent():SetBackgroundAlpha(0)
    end
    transitionScreenAlpha = Clamp(transitionScreenAlpha + delta * 200, 0, 100)
    thisMovie:SetBackgroundAlpha(0)
    thisMovie:SetVariable("._alpha", transitionScreenAlpha)
    if 100 <= transitionScreenAlpha and needStopPrevBink then
      needStopPrevBink = false
      LIB.StopBackgroundBink()
    end
    if destination == nil and not fadeToBlack and parentInstance ~= nil then
      parentAlpha = Clamp(parentAlpha + delta * 10, 0, 100)
      parentInstance:SetVariable("._alpha", parentAlpha)
      parentInstance:SetBackgroundAlpha(0)
    end
    if transitioningToGameplay then
      local newGain = Lerp(origMusicGain, -24, 1 - 0.01 * oldScreenAlpha)
      LIB.SetGlobalMusicTrackGain(newGain)
    end
    if IsNull(mTexture) or 0 < mTexture:GetPlayCount() then
      break
    else
      Sleep(0)
    end
  end
  LIB.StopBackgroundBink()
  local newScreenInstance
  if destination ~= nil then
    if not IsNull(thisMovie:GetParent()) then
      newScreenInstance = thisMovie:GetParent():PushChildMovie(destination)
    else
      thisMovie:PushChildMovie(destination)
    end
  elseif destinationScreenName == LIB.TRANSITION_DESTINATON_CONTINUE_LAST_SAVE then
    LIB.StopGlobalMusicTrack()
    if not Engine.GetPlayerProfileMgr():ScriptLoadLastSaveGame() then
      Engine.Disconnect(true)
    end
    _T.doingTransition = false
    return
  elseif destinationScreenName == LIB.TRANSITION_DESTINATON_START_NEW_GAME then
    StartNewGame(thisMovie)
    _T.doingTransition = false
    return
  elseif destinationScreenName == LIB.TRANSITION_DESTINATON_PLAY_NEW_GAME_VIDEO then
    if not IsNull(mTexture) then
      mTexture:SetPlayCount(0)
      gRegion:StopVideoTexture(mTexture)
    end
    gRegion:GetGameRules():StartAttractMode()
    LIB.SetGlobalMusicTrackGain(origMusicGain)
    mPlayingNewGameVideo = true
    _T.doingTransition = false
    return
  else
    newScreenInstance = thisMovie:GetParent():GetParent()
    if newScreenInstance ~= nil then
      newScreenInstance:Execute("RestartBackgroundVideo", "")
    end
    thisMovie:GetParent():Close()
  end
  if not IsNull(mTexture) then
    mTexture:SetPlayCount(0)
    gRegion:StopVideoTexture(mTexture)
  end
  thisMovie:SetVariable("._alpha", 0)
  if not IsNull(newScreenInstance) then
    local curAlpha = 0
    newScreenInstance:SetVariable("._alpha", curAlpha)
    while curAlpha < 1 do
      if not gRegion:IsVideoTextureAsyncLoadPending() then
        local delta = RealDeltaTime()
        curAlpha = curAlpha + delta
        newScreenInstance:SetVariable("._alpha", curAlpha * 100)
      end
      Sleep(0)
    end
    newScreenInstance:SetVariable("._alpha", 100)
  end
  _T.doingTransition = false
  thisMovie:Close()
end
function Update(movie)
  if mPlayingNewGameVideo and not gRegion:GetGameRules():IsInAttractMode() then
    mPlayingNewGameVideo = false
    StartNewGame(movie)
  end
end
local function _AbortAttractVideo()
  if mPlayingNewGameVideo then
    gRegion:GetGameRules():StopAttractMode()
  end
end
function onKeyDown_MENU_SELECT(movie, deviceID)
  _AbortAttractVideo()
  return 1
end
function onKeyDown_PRESS_START(movie, deviceID)
  _AbortAttractVideo()
  return 1
end
function onKeyDown_MENU_CANCEL(movie)
  _AbortAttractVideo()
  return 1
end
