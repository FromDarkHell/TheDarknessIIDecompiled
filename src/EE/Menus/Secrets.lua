qaMenu = Resource()
visModesMenu = Resource()
statsMenu = Resource()
local LIST_CATEGORIES = 0
local LIST_SUBLIST = 1
local ITEM_TYPE_STD_BTN = 1
local ITEM_TYPE_TOGGLE_BTN = 2
local ITEM_TYPE_SEPARATOR = 3
local catList
local focusedList = 0
local tabAmount = 3
local createList = function(name, flashListName)
  local getCount = function(this)
    return table.getn(this.items)
  end
  local list = {
    name = name,
    flashListName = flashListName,
    visibleItems = 12,
    scrollPos = 0,
    selected = 1,
    items = {},
    count = getCount,
    onValidate = nil,
    onScroll = nil,
    onFocused = nil,
    onPress = nil
  }
  return list
end
local function createItem(itemName, itemValue, itemType, callback, userData)
  if itemType == nil then
    itemType = ITEM_TYPE_STD_BTN
  end
  local selectable = true
  if itemType == ITEM_TYPE_SEPARATOR then
    selectable = false
  end
  local item = {
    name = itemName,
    value = itemValue,
    type = itemType,
    callback = callback,
    usrData = userData,
    selectable = selectable
  }
  return item
end
local function addItem(list, itemName, itemValue, itemType, callback, userData)
  table.insert(list.items, createItem(itemName, itemValue, itemType, callback, userData))
end
local strsplit = function(text, delimiter)
  local list = {}
  local pos = 1
  if string.find("", delimiter, 1, true) then
    table.insert(list, 1, text)
    return list
  end
  while true do
    local first, last = string.find(text, delimiter, pos, true)
    if first then
      table.insert(list, string.sub(text, pos, first - 1, true))
      pos = last + 1
    else
      table.insert(list, string.sub(text, pos))
      break
    end
  end
  return list
end
local toggleConfig = function(this, movie, list)
  this.value = not this.value
  local cVar = this.usrData
  local v = this.value
  gFlashMgr:SetConfigBool(cVar, v)
end
local runToolCmd = function(this, movie, list)
  local tool = this.usrData
  local fullName = tool:GetFullName()
  local val = gFlashMgr:IsToolMenuSelected(tool)
  gFlashMgr:ExecuteToolMenuCommand(tool)
  val = gFlashMgr:IsToolMenuSelected(tool)
  this.value = val
end
local toggleStat = function(this, movie, list)
  local index = this.usrData
  local statMgr = Script.GetStatsMgr()
  local statGroups = statMgr:GetGroups()
  local statName = statGroups[index]:GetName()
  local statIsVisible = not statGroups[index]:IsVisible()
  statMgr:SetGroupVisibility(statName, statIsVisible)
  this.value = statIsVisible
end
local restartLevelAtCheckPoint = function(this, movie, list)
  local cp = this.usrData
  cp:RestartLevel()
end
local function loadStats(movie)
  local statMgr = Script.GetStatsMgr()
  local statGroups = statMgr:GetGroups()
  local statList = createList("Stat Groups", "subList")
  addItem(statList, "ShowStats", gFlashMgr:GetConfigBool("Stats.ShowStats"), ITEM_TYPE_TOGGLE_BTN, toggleConfig, "Stats.ShowStats")
  addItem(statList, "-", false, ITEM_TYPE_SEPARATOR)
  for i = 1, #statGroups do
    local n = statGroups[i]:GetName()
    local v = statGroups[i]:IsVisible()
    addItem(statList, n, v, ITEM_TYPE_TOGGLE_BTN, toggleStat, i)
  end
  addItem(catList, statList.name, statList, ITEM_TYPE_STD_BTN)
end
local function loadCheckPoints(movie)
  local gameRules = gRegion:GetGameRules()
  local checkPoints = gameRules:GetSelectableCheckPoints()
  if checkPoints ~= nil and 0 < #checkPoints then
    local checkPointList = createList("CheckPoints", "subList")
    for i = 1, #checkPoints do
      local name = checkPoints[i]:GetName()
      addItem(checkPointList, name, false, ITEM_TYPE_STD_BTN, restartLevelAtCheckPoint, checkPoints[i])
    end
    addItem(catList, checkPointList.name, checkPointList, ITEM_TYPE_STD_BTN)
  end
end
local function loadConfigs(movie)
  local configs = {}
  local numConfigBool = gFlashMgr:GetNumConfigBool()
  local lastCat = ""
  local catIndex = 0
  for i = 1, numConfigBool do
    local n = gFlashMgr:GetConfigBoolName(i)
    local v = gFlashMgr:GetConfigBool(n)
    local split = strsplit(n, ".")
    if split[2] ~= nil then
      local cat = split[1]
      local itemName = split[2]
      if lastCat ~= cat then
        table.insert(configs, createList(cat))
        lastCat = cat
        catIndex = catIndex + 1
      end
      local configCategory = configs[catIndex]
      addItem(configCategory, itemName, v, ITEM_TYPE_TOGGLE_BTN, toggleConfig, cat .. "." .. itemName)
    end
  end
  return configs
