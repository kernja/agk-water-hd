#include "ImageMembank.agc"
#include "Gameplay.agc"
#include "CursorControl.agc"
#include "screens.agc"
#include "parseImageList.agc"
#include "ScreenResolution.agc"
#include "ParseLevelData.agc"
#include "parseSoundList.agc"
#include "parseText.agc"
rem
rem AGK Application
rem
rem set app defaults
SetVirtualResolution(960, 640)
SetDefaultMinFilter(0)
SetDefaultMagFilter(0)
InitScreenResolution()
InitCursor()

rem define custom types
TYPE TYPE_POINT2D
    X as integer
    Y as integer
ENDTYPE

type Color
    R as integer
    G as integer
    B as integer
    A as integer
endtype

type TYPE_WATER_DROPLET
    X as integer
    Y as integer
    active as integer
endtype

type TYPE_MUSICFX
    path as string
    id as integer
endtype

type TYPE_LEVEL
    path as string
    id as integer
endtype

type TYPE_SCORE
    id as integer
    score as integer
    rank as integer
endtype


rem holds image data (being red into the app)
type typeImageData
    imageID as integer
    imagePath as string
    imageAtlas as integer
    magFilter as integer
    minFilter as integer
    keepDelete as integer
endtype

rem rem load all text data into the program
TYPE TYPE_TEXT_LIBRARY
    id as integer
    english as string
endtype

rem define constants
#constant LEVEL_GAMEPLAY 1000
#constant LEVEL_IMAGE 1001
#constant LEVEL_IMAGE_MASK 1002
#constant LEVEL_SPRITE 1001
#constant LEVEL_IMAGE_BG 1003

#constant MEMBLOCK_GAMEPLAY 1000
#constant MEMBLOCK_IMAGE 1001
#constant MEMBLOCK_IMAGE_MASK 1002
#constant MEMBLOCK_IMAGE_BG 1003
#constant MAX_DIMENS_X 2048
#constant MAX_DIMENS_Y 2048
#constant MAX_SOURCE 100
#constant MAX_DROPLETS 3000
#constant MUSIC_ID 10

global levelSelectPress as integer
    levelSelectPress = -1
global levelSelectRelease as integer
    levelSelectRelease = -1
global textCount as integer
global textLoaded as integer
global dim TextList[] as TYPE_TEXT_LIBRARY
global languageSelect as integer
    ParseLanguageFile()

global soundCount as integer
global musicCount as integer
global musicLoop as integer
global dim soundList[] as TYPE_MUSICFX
global dim musicList[] as TYPE_MUSICFX

rem create variables defined for the purpose of water
global Dim droplets[MAX_DROPLETS] as Type_Water_Droplet

global dropletCollected as integer
global dropletLost as integer
global dropletMade as integer
global dropletCountMax as integer
global dropletRequired as integer

rem define the variable used for storing water color
global waterColor as Color
    waterColor.R = 0
    waterColor.G = 0
    waterColor.B = 192
    waterColor.A = 255
rem define variable used for building walls
global buildColor as Color
    buildColor.R = 255
    buildColor.G = 242
    buildColor.B = 0
    buildColor.A = 255

rem define variables used for storing level data and file
global levelCount as integer
global levelActive as integer
global levelFinished as integer
global levelScoreA as integer
global levelScoreB as integer

global dim levelList[] as TYPE_LEVEL
ParseLevelList("levelList.txt")
global dim scoreList[levelCount] as TYPE_SCORE
ParseScoreList()
global dim levelData[MAX_DIMENS_X, MAX_DIMENS_Y] as integer
global levelSize as TYPE_POINT2D
global dim levelSource[MAX_SOURCE] as TYPE_POINT2D
global levelSpritePath as string
global levelMaskPath as string
global levelBGPath as string
global levelBombCount as integer
global levelBuildCount as integer
global levelStartCount as float
global levelTimerCount as float

rem reload level, stay in level
global levelReload as integer
rem loop gameplay
global levelLoop as integer
levelReload = 0
levelLoop = 0
global levelFinished as integer

levelStartCount = 10.0
levelBombCount = 200
levelBuildCount = 200
rem store variables used for determining whether or not to stop simulation early
global levelWaterDropping as integer
global levelWaterDropTimer as float

