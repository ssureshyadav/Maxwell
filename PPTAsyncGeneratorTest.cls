@isTest
private class PPTAsyncGeneratorTest
{
    @isTest
    static void generateData(){
        ContentVersion mainImage=new Contentversion();
        mainImage.title='ABC';
        mainImage.PathOnClient ='test.txt';
        mainImage.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert mainImage;
        
         Test.startTest();
            System.enqueueJob(new PPTAsyncGenerator(new List<String>(),null,0,new List<String>(),new Map<String,Set<Id>>()));
        Test.stopTest();
    }
}