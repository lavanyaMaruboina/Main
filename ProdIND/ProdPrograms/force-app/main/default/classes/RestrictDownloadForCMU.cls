public class RestrictDownloadForCMU implements Sfc.ContentDownloadHandlerFactory {
    public Sfc.ContentDownloadHandler getContentDownloadHandler( List<ID> listIds, Sfc.ContentDownloadContext context ) {
        Sfc.ContentDownloadHandler contentDownloadHandler = new Sfc.ContentDownloadHandler();
        Id profileId = UserInfo.getProfileId();
        
       /*if( String.isNotBlank( profileId ) ) {
            Profile objProfile = [ SELECT Id, Name FROM Profile WHERE Id =: profileId ];
            if ( objProfile != null && objProfile.Name == 'CMU' ) {
                contentDownloadHandler.isDownloadAllowed = false;
                contentDownloadHandler.downloadErrorMessage = 'Downloading a file is not allowed for your profile';
                return contentDownloadHandler;
            }
        }*/
       contentDownloadHandler.isDownloadAllowed = true;
        return contentDownloadHandler;
    } 
}