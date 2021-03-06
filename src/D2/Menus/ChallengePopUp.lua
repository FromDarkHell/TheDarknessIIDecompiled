local totalTime = 0
local lastTime = Time()
local mMaxProg = 1
local mCurProg = 1
function SetTitle(movie, title)
  movie:SetLocalized("PopupContainer.Popup.ChallengeName.text", string.format("/D2/Language/Challenges/Challenge_%s_Name", title))
  movie:SetVariable("PopupContainer.Popup.ChallengeIcon._visible", false)
  movie:SetLocalized("PopupContainer.Popup.ChallengeCondition.text", "")
end
local _SetProgress = function(movie, percent)
  percent = tonumber(percent)
  percent = Clamp(percent, -1, 101)
  FlashMethod(movie, "PopupContainer.Popup.ChallengeProgress.gotoAndStop", percent * 1)
  local isFailed = percent < 0
  local isComplete = 100 <= percent
  if isFailed then
    movie:SetLocalized("PopupContainer.Popup.ChallengeCondition.text", "/D2/Language/MPGame/Challenge_Failed")
    movie:SetLocalized("PopupContainer.Popup.ChallengeNum.text", "<CROSSED_OFF>")
  elseif isComplete then
    movie:SetLocalized("PopupContainer.Popup.ChallengeCondition.text", "/D2/Language/MPGame/Challenge_Completed")
    movie:SetLocalized("PopupContainer.Popup.ChallengeNum.text", "<CHECKMARK>")
  else
    movie:SetLocalized("PopupContainer.Popup.ChallengeCondition.text", "")
  end
end
function SetProgress(movie, percent)
  _SetProgress(movie, percent)
end
local function UpdateChallengeNum(movie)
  if mCurProg < 0 or mCurProg >= mMaxProg then
    _SetProgress(movie, mCurProg / mMaxProg * 100)
  else
    movie:SetVariable("PopupContainer.Popup.ChallengeNum.text", string.format("%i/%i", mCurProg, mMaxProg))
  end
end
function SetMax(movie, maxProg)
  mMaxProg = maxProg * 1
  UpdateChallengeNum(movie)
end
function SetCount(movie, cnt)
  mCurProg = cnt * 1
end
function SetIsNew(movie, isNew)
  movie:SetVariable("PopupContainer.Popup.NewChallenge._visible", isNew == "true")
end
function Show(movie)
  FlashMethod(movie, "PopupContainer.gotoAndPlay", "Show")
end
function Close(movie)
  FlashMethod(movie, "PopupContainer.gotoAndPlay", "Hide")
  movie:Close()
end
function SetIsUnlocked(movie, isUnlocked)
  local frameName = "Locked"
  if isUnlocked == "true" then
    frameName = "Unlocked"
  end
  FlashMethod(movie, "PopupContainer.Popup.LockedIcon.gotoAndStop", frameName)
end
function SetIcon(movie, icon)
  FlashMethod(movie, "PopupContainer.Popup.ChallengeIcon.gotoAndStop", icon)
  movie:SetVariable("PopupContainer.Popup.ChallengeIcon._visible", true)
end
function Close(movie)
  movie:Close()
end
