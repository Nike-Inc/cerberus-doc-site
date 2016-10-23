$(document).ready(function () {
    $("#wrapper").touchwipe({
        wipeLeft: function() {
            // go right in menu
            shiftDirection(1);
        },
        wipeRight: function() {
            // go left in menu
            shiftDirection(-1);
        },
        min_move_x: 75,
        preventDefaultEvents: false
    });
});

var shiftDirection = function(n) {
    var menu = $(".menu").find('a');
    for (i = 0; i < menu.length; i++) {
        var isSelected = $(menu[i]).hasClass('selected');
        console.log(isSelected);
        if (isSelected) {
            if (i > 0 || i < menu.length -1) {
                $(menu)[i+n].click();
            }
        }
    }
};
