local M = {

    options = {
        { "text_color", COLOR, COLOR_THEME_PRIMARY1 },
    },

    translate = function(name)
        local translations = {
            text_color = "Text Color",
        }
        return translations[name]
    end

}

return M
