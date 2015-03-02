var Kumquat = {

    Flash: {

        FADE_OUT_DELAY: 10000,

        /**
         * @param text
         * @param type Value of the X-Kumquat-Message-Type header
         * @return void
         */
        set: function(text, type) {
            var bootstrap_class;
            switch (type) {
                case 'success':
                    bootstrap_class = 'alert-success';
                    break;
                case 'error':
                    bootstrap_class = 'alert-danger';
                    break;
                case 'alert':
                    bootstrap_class = 'alert-block';
                    break;
                default:
                    bootstrap_class = 'alert-info';
                    break;
            }

            // remove any existing messages
            $('div.kq-flash').remove();

            // construct the message
            var flash = $('<div class="kq-flash alert ' + bootstrap_class + '"></div>');
            var button = $('<button type="button" class="close"' +
            ' data-dismiss="alert" aria-hidden="true">&times;</button>');
            flash.append(button);
            button.after(text);

            // append the flash to the DOM
            $('div.container header, div.container-fluid header').after(flash);

            // make it disappear after a delay
            setTimeout(function() {
                flash.fadeOut();
            }, Kumquat.Flash.FADE_OUT_DELAY);
        }

    },

    /**
     * Application-level initialization.
     */
    init: function() {
        // make flash messages disappear after a delay
        var flash = $('div.kq-flash');
        if (flash.length) {
            setTimeout(function () {
                flash.fadeOut();
            }, Kumquat.Flash.FADE_OUT_DELAY);
        }

        // make the active nav bar nav active
        $('.navbar-nav li').removeClass('active');
        $('.navbar-nav li#' + $('body').attr('data-nav') + '-nav').addClass('active');
    }

};

var ready = function() {
    Kumquat.init();
};

$(document).ready(ready);
$(document).on('page:load', ready);
