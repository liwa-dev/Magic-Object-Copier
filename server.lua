function readLocalVersion()
    if fileExists("version.txt") then
        local file = fileOpen("version.txt")
        if file then
            local size = fileGetSize(file)
            local content = fileRead(file, size)
            fileClose(file)
            content = content:gsub("^%s*(.-)%s*$", "%1")
            return content
        end
    end
    return nil
end

local currentVersion = readLocalVersion()


local baseURL =
    "https://raw.githubusercontent.com/liwa-dev/Magic-Object-Copier/main/"

function updateFiles()
    local files = {"server.lua", "meta.xml", "client.xml", "version.txt"}

    for _, filename in ipairs(files) do
        fetchRemote(baseURL .. filename, function(data, errorCode)
            if errorCode == 0 then
                if fileExists(filename) then fileDelete(filename) end
                local file = fileCreate(filename)
                if file then
                    fileWrite(file, data)
                    fileClose(file)
                    print("Updated " .. filename)
                else
                    print("Failed to create " .. filename)
                end
            else
                print("Failed to download " .. filename)
            end
        end)
    end

    setTimer(function()
        if hasObjectPermissionTo(getThisResource(), "function.restartResource", false) then
            restartResource(getThisResource())
            outputChatBox("MOC: Resource updated and will restart now.", root, 255,0, 0)
        else
            outputChatBox(
                "MOC: Failed to restart resource. Please do manually restart the resource.",
                root, 255, 0, 0)
            outputChatBox("MOC: Please run: /aclrequest allow moc all", root, 255, 0, 0)
        end
    end, 3000, 1)
end

function checkForUpdatesManual(player)
    
    if hasObjectPermissionTo(getThisResource(), "function.fetchRemote", false) then
        fetchRemote(baseURL .. "version.txt", function(response, errorCode)
            if errorCode == 0 then
                response = response:gsub("^%s*(.-)%s*$", "%1")
                print("Current version: " .. currentVersion)
                print("Remote version: " .. response)
                if response ~= currentVersion then
                    outputChatBox(
                        "MOC: New version detected! Updating... Please wait",
                        player, 0, 255, 0)
                    updateFiles()
                else
                    outputChatBox("MOC: You are running the latest version.",
                                  player, 0, 255, 0)
                end
            else
                outputServerLog(
                    "MOC: Failed to check for updates. Error code: " ..
                        tostring(errorCode))
            end
        end)
    else
        outputChatBox(
            "MOC: Failed to check for updates. Please run: /aclrequest allow moc all",
            player, 255, 0, 0)
    end
end

addCommandHandler("updatemoc", checkForUpdatesManual)

addEventHandler("onResourceStart", resourceRoot,function() checkForUpdatesManual(root) end)

addEvent("getVersion", true)
addEventHandler("getVersion", root, function()
    triggerClientEvent(source, "receiveVersion", source, currentVersion)
end)