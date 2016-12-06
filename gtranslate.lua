local mod = {}

-- gtranslate
function mod.gtranslate()
    local API_KEY = "AIzaSyCuDQKqJcdE2ZQQqEX2zay3FPlWQ5qB1rc"
    local GOOGLE_ENDPOINT = 'https://www.googleapis.com/language/translate/v2?target=%s&source=%s&key=%s&q=%s'
    local target = "en"
    local source = "fi"

    local current = hs.application.frontmostApplication()
    local tab = nil
    local copy = nil
    local choices = {}

    local chooser = hs.chooser.new(function(choosen)
        if copy then copy:delete() end
        if tab then tab:delete() end
        current:activate()
        hs.eventtap.keyStrokes(choosen.text)
    end)

    -- Removes all items in list
    function reset()
        chooser:choices({})
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
end

function mod.registerDefaultBindings(mods, key)
    mods = mods or {"cmd", "alt", "ctrl"}
    key = key or "T"
    hs.hotkey.bind(mods, key, mod.gtranslate)
end

return mod
