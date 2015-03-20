var ready = function() {
    if ($('body#rdf_predicates').length) {
        $('button.kq-add-predicate').on('click', function() {
            var tr = $('table.kq-predicates > tbody > tr:last-child');
            var cloned = tr.clone(true).insertAfter(tr);
            var cloned_inputs = cloned.find('input');
            cloned_inputs.val('');
            var uuid = v4UUID();
            $(cloned_inputs[0]).attr('name', 'predicates[' + uuid + '][_destroy]');
            $(cloned_inputs[1]).attr('name', 'predicates[' + uuid + '][uri]');
            $(cloned_inputs[2]).attr('name', 'predicates[' + uuid + '][label]');
        });

        $('button.kq-remove-predicate').on('click', function() {
            $(this).closest('tr').fadeOut().find('.kq-destroy-marker').val('1');
        });

        function v4UUID() {
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
                var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
                return v.toString(16);
            });
        }
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);
