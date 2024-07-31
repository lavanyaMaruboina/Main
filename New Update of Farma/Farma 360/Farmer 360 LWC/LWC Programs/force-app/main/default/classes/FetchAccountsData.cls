public class FetchAccountsData {

    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getRecentAccounts() {
        // Fetch recent accounts
        List<Account> accounts = [
            SELECT Id, Name, Phone, Email__c, Primary_Contact_Name__c, Primary_Contact_Phone__c,
                   ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, YearStarted
            FROM Account
            WHERE Active__c = 'Yes'
        ];

        System.debug('Fetched Accounts: ' + accounts.size());

        // Collect account IDs
        Set<Id> accountIds = new Set<Id>();
        for (Account account : accounts) {
            accountIds.add(account.Id);
        }

        System.debug('Account IDs: ' + accountIds);

        // Fetch related files
        List<ContentDocumentLink> documentLinks = [
            SELECT ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.FileExtension
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :accountIds
            AND ContentDocument.FileExtension != null
        ];

        System.debug('Document Links: ' + documentLinks.size());

        // Collect ContentDocumentIds
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : documentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        System.debug('Content Document IDs: ' + contentDocumentIds);

        // Fetch ContentVersions
        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            ORDER BY CreatedDate DESC
        ];

        System.debug('Content Versions: ' + contentVersions.size());

        // Create maps for quick lookup
        Map<Id, ContentDocumentLink> accountToFileMap = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink link : documentLinks) {
            accountToFileMap.put(link.LinkedEntityId, link);
        }

        System.debug('Account to File Map: ' + accountToFileMap.size());

        Map<Id, ContentVersion> documentToVersionMap = new Map<Id, ContentVersion>();
        for (ContentVersion version : contentVersions) {
            documentToVersionMap.put(version.ContentDocumentId, version);
        }

        System.debug('Document to Version Map: ' + documentToVersionMap.size());

        // Create the wrapper list
        List<AccountWrapper> accountWrapperList = new List<AccountWrapper>();
        for (Account account : accounts) {
            AccountWrapper wrapper = new AccountWrapper();
            wrapper.account = account;

            ContentDocumentLink link = accountToFileMap.get(account.Id);
            if (link != null) {
                ContentVersion version = documentToVersionMap.get(link.ContentDocumentId);
                if (version != null && link.ContentDocument != null && link.ContentDocument.FileExtension != null) {
                    String imageUrl = 'data:image/' + link.ContentDocument.FileExtension + ';base64,' + EncodingUtil.base64Encode(version.VersionData);
                    wrapper.attachmentUrl = imageUrl;

                    System.debug('Account Id: ' + account.Id + ' - Image URL: ' + imageUrl);
                } else {
                    System.debug('No valid image file for Account Id: ' + account.Id);
                }
            } else {
                System.debug('No linked file for Account Id: ' + account.Id);
            }

            accountWrapperList.add(wrapper);
        }

        System.debug('Final Account Wrapper List Size: ' + accountWrapperList.size());
        return accountWrapperList;
    }

    public class AccountWrapper {
        @AuraEnabled public Account account { get; set; }
        @AuraEnabled public String attachmentUrl { get; set; }
    }
}