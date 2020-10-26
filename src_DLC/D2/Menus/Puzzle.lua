local LIB = require("D2.Menus.SharedLibrary")
local DIMENSIONS_WIDTH = 4
local DIMENSIONS_HEIGHT = 4
local ARROWDIR_Invalid = -1
local ARROWDIR_Up = 0
local ARROWDIR_Right = 1
local ARROWDIR_Down = 2
local ARROWDIR_Left = 3
local chunkSize = 128
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {statusSelect, statusBack}
local mLocalPlayers = {}
local mGridLayout = {}
local mPieceAnimation = {}
local mSelectionIdx = -1
local mIsComplete = false
local oldPostProcessBlur, oldPostProcessBloom, oldPostProcessShakeTime, oldPostProcessShakeStrength, oldPostProcessLightning, oldPostProcessBlur, oldPostProcessFocalDepth
local GetItemMCName = function(baseName, x, y)
  return string.format("%s_Item%dx%d", baseName, x, y)
end
local function FindYFromIndex(index)
  return math.floor(index / DIMENSIONS_WIDTH)
end
local function FindXFromIndex(index)
  return index % DIMENSIONS_WIDTH
end
local function SetSelectionState(movie, x, y, state, arrowDir)
  local mcName = GetItemMCName("StateGrid", x, y)
  movie:SetVariable(string.format("%s.Selected._visible", mcName), state)
  movie:SetVariable(string.format("%s.ArrowLeft._visible", mcName), state and arrowDir == ARROWDIR_Left)
  movie:SetVariable(string.format("%s.ArrowRight._visible", mcName), state and arrowDir == ARROWDIR_Right)
  movie:SetVariable(string.format("%s.ArrowUp._visible", mcName), state and arrowDir == ARROWDIR_Up)
  movie:SetVariable(string.format("%s.ArrowDown._visible", mcName), state and arrowDir == ARROWDIR_Down)
end
local function GetArrowDir(slotIdx)
  local arrowDir = ARROWDIR_Invalid
  if mGridLayout.pieces == nil or #mGridLayout.pieces == 0 then
    return arrowDir
  end
  local curLocation = slotIdx - 1
  local curX = FindXFromIndex(curLocation)
  local curY = FindYFromIndex(curLocation)
  if curY == FindYFromIndex(curLocation - 1) and mGridLayout.pieces[slotIdx - 1] == 0 then
    arrowDir = ARROWDIR_Left
  elseif curY == FindYFromIndex(curLocation + 1) and mGridLayout.pieces[slotIdx + 1] == 0 then
    arrowDir = ARROWDIR_Right
  elseif curX == FindXFromIndex(curLocation - DIMENSIONS_HEIGHT) and mGridLayout.pieces[slotIdx - DIMENSIONS_HEIGHT] == 0 then
    arrowDir = ARROWDIR_Up
  elseif curX == FindXFromIndex(curLocation + DIMENSIONS_HEIGHT) and mGridLayout.pieces[slotIdx + DIMENSIONS_HEIGHT] == 0 then
    arrowDir = ARROWDIR_Down
  end
  return arrowDir
end
local function UnselectAll(movie)
  for ny = 1, DIMENSIONS_HEIGHT do
    for nx = 1, DIMENSIONS_WIDTH do
      SetSelectionState(movie, nx - 1, ny - 1, false)
    end
  end
end
function StateGridItemSelected(movie, arg)
  local slotIdx = tonumber(arg) + 1
  local x = FindXFromIndex(slotIdx - 1)
  local y = FindYFromIndex(slotIdx - 1)
  local arrowDir = GetArrowDir(slotIdx)
  UnselectAll(movie)
  SetSelectionState(movie, x, y, true, arrowDir)
  mSelectionIdx = slotIdx - 1
end
function StateGridItemUnselected(movie, arg)
  local slotIdx = tonumber(arg)
  local x = FindXFromIndex(slotIdx)
  local y = FindYFromIndex(slotIdx)
  SetSelectionState(movie, x, y, false, ARROWDIR_Invalid)
  mSelectionIdx = -1
