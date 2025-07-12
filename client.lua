local BIND_KEY = "num_add"
local MODIFIER_KEY = "lshift" 


local isActive = false
local objectInfo = nil
local lastCopyTime = 0


local screenWidth, screenHeight = guiGetScreenSize()
local slideAnimation = 0
local infoAlpha = 0


local function toggleMOC()
    isActive = not isActive
    if isActive then
        
        objectInfo = { status = "MOC ACTIVE - Click an object, ped or vehicle to copy data." }
        infoAlpha = 255
        slideAnimation = 0
        lastCopyTime = 0
        outputChatBox("#606efc[MOC] #00ff00Activated - Click objects, peds or vehicles to copy data.", 255, 255, 255, true)
    else
        
        outputChatBox("#606efc[MOC] #ff0000Deactivated.", 255, 255, 255, true)
    end
end


bindKey(BIND_KEY, "down", function()
    if getKeyState(MODIFIER_KEY) or getKeyState("rshift") then
        toggleMOC()
    end
end)


addEvent("onClientElementSelect", true)


addEventHandler("onClientElementSelect", root, function()
    
    if not isActive or not isCursorShowing() then
        return
    end

    
    local clickedElement = source

    
    if not isElement(clickedElement) then
        return
    end

    local elemType = getElementType(clickedElement)
    
    
    if elemType ~= "object" and elemType ~= "ped" and elemType ~= "vehicle" then
        return
    end

    local x, y, z = getElementPosition(clickedElement)
    local rx, ry, rz = getElementRotation(clickedElement)
    local model = getElementModel(clickedElement)

    
    if x and y and z and rx and ry and rz and model then
        objectInfo = {
            status = "copied",
            model = tostring(model),
            pos = string.format("%.2f, %.2f, %.2f", x, y, z),
            rot = string.format("%.2f, %.2f, %.2f", rx, ry, rz),
            type = tostring(elemType)
        }
        
        
        local clipboardText = string.format("%s, %s, %s", objectInfo.model, objectInfo.pos, objectInfo.rot)
        setClipboard(clipboardText)
        
        
        lastCopyTime = getTickCount()
        infoAlpha = 255
        slideAnimation = 0
        outputChatBox("#606efc[MOC] #00ff00Copied data for " .. elemType .. " (Model: " .. objectInfo.model .. ")", 255, 255, 255, true)
    end
end)


addEventHandler("onClientRender", root, function()
    local currentTime = getTickCount()
    
    
    if slideAnimation < 1 then slideAnimation = slideAnimation + 0.05 end

    
    if not isActive then
        if infoAlpha > 0 then infoAlpha = infoAlpha - 10 end
    end

    
    if objectInfo and objectInfo.status == "copied" then
        if currentTime - lastCopyTime > 5000 then
            infoAlpha = infoAlpha - 10
            if infoAlpha <= 0 then
                objectInfo = { status = "MOC ACTIVE - Click an object, ped or vehicle to copy data." }
                infoAlpha = 255 
            end
        end
    end

    
    if infoAlpha > 0 and objectInfo and isCursorShowing() then
        local panelW, panelH = 380, 160
        local panelX, panelY = screenWidth - panelW - 30, screenHeight - panelH - 30
        local animatedX = panelX + (panelW * (1 - slideAnimation))
        local currentAlpha = math.floor(infoAlpha)

        
        dxDrawRectangle(animatedX, panelY, panelW, panelH, tocolor(20, 22, 25, math.floor(200 * (currentAlpha / 255))))
        dxDrawRectangle(animatedX, panelY, panelW, 3, tocolor(0, 255, 136, currentAlpha)) 

        
        dxDrawText("OBJECT INFORMATION", animatedX + 20, panelY + 15, animatedX + panelW, panelY + 35, tocolor(255, 255, 255, currentAlpha), 1.0, "default-bold")
        
        local textY = panelY + 50
        local spacing = 20
        
        dxDrawText("Type:", animatedX + 20, textY, 0, 0, tocolor(200, 200, 200, currentAlpha), 0.9, "default")
        dxDrawText(tostring(objectInfo.type or "N/A"), animatedX + 120, textY, 0, 0, tocolor(255, 255, 255, currentAlpha), 0.9, "default-bold")
        textY = textY + spacing

        dxDrawText("Model ID:", animatedX + 20, textY, 0, 0, tocolor(200, 200, 200, currentAlpha), 0.9, "default")
        dxDrawText(tostring(objectInfo.model or "N/A"), animatedX + 120, textY, 0, 0, tocolor(255, 255, 255, currentAlpha), 0.9, "default-bold")
        textY = textY + spacing

        dxDrawText("Position:", animatedX + 20, textY, 0, 0, tocolor(200, 200, 200, currentAlpha), 0.9, "default")
        dxDrawText(tostring(objectInfo.pos or "N/A"), animatedX + 120, textY, 0, 0, tocolor(255, 255, 255, currentAlpha), 0.9, "default-bold")
        textY = textY + spacing

        dxDrawText("Rotation:", animatedX + 20, textY, 0, 0, tocolor(200, 200, 200, currentAlpha), 0.9, "default")
        dxDrawText(tostring(objectInfo.rot or "N/A"), animatedX + 120, textY, 0, 0, tocolor(255, 255, 255, currentAlpha), 0.9, "default-bold")
        textY = textY + spacing

        if objectInfo.status == "copied" then
            dxDrawText("Copied to clipboard!", animatedX + 20, textY + 5, 0, 0, tocolor(0, 255, 136, currentAlpha), 0.9, "default-bold")
        end
    end
end)


local mocVersion = "N/A"

addEvent("receiveVersion", true)
addEventHandler("receiveVersion", root, function(version)
    mocVersion = tostring(version or "N/A")
    outputChatBox("#606efc[MOC] #ffffffMagic Object Copier Loaded", 255, 255, 255, true)
    outputChatBox("#606efc[MOC] #ffffffVersion: #606efc" .. mocVersion, 255, 255, 255, true)
    outputChatBox("#606efc[MOC] #ffffffAuthor: #888888LIWA", 255, 255, 255, true)
    outputChatBox("#606efc[MOC] #ffffffPress #606efcShift and + #ffffffto toggle MOC ON/OFF.", 255, 255, 255, true)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("getVersion", localPlayer)
end)


