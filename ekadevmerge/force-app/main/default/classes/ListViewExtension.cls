public class ListViewExtension {
public List<Lead> selLeads;
    public String leadIds;
    
    // Constructor
    public ListViewExtension(ApexPages.StandardSetController cntlr){
        selLeads = cntlr.getSelected(); //get selected records from account list view
        leadIds = '';  
        for(Lead l : selLeads){
            leadIds += l.Id + '-'; //build list of ids string concatenated with comma                         
        }
        //selLeads = selLeads.removeEnd('-'); 
    } 
    
    public PageReference redirectToLC(){
        //'/lightning/cmp/c__LightningComponentName?c__listofAcounts=parameters'
        String returnUrl = '/lightning/cmp/c__ListViewCMP?c__listofLeads='+selLeads;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }
}