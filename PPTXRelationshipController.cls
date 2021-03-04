public with sharing class PPTXRelationshipController {

    public String xmlbody { get; set; }

    public String xmlheader{ get; set; }
    
    public List<String> imageList {get; set;}
    
    public PPTXRelationshipController(){
        xmlheader='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
        
        String serializeimageList = ApexPages.currentPage().getParameters().get('imageList');
        System.debug('serializeimageList:::'+serializeimageList);
         if(serializeimageList == null){
            List<String> lstParams=new List<String>{'sehwag.jpg##rId2'};
            imageList=lstParams;
        }else{
            imageList = (List<String>) System.JSON.deserialize(serializeimageList , List<String>.class);
        }
        
        xmlbody ='<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">';
        for(String image:imageList){
            String[] imageName=image.split('##');
            xmlbody +='<Relationship Target="../media/'+imageName[0]+'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Id="'+imageName[1]+'"/>';    
        }
        xmlbody +='<Relationship Target="../slideLayouts/slideLayout1.xml" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Id="rId1"/>'
                    +'</Relationships>';
        
    }
}