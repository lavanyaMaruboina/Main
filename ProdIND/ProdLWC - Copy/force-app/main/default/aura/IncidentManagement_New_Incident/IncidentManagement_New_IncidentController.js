({
	doInit : function(component, event, helper) {
       /*component.set('v.isOpen', true);
       var flow = component.find('flow');
       flow.startFlow('Incident_Management_Case_close_screen');*/
    },

closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    },

closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
            //location.reload(false);
        }
    },
    handleClick :  function(component, event, helper) {
    
    component.set('v.isOpen', true);
       var flow = component.find('flow');
       flow.startFlow('IncidentManagement_New_Incident');
    }
})