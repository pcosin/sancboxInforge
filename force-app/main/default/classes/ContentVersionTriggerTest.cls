@isTest
public class ContentVersionTriggerTest {
    @isTest
    static void testContentVersionTrigger() {
        Lead l = new Lead();
        l.Description = 'Test Description';
        l.FirstName = 'Test Name';
        l.LastName = 'Test LastName';
        l.Company = 'Test Company';
        insert l;

        ContentVersion cv = new Contentversion();
        cv.title = 'ABC';
        cv.PathOnClient = 'test';
        Blob b = Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Guest_Record_fileupload__c = l.Id;
        insert cv;
    }
}