TYPE TYPE_CURSOR_CONTROL
    REM BASIC CURSOR DATA
    cursorPress as integer
    cursorState as integer
    cursorRelease as integer

    REM HOLD WHETHER OR NOT MULTITOUCH IS ENABLED
    multiTouch as integer

    REM HOLD VARIABLES FOR MULTITOUCH
    REM INPUT COUNT
    touchPressCount as integer
    touchReleaseCount as integer

    REM HOLD VARIABLES FOR THE CURSOR POSITIONING
    location as TYPE_POINT2D

    REM HOLD VARIABLES FOR CURSOR OFFSET POSITIONING
    offsetOld as TYPE_POINT2D
    offsetNew as TYPE_POINT2D

    REM HOLD VARIABLES FOR ZOOM POSITIONING
    zoomA as TYPE_POINT2D
    zoomB as TYPE_POINT2D

    REM ZOOM DISTANCE
    zoomDistanceOld as float
    zoomDistanceNew as float

    REM HOLD VARIABLES FOR CURSOR SWIPE
    swipeOld as TYPE_POINT2D
    swipeNew as TYPE_POINT2D
    swipeDifference as TYPE_POINT2D
ENDTYPE

GLOBAL cursor as TYPE_CURSOR_CONTROL

FUNCTION InitCursor()
    REM SET UP MULTITOUCH VALUE
    cursor.multiTouch = GetMultiTouchExists()

    REM REGULAR LOCATION POSITION
    cursor.location.X = -1
    cursor.location.Y = -1

    REM OFFSET LOCATION POSITION
    REM RESET TO AN INVALID LOCATION SO WE CAN TELL WHETHER OR NOT
    REM THE LOCATION STORED IS A VALID ONE
    cursor.offsetOld.X = -1
    cursor.offsetOld.Y = -1
    cursor.offsetNew.X = -1
    cursor.offsetNew.Y = -1

    REM ZOOM LOCATION
    cursor.zoomA.X = -1
    cursor.zoomA.Y = -1
    cursor.zoomB.X = -1
    cursor.zoomB.Y = -1

    REM ZOOM DISTANCE
    cursor.zoomDistanceOld = 0
    cursor.zoomDistanceNew = 0

    REM SWIPE LOCATIN
    cursor.swipeOld.X = -1
    cursor.swipeOld.Y = -1
    cursor.swipeNew.X = -1
    cursor.swipeNew.Y = -1

    REM SWIPE DIFFERENCE
    cursor.swipeDifference.X = -1
    cursor.swipeDifference.Y = -1

ENDFUNCTION

