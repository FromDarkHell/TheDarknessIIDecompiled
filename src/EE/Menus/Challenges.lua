local mRemapList = {0}
local itemList = {" "}
local mLocalPlayers
function Initialize(movie)
  if Engine.GetMatchingService():GetState() == 0 then
    mLocalPlayers = gRegion:GetHumanPlayers()
  else
    mLocalPlayers = gRegion:ScriptGetLocalPlayers()
  end
  FlashMethod(movie, "InitScreen", "/EE_Menus/Challenges_Title", "/EE_Menus/Challenges_Description", "/EE_Menus/Challenges_Reward", "/EE_Menus/Challenges_Progress")
  local numChallenges = 0
  if gChallengeMgr ~= nil then
    numChallenges = gChallengeMgr:GetNumChallenges()
  end
  local index = 1
  for i = 1, numChallenges + 1 do
    mRemapList[i] = i
  end
  for i = 1, numChallenges do
    local thisChallenge = gChallengeMgr:GetChallengeByIndex(i - 1)
    itemList[i] = ""
    if thisChallenge ~= nil and thisChallenge:IsHidden() ~= true then
      itemList[index] = thisChallenge:GetName()
      FlashMethod(movie, "OptionList.ListClass.AddItem", string.format("/EE_Menus/Challenge_%s_Name", itemList[index]), false)
      mRemapList[index] = i
      index = index + 1
    end
  end
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "left")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Challenges_Clear")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Back")
end
function onKeyDown_MENU_GENERIC1(movie)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if playerProfile ~= nil then
    playerProfile:TestingClearChallengeHistory()
  end
end
function onKeyDown_MENU_CANCEL(movie)
  movie:Close()
end
local Scroll = function(movie, dir)
  local curScrollPos = tonumber(movie:GetVariable("OptionList.ListClass.mScrollPos"))
  local curSelection = tonumber(movie:GetVariable("OptionList.ListClass.mCurrentSelection"))
  local numLabels = tonumber(movie:GetVariable("OptionList.ListClass.numLabels"))
  local numElements = tonumber(movie:GetVariable("OptionList.ListClass.numElements"))
  local maxSize = math.min(numLabels, numElements)
  if dir == -1 then
    if curSelection == 0 then
      if 0 < curScrollPos then
        FlashMethod(movie, "OptionList.ListClass.ScrollUp")
      end
      return true
    end
  elseif dir == 1 and maxSize <= curSelection + 1 then
    FlashMethod(movie, "OptionList.ListClass.ScrollDown")
    return true
  end
  return false
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  return Scroll(movie, -1)
end
function onKeyDown_MENU_UP(movie)
  return Scroll(movie, -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  local r = Scroll(movie, 1)
  return r
end
function onKeyDown_MENU_DOWN(movie)
  local r = Scroll(movie, 1)
  return r
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return 1
end
function onKeyDown_MENU_LEFT(movie)
  return 1
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return 1
end
function onKeyDown_MENU_RIGHT(movie)
  return 1
end
function ListButtonSelected(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  local thisChallenge = gChallengeMgr:GetChallengeByIndex(mRemapList[index] - 1)
  if thisChallenge ~= nil and thisChallenge:IsHidden() ~= true then
    local progressCurText = ""
    local progressMidText = "/"
    local progressMaxText = ""
    local rewardText = ""
    local descriptionText = ""
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    if playerProfile ~= nil then
      local curProgress = playerProfile:GetChallengeProgress(thisChallenge:GetFullName())
      local maxProgress = thisChallenge:GetRequiredCount()
      progressCurText = curProgress
      progressMaxText = maxProgress
      rewardText = thisChallenge:GetXPReward()
      descriptionText = string.format("/EE_Menus/Challenge_%s_Description", itemList[index])
    end
    FlashMethod(movie, "Selected", tonumber(buttonArg), descriptionText, progressCurText, progressMidText, progressMaxText, rewardText)
  end
end
