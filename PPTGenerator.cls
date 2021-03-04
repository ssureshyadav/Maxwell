public class PPTGenerator {

    public static String generatePPT(list<id> discIds)
    {
        try{
        Set<Id> condocids = new Set<Id>();
        StaticResource pptxTemplateFrame = [SELECT Body FROM StaticResource WHERE Name = 'PPTXTemplateFrame' LIMIT 1];
        
        list<SymphonyIPM__Invention_Disclosure_New__c> lstinv= [select Name,SymphonyIPM__Disclosure_Status__c,Inventors__c,SymphonyIPM__Title__c,MainImage__c,Otherimages__c,SymphonyIPM__Primary_Inventor__r.Name,Detailed_Description__c,Project_Code_Name__c from SymphonyIPM__Invention_Disclosure_New__c where id in: discIds];
        
        for(SymphonyIPM__Invention_Disclosure_New__c obj : lstinv){
            if(obj.MainImage__c!=null){
                condocids.add(obj.MainImage__c);
            }
            if(obj.Otherimages__c!=null){
                List<Id> lstimages=obj.Otherimages__c.split(',');
                condocids.addAll(lstimages);
            }
        }
        Boolean processBulk=false;
        if(!condocids.isEmpty()){
            if(condocids.size() > 3){
                processBulk=true;
            }else{
                Integer size=0;
                for(ContentVersion cv:[SELECT ContentSize FROM ContentVersion WHERE Id IN : condocids]){
                    size +=cv.ContentSize;
                }
                if(size > 200000){
                    processBulk=true;
                }
            }
        }
        
        if(processBulk){
            ContentVersion cvZip = new ContentVersion();
            String title = 'Presentation Mode';
            cvZip.Title = title;
            cvZip.PathOnClient = title + ' - ' + DateTime.now() + '.zip';
            cvZip.VersionData = pptxTemplateFrame.Body;
            cvZip.IsMajorVersion = false;
            insert cvZip;
            System.enqueueJob(new PPTAsyncGenerator(discIds,cvZip.Id,discIds.size(),new List<String>(),new Map<String,Set<Id>>()));
            return 'Async process' + cvZip.Id;
        }
        
        Zippex pptx = new Zippex(pptxTemplateFrame.Body);
        Zippex zipfile = new Zippex();
        
        /*Map<Id,List<Id>> mapInvDocuments=new Map<Id,List<Id>>();
        for(ContentDocumentLink cLink:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink Where LinkedEntityId IN : discIds AND ContentDocument.FileExtension IN ('png','jpg','tif')]){
            List<Id> lstDocId=new List<Id>();
            if(mapInvDocuments.containsKey(cLink.LinkedEntityId)){
                lstDocId.addAll(mapInvDocuments.get(cLink.LinkedEntityId));    
            }
            lstDocId.add(cLink.ContentDocumentId);
            mapInvDocuments.put(cLink.LinkedEntityId,lstDocId);
        }*/
        
        List<String> lstSlides=new List<String>();
        for(Integer i=0;i<lstinv.size();i++){
            SymphonyIPM__Invention_Disclosure_New__c inv=lstinv[i];
            PageReference pptxTemplate = page.PPTTemplate;
            List<String> textparams=new List<String>{inv.Name,inv.SymphonyIPM__Title__c,inv.Inventors__c,inv.Project_Code_Name__c,inv.Detailed_Description__c};
            List<String> imageparams=new List<String>();
            if(inv.MainImage__c!=null){
                ContentVersion cv = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where ContentDocumentId =: inv.MainImage__c];
                imageparams.add('image'+i+'##rId2');
                pptx.addFile('ppt/media/image'+i, cv.VersionData , null);
                zipfile.addFile(inv.Name +'/' + inv.Name +'-Main Image '+cv.PathOnClient, cv.VersionData, null);
            }
            
            if(inv.Otherimages__c != null){
                List<Id> lstDocId=inv.Otherimages__c.split(',');
                for(Id docId:lstDocId){
                    if( inv.MainImage__c != docId){
                        ContentVersion cv = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where ContentDocumentId =: docId];
                        zipfile.addFile(inv.Name +'/' + inv.Name +'-'+cv.PathOnClient, cv.VersionData, null);
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
        }
        
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
        System.debug('');
        zipfile.addFile('PPT' + ' - ' + DateTime.now() + '.pptx', pptx.getZipArchive(), null);
        /*ContentVersion cv = new ContentVersion();
        String title = 'pptxExample';
        cv.Title = title;
        cv.PathOnClient = title + ' - ' + DateTime.now() + '.pptx';
        cv.VersionData = pptx.getZipArchive();
        insert cv;*/
        
        ContentVersion cvZip = new ContentVersion();
        String title = 'Presentation Mode';
        cvZip.Title = title;
        cvZip.PathOnClient = title + ' - ' + DateTime.now() + '.zip';
        cvZip.VersionData = zipfile.getZipArchive();
        insert cvZip;
        system.debug(Limits.getCpuTime());
            system.debug(Limits.getLimitCpuTime());
            system.debug(Limits.getHeapSize());
            system.debug(Limits.getLimitHeapSize());
        
        Id contentDocumentid = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cvZip.Id].Id;
            return URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentid;
        }catch(exception e){
            return 'Error:'+e.getMessage() + '--'+e.getstacktraceString();
        }
    }
    
    
    /*public static String generatePPT(list<id> discIds)
    {
        try{
        map<id,string> condocids = new map<id,string>();
        StaticResource pptxTemplateFrame = [SELECT Body FROM StaticResource WHERE Name = 'PPTXTemplateFrame' LIMIT 1];
        Zippex pptx = new Zippex(pptxTemplateFrame.Body);
        Zippex zipfile = new Zippex();
        list<SymphonyIPM__Invention_Disclosure_New__c> lstinv= [select Name,SymphonyIPM__Disclosure_Status__c,Inventors__c,SymphonyIPM__Title__c,MainImage__c,Otherimages__c,SymphonyIPM__Primary_Inventor__r.Name,Detailed_Description__c,Project_Code_Name__c from SymphonyIPM__Invention_Disclosure_New__c where id in: discIds];
        
        List<String> lstSlides=new List<String>();
        for(Integer i=0;i<lstinv.size();i++){
            SymphonyIPM__Invention_Disclosure_New__c inv=lstinv[i];
            PageReference pptxTemplate = page.PPTTemplate;
            List<String> textparams=new List<String>{inv.Name,inv.SymphonyIPM__Title__c,inv.Inventors__c,inv.Project_Code_Name__c,inv.Detailed_Description__c};
            List<String> imageparams=new List<String>();
            if(inv.MainImage__c!=null){
                ContentVersion cv = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where ContentDocumentId =: inv.MainImage__c];
                imageparams.add('image'+i+'##rId2');
                pptx.addFile('ppt/media/image'+i, cv.VersionData , null);
                zipfile.addFile(inv.Name +'/' + inv.Name +'-Main Image '+cv.PathOnClient, cv.VersionData, null);
            }
            
            if(inv.Otherimages__c != null){
                List<Id> lstDocId=inv.Otherimages__c.split(',');
                for(Id docId:lstDocId){
                    if( inv.MainImage__c != docId){
                        ContentVersion cv = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where ContentDocumentId =: docId];
                        zipfile.addFile(inv.Name +'/' + inv.Name +'-'+cv.PathOnClient, cv.VersionData, null);
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
        }
        
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
        System.debug('');
        zipfile.addFile('PPT' + ' - ' + DateTime.now() + '.pptx', pptx.getZipArchive(), null);
        /*ContentVersion cv = new ContentVersion();
        String title = 'pptxExample';
        cv.Title = title;
        cv.PathOnClient = title + ' - ' + DateTime.now() + '.pptx';
        cv.VersionData = pptx.getZipArchive();
        insert cv;*
        
        ContentVersion cvZip = new ContentVersion();
        String title = 'Presentation Mode';
        cvZip.Title = title;
        cvZip.PathOnClient = title + ' - ' + DateTime.now() + '.zip';
        cvZip.VersionData = zipfile.getZipArchive();
        insert cvZip;
        system.debug(Limits.getCpuTime());
            system.debug(Limits.getLimitCpuTime());
            system.debug(Limits.getHeapSize());
            system.debug(Limits.getLimitHeapSize());
        
        Id contentDocumentid = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cvZip.Id].Id;
            return URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentid;
        }catch(exception e){
            return 'Error:'+e.getMessage() + '--'+e.getstacktraceString();
        }
    }*/

    @future(callout=true)
    public static void generatePPTFuture(list<id> discIds)
    {
        try{
        map<id,string> condocids = new map<id,string>();
        StaticResource pptxTemplateFrame = [SELECT Body FROM StaticResource WHERE Name = 'PPTXTemplateFrame' LIMIT 1];
        Zippex pptx = new Zippex(pptxTemplateFrame.Body);
        Zippex zipfile = new Zippex();
        list<SymphonyIPM__Invention_Disclosure_New__c> lstinv= [select Name,SymphonyIPM__Disclosure_Status__c,Inventors__c,SymphonyIPM__Title__c,MainImage__c,Otherimages__c,SymphonyIPM__Primary_Inventor__r.Name,Detailed_Description__c,Project_Code_Name__c from SymphonyIPM__Invention_Disclosure_New__c where id in: discIds];
        
        /*for(SymphonyIPM__Invention_Disclosure_New__c obj : lstinv){
            if(obj.MainImage__c!=null){
                condocids.put(obj.MainImage__c,obj.name);
            }
        }*/
        
        /*Map<Id,List<Id>> mapInvDocuments=new Map<Id,List<Id>>();
        for(ContentDocumentLink cLink:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink Where LinkedEntityId IN : discIds AND ContentDocument.FileExtension IN ('png','jpg','tif')]){
            List<Id> lstDocId=new List<Id>();
            if(mapInvDocuments.containsKey(cLink.LinkedEntityId)){
                lstDocId.addAll(mapInvDocuments.get(cLink.LinkedEntityId));    
            }
            lstDocId.add(cLink.ContentDocumentId);
            mapInvDocuments.put(cLink.LinkedEntityId,lstDocId);
        }*/
        
        /*Map<Id,ContentVersion> cvmap = new Map<Id,ContentVersion>([select id,Title,VersionData,ContentDocumentId from ContentVersion where ContentDocumentId in: mapInvDocuments.values()]);*/
        List<String> lstSlides=new List<String>();
        for(Integer i=0;i<lstinv.size();i++){
            SymphonyIPM__Invention_Disclosure_New__c inv=lstinv[i];
            PageReference pptxTemplate = page.PPTTemplate;
            List<String> textparams=new List<String>{inv.Name,inv.SymphonyIPM__Title__c,inv.Inventors__c,inv.Project_Code_Name__c,inv.Detailed_Description__c};
            List<String> imageparams=new List<String>();
            if(inv.MainImage__c!=null){
                ContentVersion cv = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where ContentDocumentId =: inv.MainImage__c];
                imageparams.add('image'+i+'##rId2');
                pptx.addFile('ppt/media/image'+i, cv.VersionData , null);
                zipfile.addFile(inv.Name +'/' + inv.Name +'-Main Image '+cv.PathOnClient, cv.VersionData, null);
            }
            
            if(inv.Otherimages__c != null){
                List<Id> lstDocId=inv.Otherimages__c.split(',');
                for(Id docId:lstDocId){
                    if( inv.MainImage__c != docId){
                        ContentVersion cv = [select id,Title,PathOnClient,VersionData,ContentDocumentId from ContentVersion where ContentDocumentId =: docId];
                        zipfile.addFile(inv.Name +'/' + inv.Name +'-'+cv.PathOnClient, cv.VersionData, null);
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
        }
        
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
        System.debug('');
        zipfile.addFile('PPT' + ' - ' + DateTime.now() + '.pptx', pptx.getZipArchive(), null);
        /*ContentVersion cv = new ContentVersion();
        String title = 'pptxExample';
        cv.Title = title;
        cv.PathOnClient = title + ' - ' + DateTime.now() + '.pptx';
        cv.VersionData = pptx.getZipArchive();
        insert cv;*/
        
        ContentVersion cvZip = new ContentVersion();
        String title = 'Presentation Mode';
        cvZip.Title = title;
        cvZip.PathOnClient = title + ' - ' + DateTime.now() + '.zip';
        cvZip.VersionData = zipfile.getZipArchive();
        insert cvZip;
        system.debug(Limits.getCpuTime());
            system.debug(Limits.getLimitCpuTime());
            system.debug(Limits.getHeapSize());
            system.debug(Limits.getLimitHeapSize());
        
        Id contentDocumentid = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cvZip.Id].Id;
        //return URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentid;
        }catch(exception e){
            //return 'Error:'+e.getMessage() + '--'+e.getstacktraceString();
        }
        //pptx.addFile('ppt/media/sehwag.jpg', sehwagresource.Body, null);
    }
    
    
    public static String generate(List<String> textList,List<String> imagelist) {
        // Build XLSX File Content 
        try{
        PageReference pptxTemplate = page.PPTTemplate;
        pptxTemplate.getParameters().put('textList', System.JSON.serialize(textList));
        pptxTemplate.getParameters().put('imageList', System.JSON.serialize(imageList));
        Blob pptxContent;
        if (Test.isRunningtest()) {
            pptxContent= Blob.valueOf('Sample');
        } else {
            pptxContent = pptxTemplate.getContent();
        }
        
        PageReference pptximageTemplate = page.PPTXRelationship;
        pptximageTemplate.getParameters().put('imageList', System.JSON.serialize(imageList));
        Blob pptxImageContent;
        if (Test.isRunningtest()) {
            pptxImageContent= Blob.valueOf('Sample');
        } else {
            pptxImageContent= pptximageTemplate.getContent();
        }
            
        // Build XLSX File Frame
        StaticResource pptxTemplateFrame = [SELECT Body FROM StaticResource WHERE Name = 'PPTXTemplateFrame' LIMIT 1];
        Zippex pptx = new Zippex(pptxTemplateFrame.Body);
        // Add the Content to the Frame to complete the File
        pptx.addFile('ppt/slides/slide1.xml', pptxContent, null);
        pptx.addFile('ppt/slides/_rels/slide1.xml.rels', pptxImageContent, null);
        
        
        /*StaticResource sehwagresource =[SELECT Body FROM StaticResource WHERE Name = 'sehwag' limit 1];
        pptx.addFile('ppt/media/sehwag.jpg', sehwagresource.Body, null);*/
        // Save XLSX File 
        ContentVersion cv = new ContentVersion();
        String title = 'pptxExample';
        cv.Title = title;
        cv.PathOnClient = title + ' - ' + DateTime.now() + '.pptx';
        cv.VersionData = pptx.getZipArchive();
        insert cv;
        
        
        Id contentDocumentid = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id].Id;
        return URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentid;
        }catch(exception e){
            return e.getMessage() + '--'+e.getstacktraceString();
        }
    }

}