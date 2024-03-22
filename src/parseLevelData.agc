function ParseLevelList(pPath as string)
    fileID as integer
    tString as string
    tBase as string
    tSplit as string

    fileID = openToRead(pPath)
    levelCount = 0

    while fileEOF(fileID) <> 1
        tString = readline(fileID)
        tBase = GetStringToken(tString, ",", 1)
        tSplit = GetStringToken(tString, ",", 2)

        dim levelList[levelCount + 1]
        levelList[levelCount].id = val(tBase)
        levelList[levelCount].path = tSplit
        levelCount = levelCount + 1
    endwhile

    closefile(fileID)
endfunction

function ParseScoreList()
    pPath as string
    pPath = "score.txt"
    fileID as integer
    tString as string
    tCount as integer
    i as integer

    if GetFileExists(pPath) = 1
        fileID = openToRead(pPath)

        while fileEOF(fileID) <> 1 and levelCount - 1 > tCount
            tString = readline(fileID)
            scoreList[tCount].id = val(GetStringToken(tString, ",", 1))
            scoreList[tCount].score = val(GetStringToken(tString, ",", 2))
            scoreList[tCount].rank = val(GetStringToken(tString, ",", 3))
            tCount = tCount + 1
        endwhile

        closefile(fileID)
    else
        for i = 0 to levelCount - 1
            scoreList[i].id = i
        next
    endif
endfunction

function WriteScoreList()
    pPath as string
    pPath = "score.txt"
    fileID as integer
    tString as string
    tCount as integer
    i as integer

        fileID = openToWrite(pPath, 0)
            for i = 0 to levelCount - 1
                tString = str(scoreList[i].id) + "," + str(scoreList[i].score) + "," + str(scoreList[i].rank)
                writeline(fileID, tString)
            next

        closefile(fileID)

endfunction

function GetActiveLevelFile()
    myReturn as string

    myReturn = levelList[levelActive].path

endfunction myReturn

function SetLevelScore(pLevel, pScore, pRank)
    i as integer
   // for i = 0 to scoreList - 1
    //        if scoreList[i].id = pLevel
                if scoreList[pLevel].score < pScore
        scoreList[pLevel].id = pLevel
        scoreList[pLevel].score = pScore
        scoreList[pLevel].rank = pRank
        endif
 WriteScoreList()
endfunction

function ProgressNextLevel()
    levelActive = levelActive + 1
    if levelActive = levelCount
        levelActive = 0
    endif
endfunction

function ParseLevelData()
    fileID as integer
    tString as string
    tBase as string
    tSplit as string
    count as integer
    count = 1

    fileID = openToRead("puzzles/" + GetActiveLevelFile())

    while fileEOF(fileID) <> 1
        tString = readline(fileID)
        tBase = GetStringToken(tString, ":", 1)
        tSplit = GetStringToken(tString, ":", 2)

            if lower(tBase) = "sprite"
                levelSpritePath = tSplit
            elseif lower(tBase) = "mask"
                levelMaskPath = tSplit
            elseif lower(tBase) = "bg"
                levelBGPath = tSplit
            elseif lower(tBase) = "bomb"
                levelBombCount = val(tSplit)
            elseif lower(tBase) = "build"
                levelBuildCount = val(tSplit)
            elseif lower(tBase) = "buildc"
                 buildColor.R =  val(GetStringToken(tSplit, ",", 1))
                 buildColor.G =  val(GetStringToken(tSplit, ",", 2))
                 buildColor.B =  val(GetStringToken(tSplit, ",", 3))
                 buildColor.A = 255
            elseif lower(tBase) = "waterc"
                 waterColor.R =  val(GetStringToken(tSplit, ",", 1))
                 waterColor.G =  val(GetStringToken(tSplit, ",", 2))
                 waterColor.B =  val(GetStringToken(tSplit, ",", 3))
                 waterColor.A = 255
            elseif lower(tBase) = "droplets"
                dropletCountMax = val(tSplit)
            elseif lower(tBase) = "dropletsreq"
                dropletRequired = val(tSplit)
            elseif lower(tBase) = "timestart"
                levelStartCount = val(tSplit)
            elseif lower(tBase) = "timelevel"
                levelTimerCount = val(tSplit)
            elseif lower(tBase) = "pointsa"
                levelScoreA = val(tSplit)
            elseif lower(tBase) = "pointsb"
                levelScoreB = val(tSplit)
            endif
    endwhile

    closefile(fileID)

LoadLevelImages(levelSpritePath, levelMaskPath, levelBGPath)
PrepGameplayScreen()
endfunction

function ParseLanguageFile()
    pPath as string
    pPath = "language.txt"
    fileID as integer
    tString as string

    i as integer

    if GetFileExists(pPath) = 1
        fileID = openToRead(pPath)

        tString = readline(fileID)

        closefile(fileID)

         languageSelect = val(tString)

         if languageSelect < 0
            languageSelect = -1
        elseif languageSelect > 3
            languageSelect = -1
        endif
    else
        languageSelect = -1
    endif
endfunction

function WriteLanguageFile()
    pPath as string
    pPath = "language.txt"
    fileID as integer
    tString as string

        fileID = openToWrite(pPath, 0)

                writeline(fileID, str(languageSelect))

        closefile(fileID)

endfunction