end
local AdjustImagePart = function(movie, itemName, newX, newY)
  movie:SetVariable(string.format("%s.PuzzleImage._x", itemName), newX)
  movie:SetVariable(string.format("%s.PuzzleImage._y", itemName), newY)
end
local function RestorePostProcess()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  postProcess.bloom = oldPostProcessBloom
  postProcess.viewShake.mShakeTime = oldPostProcessShakeTime
  postProcess.viewShake.mShakeStrength = oldPostProcessShakeStrength
  postProcess.lightning = oldPostProcessLightning
  postProcess.blur = oldPostProcessBlur
  postProcess.focalDepth = oldPostProcessFocalDepth
end
local function SavePostProcess()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  oldPostProcessBloom = postProcess.bloom
  oldPostProcessShakeTime = postProcess.viewShake.mShakeTime
  oldPostProcessShakeStrength = postProcess.viewShake.mShakeStrength
  oldPostProcessLightning = postProcess.lightning
  oldPostProcessBlur = postProcess.blur
  oldPostProcessFocalDepth = postProcess.focalDepth
  postProcess.blur = 1
  postProcess.focalDepth = 0
end
local function Back(movie)
  RestorePostProcess()
  movie:Close()
end
function StateGridItemPressed(movie, arg)
  if mIsComplete then
    Back(movie)
  end
  if mPieceAnimation.state ~= 0 then
    return
  end
  local arrowDir = GetArrowDir(mSelectionIdx + 1)
  if arrowDir == ARROWDIR_Invalid then
    return
  end
  local x = FindXFromIndex(mSelectionIdx)
  local y = FindYFromIndex(mSelectionIdx)
  SetSelectionState(movie, x, y, true, ARROWDIR_Invalid)
  local mcName = GetItemMCName("ImageGrid", x, y)
  movie:SetVariable(string.format("%s._visible", mcName), false)
  local mcx = movie:GetVariable(string.format("%s._x", mcName))
  local mcy = movie:GetVariable(string.format("%s._y", mcName))
  local px = movie:GetVariable(string.format("%s.PuzzleImage._x", mcName))
  local py = movie:GetVariable(string.format("%s.PuzzleImage._y", mcName))
  movie:SetVariable("ImageTemplate._x", mcx)
  movie:SetVariable("ImageTemplate._y", mcy)
  AdjustImagePart(movie, "ImageTemplate", px, py)
  movie:SetVariable("ImageTemplate._visible", true)
  mPieceAnimation.state = 1
  mPieceAnimation.swapSlotIdx = mSelectionIdx + 1
  mPieceAnimation.incX = 0
  mPieceAnimation.incY = 0
  if arrowDir == ARROWDIR_Left then
    mPieceAnimation.incX = -1
  elseif arrowDir == ARROWDIR_Right then
    mPieceAnimation.incX = 1
  elseif arrowDir == ARROWDIR_Up then
    mPieceAnimation.incY = -1
  elseif arrowDir == ARROWDIR_Down then
    mPieceAnimation.incY = 1
  end
  mPieceAnimation.destinationX = mcx + mPieceAnimation.incX * chunkSize
  mPieceAnimation.destinationY = mcy + mPieceAnimation.incY * chunkSize
end
local function GeneratePuzzle()
  mGridLayout = {
    pieces = {}
  }
  local index = 0
  for y = 1, 4 do
    for x = 1, 4 do
      mGridLayout.pieces[index + 1] = index
      index = index + 1
    end
  end
  local totalBlocks = DIMENSIONS_WIDTH * DIMENSIONS_HEIGHT
  local maxIter = 1500
  for i = 1, maxIter do
    local a = math.floor(Random(1, totalBlocks))
    local b = math.floor(Random(1, totalBlocks))
    local temp = mGridLayout.pieces[a]
    mGridLayout.pieces[a] = mGridLayout.pieces[b]
    mGridLayout.pieces[b] = temp
  end
