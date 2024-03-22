function ParseSoundsFromFile()
    fileID as integer
    tString as string

    tID as integer
    tPath as string

    fileID = openToRead("sfxList.txt")
    soundCount = 0

    while fileEOF(fileID) <> 1
        soundCount = soundCount + 1
        tString = readline(fileID)

        tID = val(GetStringToken(tString, ",", 1))
        tPath = GetStringToken(tString, ",", 2)

        dim soundList[soundCount]
        soundList[soundCount - 1].path = tPath
        soundList[soundCount - 1].id = tID
      //  message(tPath)
    endwhile

    closefile(fileID)

endfunction

function StopAllSounds()
    i as integer
    for i = 0 to soundCount - 1
            if GetSoundExists(soundList[i].id) = 1
                stopSound(soundList[i].id)
            endif
    next
endfunction

function ParseMusicFromFile()
    fileID as integer
    tString as string

    tID as integer
    tPath as string

    musicCount = 0
    fileID = openToRead("musicList.txt")
    while fileEOF(fileID) <> 1
        tString = readline(fileID)

        tID = val(GetStringToken(tString, ",", 1))
        tPath = GetStringToken(tString, ",", 2)

        musicCount = musicCount + 1
        dim musicList[musicCount]
        musicList[musicCount - 1].path = tPath
        musicList[musicCount - 1].id = tID
    endwhile

    closefile(fileID)

endfunction

function StopMusicPref()
    StopMusic()
endfunction

function PlayMusicPref(pIndex as integer, pLoop as integer)
    i as integer

    if GetMusicExists(MUSIC_ID) = 1
        DeleteMusic(MUSIC_ID)
    endif

    i as integer

    for i = 0 to musicCount - 1
        if musicList[i].id = pIndex
            if GetMusicExists(MUSIC_ID) = 0
                loadMusic(MUSIC_ID, musicList[i].path)
            endif

            musicLoop = pLoop
            if playerPrefSFX = 1
                playMusic(MUSIC_ID, pLoop, MUSIC_ID, MUSIC_ID)
            endif

            exitfunction
        endif
    next
endfunction

function ResumeLastMusic()
    if playerPrefSFX = 1
        playMusic(MUSIC_ID, musicLoop, MUSIC_ID, MUSIC_ID)
    endif
endfunction

function TogglePlaybackMusic()
    if playerPrefSFX = 0
        stopmusic()
    else
        playMusic(MUSIC_ID, musicLoop, MUSIC_ID, MUSIC_ID)
    endif
endfunction

Function PlaySoundPref(pID as integer)
    i as integer

    if playerPrefSFX = 1
        for i = 0 to soundCount - 1
          //  message(str(i))
            if soundList[i].id = pID
                if GetSoundExists(soundList[i].id) = 0
                    loadSound(soundList[i].id, soundList[i].path)
                endif

                playsound(soundList[i].id)

                exitfunction
            endif
        next
    endif
endfunction

function ToggleMusicSFX(pSprite, pYes, pNo)
    if playerPrefSFX = 1
        playerPrefSFX = 0
        SetSpriteImage(pSprite, pNo)
    else
        playerPrefSFX = 1
        SetSpriteImage(pSprite, pYes)
    endif

    WriteSoundPref()
endfunction

function GetToggleMusicImage(pYes, pNo)
    myReturn as integer

    if playerPrefSFX = 1
        myReturn = pYes
    else
        myReturn = pNo
    endif

endfunction myReturn

function ParseSoundPref()
    pPath as string
    pPath = "sound.txt"
    fileID as integer
    tString as string
    tCount as integer
    i as integer

    if GetFileExists(pPath) = 1
        fileID = openToRead(pPath)
        tString = readline(fileID)

        playerPrefSFX = val(tString)

        closefile(fileID)
    else
        playerPrefSFX = 1
    endif
endfunction

function WriteSoundPref()
    pPath as string
    pPath = "sound.txt"
    fileID as integer
    tString as string
    tCount as integer
    i as integer

        fileID = openToWrite(pPath, 0)

                writeline(fileID, str(playerPrefSFX))

        closefile(fileID)

endfunction
