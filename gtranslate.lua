local mod = {}
mod.APIKEY = ""

-- gtranslate
function mod.gtranslate()
    if mod.APIKEY == "" then
        hs.alert('You must enter your Google Cloud API KEY')
        return
    end

    local GOOGLE_ENDPOINT = 'https://www.googleapis.com/language/translate/v2?target=%s&source=%s&key=%s&q=%s'
    local API_KEY = mod.APIKEY
    local target = mod.target
    local source = mod.source

    local alerts = {}

    local current = hs.application.frontmostApplication()
    local tab = nil
    local copy = nil
    local t = nil
    local choices = {}

    local chooser = hs.chooser.new(function(choosen)
        if copy then copy:delete() end
        if tab then tab:delete() end
        if t then t:delete() end
        current:activate()
        hs.eventtap.keyStrokes(choosen.text)
    end)

    -- Removes all items in list
    function reset()
        chooser:choices({})
    end

    function setLang(so, ta)
        source = so
        target = ta

        local style = {}

        hs.alert.closeSpecific( alerts["langPrimary"], 0 )
        hs.alert.closeSpecific( alerts["langSecondary"], 0 )

        alerts["langPrimary"] = hs.alert.show( string.format('%s ⇢ %s', string.upper(source), string.upper(target)), { ["textSize"] = 50 }, 2 )
        alerts["langSecondary"] = hs.alert.show( '⌘T to switch.', 2 )
    end

    tab = hs.hotkey.bind('', 'tab', function()
        local id = chooser:selectedRow()
        local item = choices[id]
        -- If no row is selected, but tab was pressed
        if not item then return end
        chooser:query(item.subText)
        reset()
        updateChooser()
    end)

    t = hs.hotkey.bind('cmd', 't', function()
        setLang(target, source)
        reset()
    end)

    copy = hs.hotkey.bind('cmd', 'c', function()
        local id = chooser:selectedRow()
        local item = choices[id]
        if item then
            chooser:hide()
            hs.pasteboard.setContents(item.text)
            hs.alert.show("Copied to clipboard", 1)
        else
            hs.alert.show("No search result to copy", 1)
        end
    end)


    function updateChooser()
        local string = chooser:query()
        local query = hs.http.encodeForQuery(string)
        -- Reset list when no query is given
        if string:len() == 0 then return reset() end

        hs.http.asyncGet(string.format(GOOGLE_ENDPOINT, target, source, API_KEY, query), nil, function(status, data)
            if not data then return end

            local ok, results = pcall(function() return hs.json.decode(data) end)
            if not ok then return end

            hs.fnutils.each( results["data"]["translations"], function(result)
                local translation = result["translatedText"]
                if string == translation then return end

                local choice = {
                    ["text"] = translation,
                    ["subText"] = string,
                }

                local found = hs.fnutils.find( choices, function( element )
                    return element["text"] == translation
                end)

                if found == nil then table.insert(choices, 1, choice) end
            end)

            hs.printf( hs.inspect(choices) )

            chooser:choices(choices)
        end)
    end

    chooser:queryChangedCallback(updateChooser)

    chooser:searchSubText(false)

    chooser:show()
    setLang(source, target)

end

function mod.init( APIKEY, source, target, mods, key )
    mod.APIKEY = APIKEY
    mod.source = source or "fi"
    mod.target = target or "en"

    mods = mods or {"cmd", "alt", "ctrl"}
    key = key or "T"
    hs.hotkey.bind(mods, key, mod.gtranslate)
end

return mod