FUNCTION UpdateCursor()
    REM LOCAL VARIABLES
    tIndex as integer
    tCount as integer

    REM UPDATE BASIC CURSOR PRESS DATA
    REM WITH THE STANDARD AGK FUNCTIONS
    cursor.cursorPress = GetPointerPressed()
    cursor.cursorState = GetPointerState()
    cursor.cursorRelease = GetPointerReleased()

    //print(cursor.multiTouch)
    if GetDeviceName() = "windows"
        cursor.multiTouch = 0
    endif
    REM UPDATE THESE VALUES BASED UPON WHETHER OR NOT MULTITOUCH EXISTS OR NOT
    if cursor.multiTouch = 0
        cursor.touchPressCount = GetPointerState()
        cursor.touchReleaseCount = GetPointerReleased()
    elseif cursor.multiTouch = 1
        REM GO THROUGH MULTI TOUCH AND SEE HOW MANY TOUCHES WE HAVE
        REM SET OUR TOUCH COUNT VARIABLES TO ZERO
        cursor.touchPressCount = 0
        cursor.touchReleaseCount = 0

        REM GET OUR FIRST INDEX
        REM RETURNS 0 IF WE HAVE NO TOUCH EVENTS
        tIndex = GetRawFirstTouchEvent(1)

        while tIndex <> 0
            REM INCREASE TOUCH COUNT BY ONE
            cursor.touchPressCount = cursor.touchPressCount + 1

            REM CHECK TO SEE IF THE TOUCH HAS BEEN RELEASED
            if GetRawTouchReleased(tIndex) = 1
                cursor.touchReleaseCount = cursor.touchReleaseCount + 1
            endif

            tIndex =  GetRawNextTouchEvent()
        endwhile
    endif

    REM RESET CURSOR VALUES IF THERE IS ABSOLUTELY NO INPUT GOING ON
    if cursor.cursorPress = 0 and cursor.cursorState = 0 and cursor.cursorRelease = 0
        REM REGULAR LOCATION POSITION
        cursor.location.X = -1
        cursor.location.Y = -1

        REM OFFSET LOCATION POSITION
        REM RESET TO AN INVALID LOCATION SO WE CAN TELL WHETHER OR NOT
        REM THE LOCATION STORED IS A VALID ONE
        cursor.offsetOld.X = -1
        cursor.offsetOld.Y = -1
        cursor.offsetNew.X = -1
        cursor.offsetNew.Y = -1
    endif

    REM UPDATE OFFSET VALUES
    REM THIS IS USED FOR SCROLLING
    REM AS THIS CAN BE USED FOR BOTH MULTITOUCH AND SINGLETOUCH, IT USES BASIC INTERNAL FUNCTIONS
    if (cursor.multiTouch = 1 and cursor.touchPressCount = 1) or cursor.multiTouch = 0
        REM MAKE SURE THERE IS INPUT
        if cursor.cursorState = 1
            REM SET PREVIOUS VALUES TO OLD CURSOR STATE
                cursor.offsetOld.X = cursor.offsetNew.X
                cursor.offsetOld.Y = cursor.offsetNew.Y
            REM SET CURRENT VALUES TO NEW
                cursor.offsetNew.X = GetPointerX()
                cursor.offsetNew.Y = GetPointerY()
        endif
    endif

    REM UPDATE CURSOR POSITIONING
    REM DIFFERENT FUNCTIONS FOR MULTITOUCH AND FOR SINGLETOUCH
    if cursor.multiTouch = 0
        cursor.location.X = GetPointerX()
        cursor.location.Y = GetPointerY()
    else
        REM UPDATE CURSOR IF WE HAVE TOUCH INPUT DATA
        if cursor.touchPressCount <> 0
            REM GET OUR FIRST INDEX
            REM RETURNS 0 IF WE HAVE NO TOUCH EVENTS
            tIndex = GetRawFirstTouchEvent(1)

            REM RESET CURSOR LOCATION TO 0
            REM SINCE WE AVERAGE OUT TOUCH VALUES FOR THE POSITIONNG
            cursor.location.X = 0
            cursor.location.Y = 0

                while tIndex <> 0
                    cursor.location.X = cursor.location.X + GetRawTouchCurrentX(tIndex)
                    cursor.location.Y = cursor.location.Y + GetRawTouchCurrentY(tIndex)

                    REM GET NEXT TOUCH EVENT
                    tIndex = GetRawNextTouchEvent()
                endwhile

                cursor.location.X = cursor.location.X / cursor.touchPressCount
                cursor.location.Y = cursor.location.Y / cursor.touchPressCount
        endif
    endif

    REM UPDATE ZOOM POSITINING
    REM ZOOM DOES NOT WORK ON SINGLETOUCH SO WE IGNORE IT
    if cursor.multiTouch = 1

        REM WE NEED TWO OR MORE INPUTS FOR THIS TO WORK
        REM ONLY USE THE FIRST TWO INPUTS
        if cursor.touchPressCount >= 2
            REM SET TCOUNT TO 0 FOR COUNTING
            tCount = 0

            REM GET OUR FIRST INDEX
            REM RETURNS 0 IF WE HAVE NO TOUCH EVENTS
            tIndex = GetRawFirstTouchEvent(1)

            while tIndex <> 0
                if tCount = 0
                    cursor.zoomA.X = GetRawTouchCurrentX(tIndex)
                    cursor.zoomA.Y = GetRawTouchCurrentY(tIndex)
                else
                    cursor.zoomB.X = GetRawTouchCurrentX(tIndex)
                    cursor.zoomB.Y = GetRawTouchCurrentY(tIndex)
                endif

                REM GET NEXT TOUCH EVENT
                tIndex = GetRawNextTouchEvent()
                tCount = tCount + 1

                REM EXIT IF WE HAVE OUR TWO INPUTS
                if tCount = 2
                    exit
                endif
            endwhile

            REM UPDATE CURSOR ZOOM VALUES
            cursor.zoomDistanceOld = cursor.zoomDistanceNew
            cursor.zoomDistanceNew = FigureCursorZoomDistance()

            REM GET RID OF OFFSET VALUES
            REM AS ZOOMING AND LETTING GO OF ONE FINGER
            REM CAN SCREW UP OFFSET!

            REM THIS IS JUST A PRECAUTIONARY MEASURE
            REM TO PREVENT IMAGE JUMPING AROUND
            REM SET OLD VALUES TO -1
            cursor.offsetOld.X = -1
            cursor.offsetOld.Y = -1
            cursor.offsetNew.X = -1
            cursor.offsetNew.Y = -1
        else
            REM RESET ZOOM IF WE CANNOT DO IT
            REM ZOOM LOCATION
            cursor.zoomA.X = -1
            cursor.zoomA.Y = -1
            cursor.zoomB.X = -1
            cursor.zoomB.Y = -1

            REM ZOOM DISTANCE
            cursor.zoomDistanceOld = -1
            cursor.zoomDistanceNew = -1
        endif
    endif

    REM UPDATE SWIPE POSITIONING
    REM WE DON'T RESET THESE VALUES EVERY FRAME
    REM WE ERASE THEM ONLY WHEN THE USER DOES A NEW PRESS

    REM AS THIS CAN BE USED WITH SINGLE OR MULTI TOUCH, USE BASIC BUILT-IN COMMANDS
    if GetCursorPress() = 1
        REM RESET VALUES
        cursor.swipeDifference.X = 0
        cursor.swipeDifference.Y = 0

        cursor.swipeNew.X = -1
        cursor.swipeNew.Y = -1

        cursor.swipeOld.X = GetPointerX()
        cursor.swipeOld.Y = GetPointerY()
    elseif GetCursorRelease() = 1
        cursor.swipeNew.X = GetPointerX()
        cursor.swipeNew.Y = GetPointerY()

        cursor.SwipeDifference.X = cursor.swipeOld.X - cursor.swipeNew.X
        cursor.SwipeDifference.Y = cursor.swipeOld.Y - cursor.swipeNew.Y
    else
        cursor.SwipeDifference.X = 0
        cursor.SwipeDifference.Y = 0

        cursor.swipeNew.X = -1
        cursor.swipeNew.Y = -1
    endif