rem store data count and define array
global imageDataCount as integer
global dim imageData[] as typeImageData

rem load all images into memory
ParseImagesFromFile()
rem set default font image
SetTextDefaultFontImage(101)

rem create music variables
global dim soundList[] as string
global playerPrefSFX as integer
ParseSoundsFromFile()
ParseMusicFromFile()
ParseSoundPref()


rem create screens
CreateGameplayScreen()
CreatePauseScreen()

rem create puzzle select
rem puzzle select items = how many clickable squares are on the screen
global puzzleSelectItems as integer
global puzzleSelectIndex as integer
global puzzleSelectPages as integer
global puzzleSelectActivePage as integer

CreateMainMenu()
SetMainMenuVisible(0)
CreatePuzzleSelect()
SetPuzzleSelectVisible(0)

global scrollIconCount as integer

rem hold variables for gameplay interaction
global gameplayInteraction as integer
global editPoint as TYPE_Point2D
    editPoint.X = -320
    editPoint.Y = -320
global editPointOld as TYPE_Point2D
    editPointOld.X = -320
    editPointOld.Y = -320
global editDiameter as integer
    editDiameter = 8

REM CREATE VARIABLES FOR WORLD SCROLL
global worldScrollX as integer
global worldScrollY as integer

REM CREATE VARIABLES FOR SPRITE ZOOM
global spriteZoom as float
rem set up default variables
spriteZoom = 1
if GetDeviceName() = "windows"
    spriteZoom = 1.5
endif

SetViewZoomMode(1)
SetViewZoom(spriteZoom)

CreateImageScroll()
CreateLanguageSelect()
if languageSelect = -1
    RenderLanguageSelect()
else
    UpdateMenuText()
endif

SetMainMenuVisible(1)

PlayMusicPref(10, 1)
do

    UpdateCursor()
    UpdateScreenResolution()
    RenderMainMenu()
    Sync()
loop

function CheckSpritePointerCollision(pSpriteID as integer)
    myReturn as integer
    x as integer
    y as integer
    width as integer
    height as integer

    x = GetSpriteX(pSpriteID)
    y = GetSpriteY(pSpriteID)
    width = x + getSpriteWidth(pSpriteID)
    height = y + getspriteheight(pSpriteID)

    if GetSpriteVisible(pSpriteID) = 1

        if GetPointerX() >= x and getPointerX() <= width
            if GetPointerY() >= y and GetPointerY() <= height
                if GetCursorState() = 1
                    myReturn = 2
                endif
                if GetCursorPress() = 1
                    myReturn = 1
                endif

                If GetCursorRelease() = 1
                    myReturn = 3
                endif


            endif
        endif

    endif

endfunction myReturn

function CheckTextHover(pID as integer)
    tPointerX as integer
    tPointerY as integer

    tPointerX = GetPointerX()
    tPointerY = GetPointerY()
    tHover as integer = 0

    if tPointerX > GetTextX(pID) - (GetTextTotalWidth(pID) * .5 ) and tPointerX < GetTextX(pID) + (GetTextTotalWidth(pID) * .5 )
        if tPointerY > GetTextY(pID)  and tPointerY < GetTextY(pID) + GetTextTotalHeight(pID)
            if GetPointerState() = 1 or GetPointerReleased() = 1
                tHover = 1
            endif
        endif
    endif

    if tHover = 1
        SetTextColor(pID, 255, 255, 0, 255)
    else
        SetTextColor(pID, 255, 255, 255, 255)
    endif

endfunction tHover

function CheckTextClick(pID as integer, pSound as integer)
    tReturn as integer

    if CheckTextHover(pID) = 1
        if GetPointerReleased() = 1
            PlaySoundPref(pSound)
            tReturn = 1
        endif
    endif

endfunction tReturn

function Distance2D(pXA as float, pYA as float, pXB as float, pYB as float)
    myReturn as float
    myReturn = sqrt( ((pXB - pXA) ^ 2)  + ((pYB - pYA) ^ 2))
endfunction myReturn

function GetModifiedFrameTime()
    myReturn as float
    myReturn = GetFrameTime()

    if myReturn > 0.0166667
        myReturn = 0.0166667
    endif

endfunction myReturn
