/**
 * @constructor
 */
var KQSearchView = function() {

    var FIELD_LIMIT = 4;

    this.init = function() {
        $('button.kq-add-field').on('click', function() {
            // limit to FIELD_LIMIT fields
            if ($('.kq-fields .form-group').length >= FIELD_LIMIT) {
                return;
            }
            var clone = $(this).prev('.form-group').clone(true);
            $(this).before(clone);
        });
        $('button.kq-remove-field').on('click', function() {
            $(this).closest('.form-group').remove();
        });

        $('button.kq-check-all').on('click', function() {
            $(this).closest('.kq-collections').find('input[type="checkbox"]').
                prop('checked', true);
        });
        $('button.kq-uncheck-all').on('click', function() {
            $(this).closest('.kq-collections').find('input[type="checkbox"]').
                prop('checked', false);
        });
    };

};

var ready = function() {
    if ($('body#search').length) {
        Kumquat.view = new KQSearchView();
        Kumquat.view.init();
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);