ENDFUNCTION

REM CURSOR STATE VALUES
function GetCursorState()
endfunction cursor.cursorState

function GetCursorPress()
endfunction cursor.cursorPress

function GetCursorRelease()
endfunction cursor.cursorRelease

REM CURSOR POSITION
function GetCursorX()
endfunction cursor.location.X

function GetCursorY()
endfunction cursor.location.Y

REM GET CURSOR PRESS AND RELEASE COUNT
function GetCursorPressCount()
endfunction cursor.touchPressCount

function GetCursorReleaseCount()
endfunction cursor.touchReleaseCount

REM CHECK TO SEE IF THE CURSOR CAN SCROLL
REM THIS IS ONLY VALID IF THE POINTER ISN'T INITIAL FIRST PRESS AND IS STILL BEING PRESSED
function CanCursorScroll()
    myReturn as integer
    myReturn = 1

    if cursor.offsetOld.X = -1 or cursor.offsetOld.Y = -1
        myReturn = 0
    endif

endfunction myReturn

REM GET CURRENT SCROLL VALUE FOR X/Y
REM THIS IS THE DIFFERENCE BETWEEN THE OLD AND NEW OFFSET X/Y
function GetCursorScrollX()
    myReturn as integer

    if CanCursorScroll() = 1
        myReturn = cursor.offsetOld.X - cursor.offsetNew.X
    endif
