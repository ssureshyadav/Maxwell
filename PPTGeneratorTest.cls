@isTest
private class PPTGeneratorTest{
    
    static testMethod void generate(){
    
        ContentVersion mainImage=new Contentversion();
        mainImage.title='ABC';
        mainImage.PathOnClient ='test.jpg';
        mainImage.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert mainImage;
        
        ContentVersion main=[Select ContentDocumentId from ContentVersion where Id = : mainImage.Id];
        
        ContentVersion otherImage=new Contentversion();
        otherImage.title='ABC';
        otherImage.PathOnClient ='test1.jpg';
        otherImage.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert otherImage;
        
        ContentVersion otherImage1=new Contentversion();
        otherImage1.title='ABC';
        otherImage1.PathOnClient ='test1.jpg';
        otherImage1.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert otherImage1;
        
        ContentVersion otherImage2=new Contentversion();
        otherImage2.title='ABC';
        otherImage2.PathOnClient ='test1.jpg';
        otherImage2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert otherImage2;
        
        ContentVersion other=[Select ContentDocumentId from ContentVersion where Id = : otherImage.Id];
        ContentVersion other1=[Select ContentDocumentId from ContentVersion where Id = : otherImage1.Id];
        ContentVersion other2=[Select ContentDocumentId from ContentVersion where Id = : otherImage2.Id];
        

        SymphonyIPM__Invention_Disclosure_New__c objInv= new SymphonyIPM__Invention_Disclosure_New__c();
        //objInvention.Name='TestIDF';
        objInv.SymphonyIPM__Alternative_Implementations_New__c='test implementation';
        objInv.SymphonyIPM__Detailed_Description__c='test description';
        //objInv.Advantages__c='test Advantage';
        objInv.MainImage__c =main.ContentDocumentId;
        objInv.Otherimages__c = other.ContentDocumentId;
        //objInv.SymphonyIPM__Internal_Counsel__c=uIc.Id;
        objInv.SymphonyIPM__Disclosure_Status__c='Draft';
        objInv.Category__c='A';
       // objInv.SymphonyIPM__Primary_Inventor__c = inv.id;
        objInv.Patent_Docket_No__c ='P51142US1';
        insert objInv;
        
        PPTGenerator.generatePPT(new List<Id>{objInv.Id});
        PPTGenerator.generatePPTFuture(new List<Id>{objInv.Id});
        
        objInv.Otherimages__c = other.ContentDocumentId +','+ other1.ContentDocumentId + ',' + other2.ContentDocumentId;
        update objInv;
        PPTGenerator.generatePPT(new List<Id>{objInv.Id});
        
        Test.startTest();
            System.enqueueJob(new PPTAsyncGenerator(new List<String>(),null,0,new List<String>(),new Map<String,Set<Id>>()));
        Test.stopTest();
                
        List<String> lstParams=new List<String>{'Apex','Suresh','Sanneboina'};
        List<String> lstimages=new List<String>{'sehwag.jpg##rId3','image1.jpg##rId2'};
        PPTGenerator.generate(lstParams,lstimages);
        
    }
}