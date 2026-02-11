local M = {

    options = {
        {"guiStyle"     , CHOICE, 1 , {
            "1-Fancy",
            "2-Modern",
        }},
        {"guiStylePost" , CHOICE, 3 , {
            "Same as Flight Dashboard",
            "Summary 1",
            "Summary 2",
        }},
        {"enableAudio"     , BOOL  ,   1         }, -- 0=disable audio announcements, 1=enable audio announcements
        {"showTotalVoltage", BOOL  ,   0         }, -- 0=Show as average Lipo cell level, 1=show the total voltage (voltage as is)
        {"reserve_capa"    , VALUE ,   0, 0, 40  },
        {"currTop"         , VALUE , 200, 60,400 },
        {"tempTop"         , VALUE ,  80, 30,150 },
        {"textColor"       , COLOR , WHITE       },
    },

    translate = function(name)
        local translations = {
            showTotalVoltage="Show Voltage as Total",
            -- enableCapa="Enable Capacity",
            -- useTelemetry="Use Telemetry (faster update)",
            guiStyle="On Flight Dashboard",
            guiStylePost="Post Flight Dashboard",
            currTop="Max Current",
            tempTop="Max ESC Temp",
            textColor="Text Color",
            enableAudio="Enable Audio Announcements",
            reserve_capa="Reserve Capacity %",
        }
        return translations[name]
    end

}

return M
