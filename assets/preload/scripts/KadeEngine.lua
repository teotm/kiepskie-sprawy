local bscore = 0
local songended = false
local noteCreated = false
local isPixel = false

function onCreatePost()
    if getPropertyFromClass('PlayState', 'isPixelStage') then 
		isPixel = true
	end

    setProperty('scoreTxt.visible', false)

    local timeY = 20

    if downscroll then
        timeY = 690
    end

    local songNameNoSpace = songName
    local difficultyNameUpper = string.upper(difficultyName:sub(1, 1)) .. difficultyName:sub(2, #difficultyName)

    for i = 1, #songName do
        if songName:sub(i, i) == " " then
            songNameNoSpace = songNameNoSpace:sub(1, i - 1) .. "-" .. songNameNoSpace:sub(i + 1, #songName)
        end
    end

    makeLuaText("timeTxtKade", songNameNoSpace, 0, 600, timeY)
    setProperty('timeTxtKade.visible', false)
    setTextSize('timeTxtKade', 17.5)
    setTextFont("timeTxtKade", "kade.ttf")
    setTextAlignment('timeTxtKade', 'CENTER')

    makeLuaText("scoreTxtKade", "NPS: 0 | Score:0 | Combo Breaks:0 | Accuracy:0% | N/A", 0, getProperty('scoreTxt.x') + 362.5, getProperty('scoreTxt.y') + 10)
    setTextSize('scoreTxtKade', 16)
    setTextFont("scoreTxtKade", "kade.ttf")
    setTextAlignment('scoreTxtKade', 'LEFT')
    setObjectOrder('scoreTxtKade', 40)

    makeLuaText("infoTxtKade", songNameNoSpace .. " " .. difficultyNameUpper .. " - Kiepski Engine 1.0", 0, 10, 690)
    setTextSize('infoTxtKade', 16)
    setTextAlignment('infoTxtKade', 'LEFT')
    setTextFont("infoTxtKade", "kade.ttf")
    setObjectOrder('infoTxtKade', 40)

    makeLuaText("msTxtKade", "69.42ms", 0, 520, 350)
    setProperty('msTxtKade.alpha', 0)
    setTextSize('msTxtKade', 17)
    setTextColor('msTxtKade', '00FFFF')
    setTextAlignment('msTxtKade', 'CENTER')
    setTextFont("msTxtKade", "kadems.otf")

    if isPixel then
        setProperty('msTxtKade.y', 400)
    end

    if not hideHud then
        if not hideTime then
            addLuaText("timeTxtKade")
        end

        addLuaText("scoreTxtKade")
        addLuaText("infoTxtKade")
    end

    addLuaText("msTxtKade")
end

local nps = 0
local noteHitted = false
local canRemove = true
local isbroNps = true
local willYouRemove = false

function goodNoteHit(id, noteData, noteType, isSustainNote)
    local strumTime = getPropertyFromGroup('notes', id, 'strumTime')
    local songPos = getPropertyFromClass('Conductor', 'songPosition')
    local rOffset = getPropertyFromClass('ClientPrefs','ratingOffset')
    
    local diff = strumTime - songPos + rOffset;
    local msDiffStr = string.format("%.3fms", -diff)

    if not isSustainNote then
        local rated = getRatingType(diff)

        if rated == "GOOD" then
            addScore(-150)
        elseif rated == "BAD" then
            addScore(-350)
        elseif rated == "SHIT" then
            addScore(-650)
            addMisses(1)
        end

        setTextString('msTxtKade', msDiffStr)
        setTextColor('msTxtKade', colorFromRating(diff))
        setProperty('msTxtKade.alpha', 1)
        doTweenAlpha('msAlpha', 'msTxtKade', 0, 0.5, "quartIn")
        runTimer('removeNoteHit', 1)

        if botPlay then
            setTextString('msTxtKade', msDiffStr .. " (BOT)")
            bscore = bscore + 350
        end

        noteHitted = false
        if canRemove then
            canRemove = false
            nps = nps - 1
        else
            nps = nps + 1
            willYouRemove = willYouRemove + 1

            if willYouRemove == true then
                willYouRemove = false
                canRemove = true
            else
                willYouRemove = true
            end
        end
    end

    runTimer('broNPS', 1)
    isbroNps = false
end

function onTimerCompleted(tag)
    if tag == "broNPS" then
        noteHitted = true
    end
end

function onStepHit()
    if noteHitted == true then
        nps = nps - 1
    else
        if curStep % 5 == 0 then
            nps = nps - 1
        end
    end     
end

function onBeatHit()
    if noteHitted == true then
        nps = nps - 2
    else
        nps = nps - 1
    end
end

function onGameOver()
    songended = true
    setPropertyFromClass('lime.app.Application', 'current.window.title', "Friday Night Funkin': Kiepski Engine - Game Over")

    return Function_Continue
end

local lastTexture = ""

function onUpdate()
    if not inGameOver then
        local acc = rating * 100
        local fctext = getProperty('ratingFC')

        if fctext == "SFC" then
            fctext = "MFC"
        end

        local calculatedtype = ""

        if acc == 100 then
            calculatedtype = 'AAAAA'
        elseif acc >= 95 then
            calculatedtype = 'AAAA'
        elseif acc >= 90 then
            calculatedtype = 'AAA'
        elseif acc >= 85 then
            calculatedtype = 'AA'
        elseif acc >= 80 then
            calculatedtype = 'A'
        elseif acc >= 60 then
            calculatedtype = 'B'
        elseif acc >= 40 then
            calculatedtype = 'C'
        elseif acc >= 20 then
            calculatedtype = 'D'
        elseif acc >= 0 then
            calculatedtype = 'F'
        end

        if nps < 0 then
            nps = 0
            noteHitted = false
        end
    
        if botPlay then
            setTextString("scoreTxtKade", "BOTPLAY - NPS: " .. nps .. " | Score:" .. bscore)
        else
            if hits > 0 then
                setTextString("scoreTxtKade", "NPS: " .. nps .. " | Score:" .. score .. " | Combo Breaks:" .. misses .. " | Accuracy:" .. math.floor(acc * 100) / 100 .. "% | (" .. fctext .. ") " .. calculatedtype)
            else
                setTextString("scoreTxtKade", "NPS: 0 | Score:0 | Combo Breaks:0 | Accuracy:0% | N/A")
            end
        end
    end
end

function onUpdatePost()
    if songended == false then
        local songNameNoSpace = songName
        local difficultyNameUpper = string.upper(difficultyName:sub(1, 1)) .. difficultyName:sub(2, #difficultyName)
    
        for i = 1, #songName do
            if songName:sub(i, i) == " " then
                songNameNoSpace = songNameNoSpace:sub(1, i - 1) .. "-" .. songNameNoSpace:sub(i + 1, #songName)
            end
        end

        if botPlay then
            setPropertyFromClass('lime.app.Application', 'current.window.title', "Friday Night Funkin': Kiepski Engine - " .. songNameNoSpace .. " [" .. difficultyNameUpper .. "] [Botplay]")
        else
            setPropertyFromClass('lime.app.Application', 'current.window.title', "Friday Night Funkin': Kiepski Engine - " .. songNameNoSpace .. " [" .. difficultyNameUpper .. "]")
        end
    end
end

function onDestroy()
    songended = true
    setPropertyFromClass('lime.app.Application', 'current.window.title', "Friday Night Funkin': Kiepski Engine")
end

function colorFromRating(diff)
    local absDiff = math.abs(diff)

    if absDiff < 46.0 then
        return '00FFFF'
    elseif absDiff < 91.0 then
        return '006400'
    elseif absDiff < 136.0 then
        return 'FFFF00'
    else
        return 'FF0000'
    end
end

function getRatingType(diff)
    local absDiff = math.abs(diff)

    if absDiff < 46.0 then
        return 'SICK'
    elseif absDiff < 91.0 then
        return 'GOOD'
    elseif absDiff < 136.0 then
        return 'BAD'
    else
        return 'SHIT'
    end
end