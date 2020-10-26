local LIB = require("D2.Menus.SharedLibrary")
lobbyGameRules = WeakResource()
hudMovie = WeakResource()
lobbyHudMovie = WeakResource()
demoLoadingSound = Resource()
demoLevelNames = {
  String()
}
local prevText = "-"
local prevFrame = -1
local startFade = false
local fadeRate = 1.0344827
local fadeTimer = 1
local mCurMpTime
local mFrozen = false
local mMovieInstance, mDemoLoadingSoundInstance
local mLevelName = ""
local mCanShowHint = false
local mMaxHints = 32
local mHintDuration = 7
local mCurrentHintTime = 0
local mCurrentHintIndex = 0
local tintColor = 0
local mHintDelay = 1
local mProgressDelay = 0.5
local mProgressVisible = false
local hudInstance
local mHintTagPrefix = "/D2/Language/Menu/LoadingHint"
local mIsMultiplayer = false
local mSPWhiteScreenHints = {
  1,
  6,
  7,
  8,
  9,
  12,
  13,
  15,
  21,
  22,
  23,
  25,
  26,
  27,
  31,
  32
}
local mMPWhiteScreenHints = {
  7,
  9,
  10,
  11,
  12,
  14,
  15,
  16,
  20,
  23,
  24,
  25,
  27,
  30,
  31,
  32
}
local mMPNeedAltHints = {
  1,
  3,
  5,
  33
}
function Initialize(movie)
  print("Progress Movie: Initialize")
  mMovieInstance = movie
  prevText = "-"
  mCurMpTime = 0
  local gameRules
  if not IsNull(gRegion) then
    gameRules = gRegion:GetGameRules()
  end
  tintColor = 0
  local sessionInfo
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileData
  if playerProfile ~= nil and not IsNull(playerProfile) then
    profileData = playerProfile:GetGameSpecificData()
    if profileData ~= nil and not IsNull(profileData) then
      sessionInfo = profileData:GetLastMPSessionInfo()
      tintColor = profileData:GetLoadingScreenTint()
    end
  end
  if 0 < tintColor then
    movie:SetVariable("WhiteBackground._alpha", 100)
    FlashMethod(movie, "_root.Hint.gotoAndStop", 2)
  end
  if sessionInfo ~= nil and sessionInfo.visible then
    FlashMethod(movie, "SetProgressType", "MP")
  elseif not IsNull(gameRules) and not IsNull(lobbyGameRules) and gameRules:IsA(lobbyGameRules) then
    FlashMethod(movie, "SetProgressType", "MP")
  end
  mMovieInstance:SetVariable("Progress._visible", mProgressVisible)
  FlashMethod(mMovieInstance, "Progress.gotoAndPlay", "Play")
end
local function _Close(movie)
  if not IsNull(mDemoLoadingSoundInstance) then
    mDemoLoadingSoundInstance:Stop(true)
    mDemoLoadingSoundInstance = nil
  end
  if not IsNull(hudInstance) then
    hudInstance:Execute("SetHudAlpha", 100)
  end
  movie:Close()
  startFade = false
