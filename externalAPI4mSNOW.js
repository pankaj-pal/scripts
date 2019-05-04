(function(_currentRec) {
	
	function sendMessage(_sendTextStr, _botIdStr, _channelIdStr) {
		var sendTextEncStr = encodeURIComponent(_sendTextStr);
		try {
			var sendMessageObj = new sn_ws.RESTMessageV2('TelegramAPI', 'Default GET');
			sendMessageObj.setEndpoint('https://api.telegram.org/bot'+_botIdStr+'/sendMessage?chat_id='+_channelIdStr+'&text='+sendTextEncStr);
			var responseObj = sendMessageObj.execute();
		}
		catch(err) {
			var errorMsgStr = err.message;
			workflow.scratchpad.apiErrorMsgStr = errorMsgStr;
		}
	}
	var botIdStr = workflow.scratchpad.botIdStr;
	var channelIdStr = workflow.scratchpad.channelIdStr;
	var timeloopCounter = workflow.scratchpad.timeloopCounter;
	var waitTimeNum = workflow.scratchpad.waitTimeNum;
	var exceededTimeNum = workflow.scratchpad.exceededTimeNum;
	var taskSysIdStr = String(_currentRec.sys_id);
	var getSLARec = new GlideRecord('task_sla');
	getSLARec.addQuery('task',taskSysIdStr);
	getSLARec.query();
	var slaDetailsStr = '';
	var slaNameStr = '';
	var slaCommitStatStr = '';
	var slabusinessLeftStr = '';
	while(getSLARec.next()) {
		slaNameStr = getSLARec.u_name;
		slabusinessLeftStr = getSLARec.business_time_left.getDisplayValue();
		slaCommitStatStr= getSLARec.u_current_stage;
		slaDetailsStr += '\nCommitment Name- '+slaNameStr+'\nCommitment Status- '+slaCommitStatStr+'\nBusiness Time Left- '+slabusinessLeftStr+'\n';
	}
	
	var cuCompanyStr = _currentRec.company.name;
	var summaryStr = _currentRec.short_description;
	var taskStr = _currentRec.number;
	var stateStr = _currentRec.state.getDisplayValue();
	var assigneeGroupStr = _currentRec.assignment_group.name;
	var responseGroupStr = _currentRec.u_responsible_owner_group.name;
	var accountGroupStr = _currentRec.u_owner_group.name;
	var createdOnStr = _currentRec.sys_created_on;
	var assigneeStr = _currentRec.assigned_to.name;
	var updatedOnStr = _currentRec.sys_updated_on;
	var updatedByStr = _currentRec.sys_updated_by;
	var taskPriorityStr = _currentRec.priority;
	var lastCommentStr = _currentRec.comments.getJournalEntry(1).split('\n')[1].trim();
	
	if (JSUtil.nil(lastCommentStr)) {
		lastCommentStr = '';
	}
	
	var incidentMsgStr = 'New Incident:';
	
	if(timeloopCounter) {
		var hrNum;
		exceededTimeNum += waitTimeNum;
		var minNum = exceededTimeNum;
		var hoursNum = ( exceededTimeNum / 60 ) << 0;
		hrNum = hoursNum;
		minNum -= 60 * hoursNum;
		minNum = isNaN(parseInt(minNum)) ? 0 : parseInt(minNum);
		
		incidentMsgStr = 'The incident is not restored/resolved for past ' + hrNum + ' hours ' + minNum + ' minutes ';
	}
	var sendTextStr = incidentMsgStr + '\nPriority - ' + taskPriorityStr + '\n'+taskStr+' - ' + summaryStr + '\nClient - ' + cuCompanyStr + '\nStatus - ' + stateStr + '\nDate Opened - ' + createdOnStr + '\nAccountable Group - ' + accountGroupStr + '\nResponsible Group - ' + responseGroupStr + '\nAssignee Group - ' + assigneeGroupStr + '\nAssigned to - ' + assigneeStr + '\nUpdated By - ' + updatedByStr + '\nUpdated On - ' + updatedOnStr + '\nComments if any: - ' + lastCommentStr + '\n\nSLA Details\n----\n' + slaDetailsStr;
	
	sendMessage(sendTextStr, botIdStr, channelIdStr); //calling function to send message
	
	timeloopCounter = parseInt(timeloopCounter) + 1;
	workflow.scratchpad.timeloopCounter = timeloopCounter;
	workflow.scratchpad.exceededTimeNum = exceededTimeNum;
	
})(current);