end
local function loadToolMenus(movie, tm)
  local tmType = tm:GetType()
  local tmName = gFlashMgr:GetToolMenuLabel(tm)
  local tmFullName = tm:GetFullName()
  local items = getToolMenuItems(tm)
  local itemCount = table.getn(items)
  local cmds = {}
  for i = 1, itemCount do
    local child = items[i]
    local isMenu
    if child == "-" then
      isMenu = false
    else
      isMenu = gFlashMgr:IsToolMenu(child)
    end
    if isMenu then
      local moreCmds = loadToolMenus(movie, child)
      for j = 1, #moreCmds do
        table.insert(cmds, moreCmds[j])
      end
    else
      local item
      if child == "-" then
        item = createItem("-", false, ITEM_TYPE_SEPARATOR)
      else
        local cmdName = gFlashMgr:GetToolMenuLabel(child)
        local tmSelected = false
        if gFlashMgr:IsToolMenuSelected(child) then
          tmSelected = true
        end
        item = createItem(cmdName, tmSelected, ITEM_TYPE_TOGGLE_BTN, runToolCmd, child)
      end
      table.insert(cmds, item)
    end
  end
  return cmds
end
function getToolMenuItems(tm)
  local cmdCount = gFlashMgr:GetNumToolMenuCommands(tm)
  local items = {}
  for i = 0, cmdCount - 1 do
    local tool = gFlashMgr:GetToolMenuIndex(tm, i)
    if tool == nil then
      tool = "-"
    end
    table.insert(items, tool)
  end
  return items
end
local function loadQA(movie)
  local cfg = {
    "AI.ShowDebug",
    "App.ShowDebugInfo",
    "Client.InfiniteAmmo",
    "Client.GodMode"
  }
  local qaList = createList("QA Fav", "subList")
  local itemCount = #cfg
  for i = 1, itemCount do
    local n = cfg[i]
    local val = gFlashMgr:GetConfigBool(n)
    addItem(qaList, n, val, ITEM_TYPE_TOGGLE_BTN, toggleConfig, n)
  end
  local toolMenus = loadToolMenus(movie, qaMenu)
  for i = 1, #toolMenus do
    table.insert(qaList.items, toolMenus[i])
  end
  addItem(catList, qaList.name, qaList, ITEM_TYPE_STD_BTN)
end
function getDisplayItem(list)
  return list.selected - list.scrollPos
end
local drawList = function(movie, list)
  local flashListName = list.flashListName
  local maxItems = math.min(list.visibleItems, table.getn(list.items))
  local startPos = list.scrollPos + 1
  local pos = 0
  local flashList = "_root." .. flashListName
  local cmd = flashList .. "." .. "clearList"
  FlashMethod(movie, cmd)
  cmd = flashList .. "." .. "setItem"
  for i = startPos, maxItems + startPos - 1 do
    local item = list.items[i]
    FlashMethod(movie, cmd, item.name, pos, item.type, item.value)
    pos = pos + 1
  end
  cmd = flashList .. "." .. "invalidate"
  FlashMethod(movie, cmd)
end
local function focusOnList(movie, list)
  if list == 0 then
    focusedList = 0
    FlashMethod(movie, "_root.showHighlighter", false)
    local displayPos = getDisplayItem(catList)
    FlashMethod(movie, "_root.setSelectorFocus", "categories", displayPos - 1)
    FlashMethod(movie, "_root.clearSubListFocus")
  elseif list == 1 then
    focusedList = 1
    local subList = catList.items[catList.selected].value
    local displayPos = getDisplayItem(subList)
    FlashMethod(movie, "_root.showHighlighter", true)
    FlashMethod(movie, "_root.setItemFocus", displayPos - 1)
    FlashMethod(movie, "_root.setSelectorFocus", "subList", displayPos - 1)
  end
end
local validateScroll = function(movie, list)
  if list.selected > list.scrollPos + list.visibleItems then
    list.scrollPos = list.selected - list.visibleItems
  elseif list.selected <= list.scrollPos then
    list.scrollPos = list.selected - 1
  end
  local showTopArrow = false
  local showBottomArrow = false
  if list.scrollPos > 0 then
    showTopArrow = true
  end
  if list.scrollPos + list.visibleItems < #list.items then
    showBottomArrow = true
  end
  FlashMethod(movie, "_root." .. list.flashListName .. ".setArrowVisible", 0, showTopArrow)
  FlashMethod(movie, "_root." .. list.flashListName .. ".setArrowVisible", 1, showBottomArrow)
end
local function validateList(movie, list)
  validateScroll(movie, list)
  drawList(movie, list)
  if list.onValidate ~= nil then
    list:onValidate()
  end
  if focusedList == 0 then
    local displayPos = getDisplayItem(catList) - 1
    FlashMethod(movie, "_root.setSelectorFocus", "categories", displayPos)
  elseif focusedList == 1 then
    local subList = catList.items[catList.selected].value
    local displayPos = getDisplayItem(subList) - 1
    FlashMethod(movie, "_root.setItemFocus", displayPos)
    FlashMethod(movie, "_root.setSelectorFocus", "subList", displayPos)
  end
