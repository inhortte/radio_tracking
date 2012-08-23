function setRTFields(ra) {
    $("#nickname_select").val(ra.nickname);
    $("#ra_id_select").val(ra.id);
    $("#frequency").val(ra.frequency);
}

$(document).ready(function() {
    $("#nickname_select").change(function() {
	var data = {
	    nickname: $(this).val()
	};
	$.ajax({
	    url: '/ajax/ra',
	    type: "POST",
	    data: data,
	    dataType: 'json',
	    success: function(ra) {
		setRTFields(ra);
	    }
	});
    });
    $("#ra_id_select").change(function() {
	var data = {
	    id: $(this).val()
	};
	$.ajax({
	    url: "/ajax/ra/" + $(this).val(),
	    dataType: 'json',
	    success: function(ra) {
		setRTFields(ra);
	    }
	});
    });
});
