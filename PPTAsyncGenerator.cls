public class PPTAsyncGenerator implements Queueable,Database.AllowsCallouts {
    public List<Id> lstInvIds;
    public Id converId;
    public Integer i;
    public List<String> lstSlides;
    public Map<String,Set<Id>> mapDocs;
    
    public PPTAsyncGenerator(List<Id> lstInvIds,Id converId,Integer index,List<String> lstSlides,Map<String,Set<Id>> mapDocs){
        this.lstInvIds =lstInvIds;
        this.converId =converId;
        this.i=index;
        this.lstSlides =lstSlides;
        this.mapDocs =mapDocs;
    }
    
    
    public void execute(QueueableContext context) {
        try{
        System.debug(i);
        
        Zippex pptx;
        If(converId == null && Test.isRunningTest()){
            pptx = new Zippex();
        }else{
            ContentVersion cVersion=[SELECT VersionData FROM ContentVersion WHERE Id = : converId];
            pptx = new Zippex(cVersion.VersionData);
        }
        //
        
        if(lstInvIds.isEmpty()){
            
            if(!mapDocs.isEmpty()){
                for(String names:mapDocs.keySet()){
                    List<Id> setdocs=new List<Id>();
                    setdocs.addAll(mapDocs.get(names));Id primaryId=setdocs[0];
                    ContentVersion primary = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where Id =: primaryId];
                    pptx.addFile(names +'/' + names +'-Main Image '+primary.PathOnClient, primary.VersionData, null);   setdocs.remove(0);
                    for(Id condocId:setdocs){
                        ContentVersion Secondary = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where Id =: condocId];
                        pptx.addFile(names +'/' + names +'-'+Secondary.PathOnClient, Secondary.VersionData, null);}}}
            
            ContentVersion cvZip = new ContentVersion(Id= converId);
            String title = 'Presentation Mode';
            cvZip.Title = title;
            cvZip.VersionData = pptx.getZipArchive();
            update cvZip;
            
            //Send Email
            Id contentDocumentid = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cvZip.Id].Id;
            
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            User usr=[Select Id,Email From User Where Id =: UserInfo.getUserId()];
            String[] toAddresses = new String[] {usr.Email,'selvamani.t@maxval.com'}; 
            //String[] ccAddresses = new String[] {'smith@gmail.com'};
            mail.setToAddresses(toAddresses);
            //mail.setCcAddresses(ccAddresses);
            //mail.setReplyTo('support@acme.com');
            mail.setSenderDisplayName('Suresh Sanneboina');mail.setSubject('PPT created : ' + case.Id);mail.setBccSender(false);
            mail.setUseSignature(false);mail.setPlainTextBody('Your PPT: ' + contentDocumentid +' has been created.');
            mail.setHtmlBody('Your PPT:<b> ' + contentDocumentid +' </b>has been created.<p>'+'To view your PPT <a href=' + URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentid+'>click here.</a>');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }else{
        
        Id invDiscId=lstInvIds[0];
        SymphonyIPM__Invention_Disclosure_New__c inv=[select Name,SymphonyIPM__Disclosure_Status__c,Inventors__c,SymphonyIPM__Title__c,MainImage__c,Otherimages__c,SymphonyIPM__Primary_Inventor__r.Name,Detailed_Description__c,Project_Code_Name__c from SymphonyIPM__Invention_Disclosure_New__c where id =: invDiscId];
        PageReference pptxTemplate = page.PPTTemplate;
        List<String> textparams=new List<String>{inv.Name,inv.SymphonyIPM__Title__c,inv.Inventors__c,inv.Project_Code_Name__c,inv.Detailed_Description__c};
        List<String> imageparams=new List<String>();
        if(inv.MainImage__c!=null){
            List<ContentVersion> lstcv = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where ContentDocumentId =: inv.MainImage__c];
            if(!lstcv.isEmpty()){
                ContentVersion cv=lstcv[0];
                imageparams.add('image'+i+'##rId2');
                mapDocs.put(inv.Name,new Set<Id>{cv.Id});
                pptx.addFile('ppt/media/image'+i, cv.VersionData , null);
            }
            //zipfile.addFile(inv.Name +'/' + inv.Name +'-Main Image '+cv.PathOnClient, cv.VersionData, null);
        }
        
        if(inv.Otherimages__c != null){
            
            List<Id> lstDocId=inv.Otherimages__c.split(',');
            
            for(Id docId:lstDocId){
                if( inv.MainImage__c != docId){
                    List<ContentVersion> lstcv = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where ContentDocumentId =: docId];
                    //zipfile.addFile(inv.Name +'/' + inv.Name +'-'+cv.PathOnClient, cv.VersionData, null);
                    if(!lstcv.isEmpty()){
                        ContentVersion cv=lstcv[0];
                        Set<Id> docIds=mapDocs.get(inv.Name); 
                        docIds.add(cv.Id);
                        mapDocs.put(inv.Name,docIds);
                    }
                }
            }
        }
        pptxTemplate.getParameters().put('textList', System.JSON.serialize(textparams));
        pptxTemplate.getParameters().put('imageList', System.JSON.serialize(imageparams));
        Blob pptxContent;
        if (Test.isRunningtest()) {
            pptxContent= Blob.valueOf('Sample');
        } else {
            pptxContent = pptxTemplate.getContent();
        }
        
        PageReference pptximageTemplate = page.PPTXRelationship;
        pptximageTemplate.getParameters().put('imageList', System.JSON.serialize(imageparams));
        Blob pptxImageContent;
        if (Test.isRunningtest()) {
            pptxImageContent= Blob.valueOf('Sample');
        } else {
            pptxImageContent= pptximageTemplate.getContent();
        }
        lstSlides.add('slide'+(i+1)+'##rId'+(7+i));
        pptx.addFile('ppt/slides/slide'+(i+1)+'.xml', pptxContent, null);
        pptx.addFile('ppt/slides/_rels/slide'+(i+1)+'.xml.rels', pptxImageContent, null);

        lstInvIds.remove(0);
        
        system.debug(Limits.getCpuTime());
        system.debug(Limits.getLimitCpuTime());
        system.debug(Limits.getHeapSize());
        system.debug(Limits.getLimitHeapSize());
        System.debug(lstInvIds.size());
        
        if(lstInvIds.size() > 0){
            
            ContentVersion cvZip = new ContentVersion(Id= converId);
            String title = 'Presentation Mode';
            cvZip.Title = title;
            cvZip.VersionData = pptx.getZipArchive();
            update cvZip;
            System.debug('batch called Multiple times');
            System.enqueueJob(new PPTAsyncGenerator(lstInvIds,converId,lstInvIds.size(),lstSlides,mapDocs));
        }else{
            Zippex zipfile = new Zippex();
            PageReference PPTPresentationTemplate = page.PPTPresentation;
            PPTPresentationTemplate.getParameters().put('slideList', System.JSON.serialize(lstSlides));
            Blob pptxPresentationsContent;
            if (Test.isRunningtest()) {
                pptxPresentationsContent= Blob.valueOf('Sample');
            } else {
                pptxPresentationsContent= PPTPresentationTemplate.getContent();
            }
            pptx.addFile('ppt/presentation.xml', pptxPresentationsContent, null);
            
            PageReference PPTPresentationrelsTemplate = page.PPTPresentationrels;
            PPTPresentationrelsTemplate.getParameters().put('slideList', System.JSON.serialize(lstSlides));
            Blob pptxPresentationsRelsContent;
            if (Test.isRunningtest()) {
                pptxPresentationsRelsContent= Blob.valueOf('Sample');
            } else {
                pptxPresentationsRelsContent= PPTPresentationrelsTemplate.getContent();
            }
            pptx.addFile('ppt/_rels/presentation.xml.rels', pptxPresentationsRelsContent, null);
            zipfile.addFile('PPT' + ' - ' + DateTime.now() + '.pptx', pptx.getZipArchive(), null);
            
            ContentVersion cvZip = new ContentVersion(Id= converId);
            String title = 'Presentation Mode';
            cvZip.Title = title;
            cvZip.VersionData = zipfile.getZipArchive();
            update cvZip;
            
            System.enqueueJob(new PPTAsyncGenerator(lstInvIds,converId,lstInvIds.size(),lstSlides,mapDocs));
        }
        }
        }catch(Exception e){
            System.debug('Error Log Object::');
            System.debug(e.getMessage() + '--'+e.getStackTraceString());
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'selvamani.t@maxval.com','sureshyadav@maxval.com'}; 
            //String[] ccAddresses = new String[] {'smith@gmail.com'};
            mail.setToAddresses(toAddresses);
            //mail.setCcAddresses(ccAddresses);
            //mail.setReplyTo('support@acme.com');
            mail.setSenderDisplayName('Suresh Sanneboina');
            mail.setSubject('Error');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody(e.getMessage() + '--'+e.getStackTraceString());
            mail.setHtmlBody(e.getMessage() + '--'+e.getStackTraceString());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
}