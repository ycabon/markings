(function () {
    "use strict";
    
    var browserScrolling;
    
    function handle(delta) {
        if (!browserScrolling) {
            return false;
        }
        return true;
    }
    
    function wheel(event) {
        var delta = 0;
        if (!event) {
            event = window.event;
        }
        browserScrolling = event.target.name !== "flashContent";
        if (event.wheelDelta) {
            delta = event.wheelDelta / 120;
            if (window.opera) {
                delta = -delta;
            }
        } else if (event.detail) {
            delta = -event.detail / 3;
        }
        if (delta) {
            handle(delta);
        }
        if (!browserScrolling) {
            if (event.preventDefault) {
                event.preventDefault();
            }
            event.returnValue = false;
        }
    }
    
    if (window.addEventListener) {
        window.addEventListener('DOMMouseScroll', wheel, false);
    }
    
    window.onmousewheel = document.onmousewheel = wheel;
    
}());
