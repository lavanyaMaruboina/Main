({
    doInit : function(component, event, helper){
        console.log('doInit 1');
        var pageReference = component.get("v.pageReference");
        console.log('doInit 1',pageReference);
        if(pageReference!==undefined && pageReference!==null && pageReference.state!=null)
        {
            console.log('doInit 2',pageReference.state.c__recordId);
            var recordId=pageReference.state.c__recordId; 
            component.set("v.recordId",recordId);   
            console.log('doInit 3',recordId);
        }
    },
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})