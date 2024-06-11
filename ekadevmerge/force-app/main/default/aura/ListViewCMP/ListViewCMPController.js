({
	onPageReferenceChange : function(component, event, helper) {
         var myPageRef = component.get("v.pageReference");
        var leadIds = myPageRef.state.c__listofleads;            
        if(leadIds!=null && leadIds!=undefined){
            component.set("v.leadIds",leadIds);
            helper.pullLead(component);
        }
		
	}
})