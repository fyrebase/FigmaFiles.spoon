local obj = {}
obj.__index = obj

obj.name = "FigmaFiles"
obj.version = "0.1"
obj.author = "Kirk Bentley <kirk@fyrebase.com>"
obj.apiKey = ""
obj.teamIds = {}
obj.autoUpdate = false
obj.updateCacheInterval = 60 * 60 * 3
obj.darkMode = false

local cacheUpdateTimer
local chooser
local choices = {}
local _items = {}

function getFigmaFiles(apiKey, teamId)
    local projectsUrl = string.format("https://api.figma.com/v1/teams/%s/projects", teamId)

    local headers = {
        ["X-Figma-Token"] = apiKey
    }

    local _, projectsResponse = hs.http.doRequest(projectsUrl, "GET", nil, headers)

    local projectIds = {}
    local projectsData = hs.json.decode(projectsResponse)

    for _, project in ipairs(projectsData.projects) do
        table.insert(projectIds, project.id)
    end

    local files = {}

    for _, projectId in ipairs(projectIds) do
        local filesUrl = string.format("https://api.figma.com/v1/projects/%s/files", projectId)

        local _, filesResponse = hs.http.doRequest(filesUrl, "GET", nil, headers)
        local filesData = hs.json.decode(filesResponse)

        for _, file in ipairs(filesData.files) do
            table.insert(files, {
                title = file.name,
                match = string.gsub(file.name, "[%s-]+", " "),
                arg = "https://www.figma.com/file/" .. file.key
            })
        end
    end

    return files
end

function updateCache(callback)
    local allItems = {}

    for _, teamId in ipairs(obj.teamIds) do
        local items = getFigmaFiles(obj.apiKey, teamId)
        for _, item in ipairs(items) do
            table.insert(allItems, item)
        end
    end

    local cacheFilePath = hs.fs.pathToAbsolute("~") .. "/.figma-file-cache.json"
    local cacheData = {
        items = allItems
    }
    local cacheJSON = hs.json.encode(cacheData, true)

    local file = io.open(cacheFilePath, "w")
    file:write(cacheJSON)
    file:close()

    if callback then
        callback()
    end
end

function loadOrCreateCache()
    local cacheFilePath = hs.fs.pathToAbsolute("~") .. "/.figma-file-cache.json"
    local cacheFile = io.open(cacheFilePath, "r")

    if cacheFile then
        local cacheData = cacheFile:read("*all")
        cacheFile:close()
        local cache = hs.json.decode(cacheData)

        if cache and cache.items then
            return cache.items
        end
    end

    updateCache()

    return {}
end

function filterData(query)
    local filteredItems = {}

    for _, item in ipairs(_items) do
        if string.match(item.title:lower(), query:lower()) then
            table.insert(filteredItems, {
                text = item.title,
                arg = item.arg
            })
        end
    end

    return filteredItems
end

function chooserFilteredUpdate(query)
    choices = {}

    local filteredData = filterData(query)

    for _, item in ipairs(filteredData) do
        table.insert(choices, {
            text = item.text,
            arg = item.arg,
            image = hs.image.imageFromPath(obj.spoonPath .. "figma.png")
        })
    end

    chooser:choices(choices)
end

function updateCacheAndRefreshChooser(cb)
    updateCache(function()
        _items = loadOrCreateCache()
    end)

    if cb then
        cb()
    end
end

function centreMouseScreenPoint(theChooser)
    local defaultWidth = 798
    local defaultHeight = 520

    local currentScreen = hs.mouse.getCurrentScreen()
    local fullFrame =  currentScreen and currentScreen:fullFrame()
    local result = fullFrame.center
    
    if result then
        result.x = result.x - (defaultWidth / 2)
        result.y = result.y - (defaultHeight / 2)
    end

    if type(result) == "table" then
        return result
    else
        log.ef("Failed to generate centreMouseScreenPoint: %s", result)
    end
end

function obj:showChooser()
    chooser:queryChangedCallback(chooserFilteredUpdate)
    chooserFilteredUpdate("")
    chooser:show(centreMouseScreenPoint(chooser))
end

function obj:bindHotKeys(mapping)
    local spec = {
        showFigmaFilesChooser = hs.fnutils.partial(self.showChooser, self)
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)

    return self
end

function obj:start()
    _items = loadOrCreateCache()

    local toolbar = hs.webview.toolbar.new("Figma Files", {{
        id = "updateCache",
        label = "Update Cache",
        image = hs.image.imageFromName("NSTouchBarRefreshTemplate"),
        tooltip = "Refresh Figma Files Cache",
        fn = function()
            updateCacheAndRefreshChooser(function()
                chooser:hide()
                chooser:show()
            end)
        end
    }})
        :toolbarStyle("unifiedCompact")

    chooser = hs.chooser.new(function(selection)
        if not selection then
            return
        end

        hs.execute("open " .. selection.arg)
    end)
        :searchSubText(true)
        :bgDark(obj.darkMode)
        :width(640)
        :placeholderText("Search for a Figma file...")
        :attachedToolbar(toolbar)
        -- :hideCallback(function() chooserCanvas:hide() end)

    cacheUpdateTimer = hs.timer.new(obj.updateCacheInterval, updateCacheAndRefreshChooser)

    if self.autoUpdate then
        cacheUpdateTimer:start()
    end
end

return obj
