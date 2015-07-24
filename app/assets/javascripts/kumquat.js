var Kumquat = {

    Events: {
        ITEM_ADDED_TO_FAVORITES: 'KQItemAddedToFavorites',
        ITEM_REMOVED_FROM_FAVORITES: 'KQItemRemovedFromFavorites'
    },

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
            $('#kq-page-content').before(flash);

            // make it disappear after a delay
            setTimeout(function() {
                flash.fadeOut();
            }, Kumquat.Flash.FADE_OUT_DELAY);
        }

    },

    SearchBar: function() {

        var ELEMENT = $('#kq-search-accordion');
        var SPEED = 200;
        var visible = false;
        var self = this;

        construct();

        function construct() {
            // set initial position
            ELEMENT.css('margin-top', 0 - height() -
                parseFloat($('#kq-main-nav').css('margin-bottom').replace(/px/, '')) - 2);
        }

        function height() {
            return ELEMENT.height() +
                parseFloat(ELEMENT.css('padding-bottom').replace(/px/, '')) +
                parseFloat(ELEMENT.css('padding-top').replace(/px/, ''));
        };

        this.hide = function() {
            ELEMENT.animate({ 'margin-top': '-=' + height() + 'px' }, SPEED);
            visible = false;
        };

        this.show = function() {
            ELEMENT.animate({ 'margin-top': '+=' + height() + 'px' }, SPEED);
            visible = true;
        };

        this.toggle = function() {
            visible ? self.hide() : self.show();
        };

    },

    Util: {

        v4UUID: function() {
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
                var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
                return v.toString(16);
            });
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

        // clear kq_* text from any search fields
        $('input[name="q"]').each(function() {
            if ($(this).val().match(/kq_/)) {
                $(this).val(null);
            }
        });

        var search_bar = new Kumquat.SearchBar();
        $('#search-nav').on('click', function() {
            search_bar.toggle();
            return false;
        });
    },

    /**
     * @return An object representing the current view.
     */
    view: null

};

var ready = function() {
    Kumquat.init();
};

$(document).ready(ready);
$(document).on('page:load', ready);
