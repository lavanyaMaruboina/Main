({
    doInit: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        
        if(myPageRef != null){
            var state = myPageRef.state;
            var stateString = JSON.parse(JSON.stringify(state)).ws;
            var URLSplit = stateString.split("/");
            var recordId =  URLSplit[URLSplit.length - 2];
            cmp.set("v.recordId", recordId);
		}        
    },
})