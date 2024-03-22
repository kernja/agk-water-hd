global devWidth as float
global devHeight as float
global devIsLandscape as integer
global devMin as float
global devMax as float
global devAspect as float

global virtMin as float
global virtMax as float
global virtWidth as float
global virtHeight as float

function InitScreenResolution()
    SetOrientationAllowed(0, 0, 1, 1)
    devWidth = GetDeviceWidth()
    devHeight = GetDeviceHeight()

    devIsLandscape = ( devWidth > devHeight )

   // if devIsLandscape
        devMin = devHeight
        devMax = devWidth
   // else
   //     devMin = devWidth
   //     devMax = devHeight
   // endif

    devAspect = devMax / devMin

    virtMin = 640
    virtMax = virtMin * devAspect

endfunction

function UpdateScreenResolution()
   // devIsLandscape = ( getDeviceWidth() > getDeviceHeight() )

    //if devIsLandscape
        virtWidth = virtMax
        virtHeight = virtMin
    //else
    //    virtWidth = virtMin
   //     virtHeight = virtMax
   // endif
    SetOrientationAllowed(0, 0, 1, 1)

    SetVirtualResolution( virtWidth , virtHeight )
endfunction

function VirtMinSize(pValue as float)
    myReturn as float

    myReturn = virtMin * (pValue / virtMin)

endfunction myReturn