end
local function DisplayPuzzle(movie)
  local index = 0
  for y = 1, DIMENSIONS_HEIGHT do
    for x = 1, DIMENSIONS_WIDTH do
      local thisPiece = mGridLayout.pieces[index + 1]
      local pieceX = FindXFromIndex(thisPiece)
      local pieceY = FindYFromIndex(thisPiece)
      local newX = pieceX * -chunkSize
      local newY = pieceY * -chunkSize
      local itemName = GetItemMCName("ImageGrid", x - 1, y - 1)
      AdjustImagePart(movie, itemName, newX, newY)
      FlashMethod(movie, "StateGrid.GridClass.SetItemVisible", x - 1, y - 1, true)
      FlashMethod(movie, "ImageGrid.GridClass.SetItemVisible", x - 1, y - 1, thisPiece ~= 0)
      index = index + 1
    end
  end
end
local function InitializeGrid(movie)
  FlashMethod(movie, "StateGrid.GridClass.SetDimensions", DIMENSIONS_WIDTH, DIMENSIONS_HEIGHT)
  FlashMethod(movie, "StateGrid.GridClass.SetClipDimensions", DIMENSIONS_WIDTH + 1, DIMENSIONS_HEIGHT + 1)
  FlashMethod(movie, "ImageGrid.GridClass.SetDimensions", DIMENSIONS_WIDTH, DIMENSIONS_HEIGHT)
  FlashMethod(movie, "ImageGrid.GridClass.SetClipDimensions", DIMENSIONS_WIDTH + 1, DIMENSIONS_HEIGHT + 1)
  local index = 0
  for y = 1, DIMENSIONS_HEIGHT do
    for x = 1, DIMENSIONS_WIDTH do
      FlashMethod(movie, "StateGrid.GridClass.SetItem", x - 1, y - 1, "StateTemplate")
      FlashMethod(movie, "ImageGrid.GridClass.SetItem", x - 1, y - 1, "ImageTemplate")
      FlashMethod(movie, "StateGrid.GridClass.SetItemVisible", x - 1, y - 1, true)
      FlashMethod(movie, "ImageGrid.GridClass.SetItemVisible", x - 1, y - 1, true)
      movie:SetVariable("ImageGrid.GridClass.SetEnabled", false)
      SetSelectionState(movie, x - 1, y - 1, false, ARROWDIR_Invalid)
    end
  end
  FlashMethod(movie, "ImageGrid.GridClass.SetItemDimensions", chunkSize, chunkSize)
  FlashMethod(movie, "StateGrid.GridClass.SetItemDimensions", chunkSize, chunkSize)
  FlashMethod(movie, "StateGrid.GridClass.SetCallbackSelected", "StateGridItemSelected")
  FlashMethod(movie, "StateGrid.GridClass.SetCallbackUnselected", "StateGridItemUnselected")
  FlashMethod(movie, "StateGrid.GridClass.SetCallbackPressed", "StateGridItemPressed")
  FlashMethod(movie, "StateGrid.GridClass.Selected", 0)
  movie:SetVariable("ImageTemplate._visible", false)
  movie:SetVariable("StateTemplate._visible", false)
end
function Initialize(movie)
  mPieceAnimation = {
    state = 0,
    moveRate = chunkSize * 2,
    destinationX = -1,
    destinationY = -1,
    incX = tonumber(0),
    incY = tonumber(0),
    swapSlotIdx = -1
  }
  FlashMethod(movie, "MenuBackgroundClip.gotoAndStop", "LoadoutMenuPosition")
  movie:SetVariable("MenuBackgroundClip.CityBackground._visible", false)
  GeneratePuzzle()
  InitializeGrid(movie)
  DisplayPuzzle(movie)
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], true)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  SavePostProcess()
end
local function CheckForCompletion(movie)
  if mIsComplete then
    return
  end
  local complete = true
  local totalBlocks = DIMENSIONS_WIDTH * DIMENSIONS_HEIGHT
  for i = 1, totalBlocks do
    if mGridLayout.pieces[i] ~= i - 1 then
      complete = false
      break
    end
  end
  if complete then
    RestorePostProcess()
    movie:SetLocalized("Congrats.text", "/D2/Language/Menu/Puzzle_Congrats")
    FlashMethod(movie, "Head.gotoAndStop", 1)
    FlashMethod(movie, "Ink1.gotoAndStop", 1)
    FlashMethod(movie, "Ink2.gotoAndStop", 1)
    for y = 1, DIMENSIONS_HEIGHT do
      for x = 1, DIMENSIONS_WIDTH do
        SetSelectionState(movie, x - 1, y - 1, true, ARROWDIR_Invalid)
      end
    end
  end
  mIsComplete = complete