end
function Update(movie)
  if gClient == nil then
    return
  end
  if mFrozen then
    return
  end
  if IsNull(gRegion) then
    return
  end
  local t = gClient:GetProgressText()
  if prevText ~= t then
    prevText = t
    movie:SetLocalized("Task.text", t)
  end
  local progressPercent = gClient:GetProgressPercent()
  local frame = 1 + progressPercent * 100
  if 1 <= Abs(frame - prevFrame) then
    prevFrame = frame
  end
  local havePlayer = false
  local humanPlayers = gRegion:GetHumanPlayers()
  if not IsNull(humanPlayers) then
    havePlayer = 0 < #humanPlayers
  end
  if havePlayer and IsNull(hudInstance) and not startFade then
    hudInstance = gFlashMgr:FindMovie(hudMovie)
    if IsNull(hudInstance) then
      hudInstance = gFlashMgr:FindMovie(lobbyHudMovie)
    end
    if not IsNull(hudInstance) then
      hudInstance:Execute("SetHudAlpha", 0)
    end
  end
  local wasFading = startFade
  if not gCmdLine:Applet() and not movie:IsPlaying() and havePlayer and 0 < progressPercent and gClient:IsLevelReady() then
    startFade = true
    fadeTimer = 1
  end
  if IsNull(gRegion) or not gRegion:IsLoadingVideoPlaying() then
    if startFade then
      if not wasFading then
        print("Starting Vignette close animation...")
        movie:SetLocalized("Task.text", "")
        movie:GotoLabeledFrame("CloseAnim")
        movie:Play()
      end
      fadeTimer = fadeTimer - fadeRate * DeltaTime()
      local a = Clamp(fadeTimer, 0, 1)
      movie:SetVariable("Progress._alpha", a * 100)
      movie:SetVariable("Hint._alpha", a * 100)
      if tintColor == 1 then
        movie:SetVariable("WhiteBackground._alpha", a * 100)
      end
      movie:SetBackgroundAlpha(a)
      if not IsNull(hudInstance) then
        hudInstance:Execute("SetHudAlpha", (1 - a) * 100)
      end
      if a < 0.01 then
        _Close(movie)
      end
    else
      local delta = RealDeltaTime()
      if not mProgressVisible then
        mProgressDelay = mProgressDelay - delta
        if mProgressDelay < 0 then
          mProgressVisible = true
          mMovieInstance:SetVariable("Progress._visible", mProgressVisible)
        end
      end
      if mCanShowHint then
        if 0 < mHintDelay then
          mHintDelay = mHintDelay - delta
        elseif gClient:IsLoading() then
          mCurrentHintTime = mCurrentHintTime - delta
          if mCurrentHintTime <= 0 then
            local iconType = gFlashMgr:GetInputDeviceIconType()
            local hintTag = ""
            local maxHints = mMaxHints
            if iconType == DIT_PC then
              maxHints = mMaxHints + 1
            end
            local newHintIndex = mCurrentHintIndex
            for i = 1, 100 do
              if tintColor == 0 then
                newHintIndex = RandomInt(1, mMaxHints)
              elseif mIsMultiplayer then
                local tempIndex = RandomInt(1, #mMPWhiteScreenHints)
                newHintIndex = mMPWhiteScreenHints[tempIndex]
              else
                local tempIndex = RandomInt(1, #mSPWhiteScreenHints)
                newHintIndex = mSPWhiteScreenHints[tempIndex]
              end
              if newHintIndex ~= mCurrentHintIndex then
                hintTag = mHintTagPrefix .. tostring(newHintIndex)
                if mIsMultiplayer then
                  for _, value in pairs(mMPNeedAltHints) do
                    if value == newHintIndex then
                      local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
                      if not IsNull(playerProfile) and iconType == DIT_PC then
                        local settings = playerProfile:Settings()
                        if settings:SwapFireButtonsWhenDualWielding() then
                          hintTag = hintTag .. "Alt"
                        end
                      end
                      break
                    end
                  end
                end
                hintTag = movie:GetLocalized(hintTag)
                break
              end
            end
            mCurrentHintIndex = newHintIndex
            mCurrentHintTime = mHintDuration
            movie:SetVariable("Hint.Hint.text", hintTag)
          end
        end
      end
    end
  end
end
function SetLevelName(movie, levelName)
  mLevelName = levelName
  if mLevelName ~= nil and mLevelName ~= "" and not mCanShowHint then
    mCanShowHint = true
    mCurrentHintTime = 0
    mCurrentHintIndex = 0
    if string.find(mLevelName, "TW") ~= nil then
      mHintTagPrefix = "/D2/Language/Menu/MPLoadingHint"
      mIsMultiplayer = true
    end
  end
  for i = 1, #demoLevelNames do
    if mLevelName == demoLevelNames[i] then
      mDemoLoadingSoundInstance = gRegion:PlaySound(demoLoadingSound, Vector(), false)
      mMovieInstance:SetVariable("WhiteBackground._alpha", 100)
      mMovieInstance:SetVariable("Progress._visible", false)
      break
    end
  end
  return 1
end
function Close(movie)
  _Close(movie)
end
