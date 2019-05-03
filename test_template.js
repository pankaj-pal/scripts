(function(_currentRec) {
	
	function template_match_percent(_rx, _string) {
		var arr = _rx.exec(_string)
		arr.shift();

		var total_test = arr.length
		var test_passed = 0 

		for (var i = 0; i < total_test; i ++ ) {
			if ( arr[i] != null ) {
				test_passed++;
			}
		}

		return Math.floor((test_passed/total_test)*100)
	}

	var lastCommentStr = _currentRec.comments.getJournalEntry(1).split('\n')[1];
	lastCommentStr = lastCommentStr ? lastCommentStr : _currentRec.comments.getJournalEntry(1);
	
	var rx = /^[\s\S]*?(?=(Problem Description:)?)[\s\S]*?(?=([\S\s]*Analysis:)?)[\s\S]*?(?=([\s\S]*Action Plan)?)[\s\S]*$/g
	var workNoteStr = 'Error occurred while parsing the response';
	
	var match_percentage = template_match_percent(rx, lastCommentStr); //calling function to calculate the match percentage
	workflow.scratchpad.percentage = match_percentage;
	
	if(parseInt(match_percentage) < 75) {
		
		workNoteStr = "Proper template was not used, match percentage is: " + match_percentage + "%.";
	}
	else {
		workNoteStr = "Proper template was not used, match percentage is: " + match_percentage + "%."
	}
	
	_currentRec.work_notes = workNoteStr;
})(current);