endfunction myReturn

function GetCursorScrollY()
    myReturn as integer

    if CanCursorScroll() = 1
        myReturn = cursor.offsetOld.Y - cursor.offsetNew.Y
    endif
endfunction myReturn

REM GET WHETHER OR NOT THE CURSOR CAN ZOOM
function CanCursorZoom()
    myReturn as integer
    myReturn = 1

    if cursor.zoomB.X = -1 or cursor.zoomB.Y = -1 or cursor.zoomDistanceOld = -1
        myReturn = 0
    endif
endfunction myReturn

REM GET THE DISTANCE FOR THE ZOOM - A POSITIVE VALUE INCREASES ZOOM
REM A NEGATIVE VALUE DECREASES ZOOM
REM PASS IN A NUMBER TO MAKE THE ZOOM DISTANCE BIGGER OR SMALLER.
REM SMALLER NUMBER PASSED IN MAKES THE ZOOM DISTANCE BIGGER, BIGGER = SMALLER
REM TAILOR TO YOUR OWN LIKING
function GetCursorZoomDistance(pDivideBy as integer)
    myReturn as float

    if CanCursorZoom() = 1
        myReturn = (cursor.zoomDistanceNew - cursor.zoomDistanceOld)
        myReturn = myReturn / pDivideBy
    else
        myReturn = 0
    endif

endfunction myReturn

REM FUNCTION FOR DISTANCE
REM WE USE THIS FOR THE ZOOM
REM IT'S JUST A BASIC DISTANCE FORMULA
function FigureCursorZoomDistance()
    myReturn as float
    myReturn = sqrt( ((cursor.zoomB.X - cursor.zoomA.X) ^ 2)  + ((cursor.zoomB.Y - cursor.zoomA.Y) ^ 2))
endfunction myReturn

REM FUNCTION TO SEE
REM IF THE USER CAN SWIPE
function CanCursorSwipe()
    myReturn as integer
    myReturn = 1

    if cursor.swipeNew.X = -1 or cursor.swipeNew.Y = -1
        myReturn = 0
    endif
endfunction myReturn

REM FOR THESE, PASS IN A THRESHOLD TO SEE IF THERE WAS A SWIPE
REM HIGHER THRESHOLD = LONGER SWIPE NEEDED TO TRIGGER
function GetCursorSwipeX(pThreshold as integer)
    myReturn as integer
    myReturn = 0

    if CanCursorSwipe() = 1
        if cursor.swipeDifference.X > pThreshold
            myReturn = 1
        elseif abs(cursor.swipeDifference.X) > pThreshold
            myReturn = -1
        endif
    endif

endfunction myReturn

function GetCursorSwipeY(pThreshold as integer)
    myReturn as integer
    myReturn = 0

    if CanCursorSwipe() = 1
        if cursor.swipeDifference.Y > pThreshold
            myReturn = 1
        elseif abs(cursor.swipeDifference.Y) > pThreshold
            myReturn = -1
        endif
    endif

endfunction myReturn


Function ScrollScreen()
SetViewOffset(-worldScrollX, -worldScrollY)
 //print(GetCursorPressCount())
    REM DO SCROLL ONLY IF WE HAVE A PRESS COUNT OF 1
    if GetCursorPressCount() = 1
        if CanCursorScroll() = 1

            worldScrollX = worldScrollX - GetCursorScrollX()
            worldScrollY = worldScrollY - GetCursorScrollY()
            SetViewOffset(-worldScrollX, -worldScrollY)

        endif
    REM DO ZOOM IF WE HAVE A PRESS COUNT OF 2
    elseif GetCursorPressCount() = 2
        if CanCursorZoom() = 1
            spriteZoom = spriteZoom + (GetCursorZoomDistance(300) * .5)

            if spriteZoom < .5
                spriteZoom = .5
            endif

            if spriteZoom > 4
                spriteZoom = 4
            endif

            SetViewZoom(spriteZoom)
        endif
    endif

endfunction
