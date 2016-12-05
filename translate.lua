hs.hotkey.bind({"cmd", "alt", "ctrl"}, "T", function()
    local API_KEY = "AIzaSyCuDQKqJcdE2ZQQqEX2zay3FPlWQ5qB1rc"
    local GOOGLE_ENDPOINT = 'https://www.googleapis.com/language/translate/v2?target=%s&source=%s&key=%s&q=%s'
    local target = "en"
    local source = "fi"

    local current = hs.application.frontmostApplication()
    local choices = {}

    local chooser = hs.chooser.new(function(choosen)
        current:activate()
        hs.eventtap.keyStrokes(choosen.text)
    end)

    chooser:queryChangedCallback(function(string)
        local query = hs.http.encodeForQuery(string)

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
    end)

    chooser:searchSubText(false)

    chooser:show()
end)