end
local function UpdatePieceAnimation(movie, rt)
  if mPieceAnimation.state == 0 then
    return
  end
  if mPieceAnimation.incX ~= nil and mPieceAnimation.incX ~= 0 then
    local x = movie:GetVariable("ImageTemplate._x")
    x = x + mPieceAnimation.incX * mPieceAnimation.moveRate * rt
    movie:SetVariable("ImageTemplate._x", x)
    local rx = math.floor(x)
    if 0 < mPieceAnimation.incX and rx >= mPieceAnimation.destinationX or 0 > mPieceAnimation.incX and rx <= mPieceAnimation.destinationX then
      mPieceAnimation.state = 0
    end
  end
  if mPieceAnimation.incY ~= nil and mPieceAnimation.incY ~= 0 then
    local y = movie:GetVariable("ImageTemplate._y")
    y = y + mPieceAnimation.incY * mPieceAnimation.moveRate * rt
    movie:SetVariable("ImageTemplate._y", y)
    local ry = math.floor(y)
    if 0 < mPieceAnimation.incY and ry >= mPieceAnimation.destinationY or 0 > mPieceAnimation.incY and ry <= mPieceAnimation.destinationY then
      mPieceAnimation.state = 0
    end
  end
  if mPieceAnimation.state == 0 then
    movie:SetVariable("ImageTemplate._visible", false)
    local oldIdx = mPieceAnimation.swapSlotIdx
    local newIdx = mPieceAnimation.swapSlotIdx + mPieceAnimation.incX + mPieceAnimation.incY * DIMENSIONS_WIDTH
    local temp = mGridLayout.pieces[oldIdx]
    mGridLayout.pieces[oldIdx] = mGridLayout.pieces[newIdx]
    mGridLayout.pieces[newIdx] = temp
    DisplayPuzzle(movie)
    CheckForCompletion(movie)
  end
end
local v = 1
local d = 1
local function UpdateMindMess(rt)
  v = v + Random(0, 1) * d
  if 50 < v or v < 1 then
    d = -d
  end
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  postProcess.blur = 1
  postProcess.bloom = v
  postProcess.viewShake.mShakeTime = 10
  postProcess.viewShake.mShakeStrength = 50
  postProcess.lightning = true
end
function Update(movie)
  local rt = RealDeltaTime()
  UpdatePieceAnimation(movie, rt)
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusBack then
    Back(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
  return true
end
local function MoveHighlight(movie, x, y)
  if mIsComplete then
    return false
  end
  if mSelectionIdx ~= -1 then
    local myX = FindXFromIndex(mSelectionIdx)
    local myY = FindYFromIndex(mSelectionIdx)
    myX = Clamp(myX + x, 0, DIMENSIONS_WIDTH - 1)
    myY = Clamp(myY + y, 0, DIMENSIONS_HEIGHT - 1)
    UnselectAll(movie)
    local newIdx = myY * DIMENSIONS_WIDTH + myX
    mSelectionIdx = newIdx
    print(string.format("x=%i, y=%i, idx=%i", myX, myY, newIdx))
    local arrowDir = GetArrowDir(newIdx + 1)
    SetSelectionState(movie, myX, myY, true, arrowDir)
    FlashMethod(movie, "StateGrid.GridClass.SetSelected", newIdx)
    return true
  end
  return false
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return false
end
function onKeyDown_MENU_RIGHT(movie)
  return MoveHighlight(movie, 1, 0)
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return false
end
function onKeyDown_MENU_LEFT(movie)
  return MoveHighlight(movie, -1, 0)
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  return false
end
function onKeyDown_MENU_UP(movie)
  return MoveHighlight(movie, 0, -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  return false
end
function onKeyDown_MENU_DOWN(movie)
  if mIsComplete then
    return false
  end
  return MoveHighlight(movie, 0, 1)
end