end
local function scrollList(movie, count)
  if count == nil or count == 0 then
    return nil
  end
  local list, flashList
  if focusedList == 0 then
    list = catList
    flashList = "categories"
  else
    list = catList.items[catList.selected].value
    flashList = "subList"
  end
  local origSelection = list.selected
  local itemCount = table.getn(list.items)
  local newPos
  newPos = math.abs(list.selected + itemCount + count) - 1
  list.selected = math.mod(newPos, itemCount) + 1
  local counted = 0
  local item = list.selected
  for i = list.selected, itemCount do
    if itemCount < item then
      item = 1
    elseif item < 1 then
      item = itemCount
    end
    counted = counted + 1
    if list.items[item].selectable == true then
      list.selected = item
      break
    elseif counted == itemCount then
      error("This list contains all non-selectable items. Invalid.")
      list.selected = nil
      break
    end
    if 0 < count then
      item = item + 1
    else
      item = item - 1
    end
  end
  validateList(movie, list)
  if list.onScroll then
    list:onScroll(movie)
  end
end
local function onCategoryScrolled(this, movie)
  local itemIndex = getDisplayItem(this)
  FlashMethod(movie, "_root.setSelectedCategory", itemIndex - 1)
  local subList = this.items[this.selected].value
  local displayPos = getDisplayItem(subList) - 1
  validateList(movie, subList)
end
local function onCatListPress(this, movie)
  focusOnList(movie, 1)
end
function onItemClick(movie, itemIndex)
  local itemList = catList.items[catList.selected].value
  itemIndex = itemList.scrollPos + itemIndex + 1
  local item = itemList.items[itemIndex]
  if focusedList ~= 1 then
    itemList.selected = itemIndex
    focusOnList(movie, 1)
  end
  if item.callback ~= nil then
    item:callback(movie, itemList)
  end
end
local function onPress_DOWN(movie)
  scrollList(movie, 1)
end
local function onPress_UP(movie)
  scrollList(movie, -1)
end
local function onPress_LEFT(movie)
  if focusedList == 0 then
    focusOnList(movie, 1)
  else
    focusOnList(movie, 0)
  end
end
local function onPress_RIGHT(movie)
  if focusedList == 0 then
    focusOnList(movie, 1)
  else
    focusOnList(movie, 0)
  end
end
function onKeyDown_MENU_DOWN(movie)
  onPress_DOWN(movie)
  return true
end
function onKeyDown_MENU_UP(movie)
  onPress_UP(movie)
  return true
end
function onKeyDown_MENU_LEFT(movie)
  onPress_LEFT(movie)
  return true
end
function onKeyDown_MENU_RIGHT(movie)
  onPress_RIGHT(movie)
  return true
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  onPress_DOWN(movie)
  return true
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  onPress_UP(movie)
  return true
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  onPress_LEFT(movie)
  return true
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  onPress_RIGHT(movie)
  return true
end
function onKeyDown_MENU_LTRIGGER2(movie)
  scrollList(movie, -3)
  return true
end
function onKeyDown_MENU_RTRIGGER2(movie)
  scrollList(movie, 3)
  return true
end
function onKeyDown_MENU_SELECT(movie)
  print("SELECT")
  local list
  if focusedList == 0 then
    list = catList
  elseif focusedList == 1 then
    list = catList.items[catList.selected].value
  end
  if list.onPress ~= nil then
    list:onPress(movie)
  end
  local item = list.items[list.selected]
  if item.callback ~= nil then
    item:callback(movie, list)
  end
  validateList(movie, list)
  return true
end
function onKeyDown_MENU_CANCEL(movie)
  if focusedList == 0 then
    movie:Close()
  else
    focusOnList(movie, 0)
  end
  return true
end
function onKeyUp_HIDE_PAUSE_MENU(movie)
  movie:Close()
end
function Initialize(movie)
  catList = createList("categories", "categories")
  catList.onScroll = onCategoryScrolled
  catList.onPress = onCatListPress
  loadQA(movie)
  loadStats(movie)
  local toolMenus = loadToolMenus(movie, visModesMenu)
  local visModes = createList("Vis Modes", "subList")
  for i = 1, #toolMenus do
    table.insert(visModes.items, toolMenus[i])
  end
  addItem(catList, "Vis Modes", visModes, ITEM_TYPE_STD_BTN)
  loadCheckPoints(movie)
  addItem(catList, "-", false, ITEM_TYPE_SEPARATOR)
  local configs = loadConfigs(movie)
  for i = 1, table.getn(configs) do
    configs[i].flashListName = "subList"
    addItem(catList, configs[i].name, configs[i], ITEM_TYPE_STD_BTN)
  end
  FlashMethod(movie, "init")
  focusOnList(movie, 0)
  validateList(movie, catList)
  catList:onScroll(movie)
end
