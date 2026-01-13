local M = {

    options = {
        {"guiStyle"     , CHOICE, 1 , {
            "1-Fancy",
            "2-Modern",
        }},
        {"guiStylePost" , CHOICE, 1 , {
            "Replace to Sammary 1",
            "Do not replace",
        }},
        {"showTotalVoltage", BOOL  ,   0         }, -- 0=Show as average Lipo cell level, 1=show the total voltage (voltage as is)
        -- {"enableCapa"   , BOOL, 1 },
        {"currTop"         , VALUE , 150, 40,300 },
        {"tempTop"         , VALUE ,  90, 30,150 },
        {"textColor"       , COLOR , WHITE       },
        {"reserve_capa"    , VALUE ,   0, 0,40   },
        {"enableAudio"     , BOOL  ,   1         }, -- 0=disable audio announcements, 1=enable audio announcements
    },

    translate = function(name)
        local translations = {
            showTotalVoltage="Show Total Voltage",
            -- enableCapa="Enable Capacity",
            -- useTelemetry="Use Telemetry (faster update)",
            guiStyle="On Flight GUI Style",
            guiStylePost="Post Flight GUI Style",
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
