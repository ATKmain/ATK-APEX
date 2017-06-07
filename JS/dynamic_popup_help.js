function ATKpopupFieldHelp(pPARAM){
	
$.ajax({
	type: "POST",
	url: "wwv_flow.show",
	dataType: "json",
	data: {
		p_flow_id: "&APP_ID.",
		p_flow_step_id: "&APP_PAGE_ID.",
		p_instance: "&APP_SESSION.",
		p_request: "APPLICATION_PROCESS=GET_ATK_PARAM",
		x01: pPARAM
	},
	success: function (jd) {
		$.each(jd.row,
			function (i, jr) {
			//console.log(jr.PARAM + "=" + jr.VALUE);
			var lDialog = apex.jQuery("#apex_popup_field_help");
			if (lDialog.length === 0) {
				// add a new div with the retrieved page
				lDialog = apex.jQuery('<div id="apex_popup_field_help">' + jr.VALUE + '</div>');
				// open created div as a dialog
				lDialog
				.dialog({
					title: 'Column Header Help',
					bgiframe: true,
					width: 500,
					height: 350,
					show: 'drop',
					hide: 'drop'
				});
			} else {
				// replace the existing dialog and open it again
				lDialog
				.html(jr.VALUE)
				.dialog('option', 'title', jr.PARAM)
				.dialog('open');
			};
		}
		)
	}
});


    return;
}; // ATKpopupFieldHelp