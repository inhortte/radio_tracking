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
    $("a[id^='radel']").click(function() {
	var id = this.id.substr(5);
	if(confirm("Are you sure?")) {
	    $.ajax({
		url: "/forms/released_animal/" + id + "/delete",
		success: function(anything) {
		    window.location.href = "/forms/released_animal";
		}
	    });
	}
    });
    $("select[id^='rt_']").change(function() {
	var id = $(this).val();
	$("#rt_nickname").val(id);
	$("#rt_animal_id").val(id);
	$("#rt_frequency").val(id);
	
	$.ajax({
	    url: "/ajax/rt/" + id, // This is the released_animal id
	    success: function(html) {
		$("#buliimia").html(html);
	    }
	});
    });
});
