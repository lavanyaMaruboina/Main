({
    doInit : function(component, event, helper){
        var pageReference = component.get("v.pageReference");
        if(pageReference!==undefined && pageReference!==null && pageReference.state!=null)
        {
            console.log('AAAA');
            var recordId=pageReference.state.c__recordId; 
            component.set("v.recordId",recordId);
			console.log('AURA recordId '+recordId);
            var getTVRIdAction = component.get('c.getTVRId');

            getTVRIdAction.setParams({
                "caseId" : recordId 
            });

            getTVRIdAction.setCallback(this, function(res){
                var value = res.getReturnValue();
                component.set('v.TVRId', value);
                console.log('TVR ID received >>> '+JSON.stringify(value));
                var action = component.get('c.getProductType'); 
                action.setParams({
                    "tvrId" : value 
                });
                action.setCallback(this, function(res){
                    console.log('TVR Aura component: Product Type >> '+JSON.stringify(res.getReturnValue()));
                    if(res.getReturnValue() == 'Tractor') {
                        component.set('v.isTractor', true);
                    }
                    component.set('v.isLoaded', true);
                });
                $A.enqueueAction(action);
            });

            $A.enqueueAction(getTVRIdAction);

           // component.find('lWCComponent2').LWCFunction();   
              console.log('BBBB');
            //Do whatever we want to do with record id 
        }
        else if(pageReference==null){
  
                 var recordId=component.get("v.recordId");
            var getTVRIdAction = component.get('c.getTVRId');

            getTVRIdAction.setParams({
                "caseId" : recordId 
            });

            getTVRIdAction.setCallback(this, function(res){
                var value = res.getReturnValue();
                component.set('v.TVRId', value);
                console.log('TVR ID received >>> '+JSON.stringify(value));
                var action = component.get('c.getProductType'); 
                action.setParams({
                    "tvrId" : value 
                });
                action.setCallback(this, function(res){
                    console.log('TVR Aura component: Product Type >> '+JSON.stringify(res.getReturnValue()));
                    if(res.getReturnValue() == 'Tractor') {
                        component.set('v.isTractor', true);
                    }
                    component.set('v.isLoaded', true);
                });
                $A.enqueueAction(action);
            });

            $A.enqueueAction(getTVRIdAction);
           
           
            
        }
    },
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})