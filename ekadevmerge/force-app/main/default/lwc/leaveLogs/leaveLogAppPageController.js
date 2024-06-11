// leaveLogAppPageController.js
({
    openLeaveLogForm : function(component, event, helper) {
        var isFormVisible = component.find('leaveLogForm').isFormVisible;
        component.find('leaveLogForm').isFormVisible = !isFormVisible;
    }
})