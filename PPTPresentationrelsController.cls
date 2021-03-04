public class PPTPresentationrelsController{
    
    public String xmlbody { get; set; }

    public String xmlHeader { get; set; }
    
     public List<String> slideList{get; set;}
    
    public PPTPresentationrelsController(){
        xmlheader='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
        
        String serializeimageList = ApexPages.currentPage().getParameters().get('slideList');
        System.debug('serializeimageList:::'+serializeimageList);
         if(serializeimageList == null){
            List<String> lstParams=new List<String>{'sehwag.jpg##rId2'};
            slideList=lstParams;
        }else{
            slideList = (List<String>) System.JSON.deserialize(serializeimageList , List<String>.class);
        }
        xmlbody ='';
        xmlbody +='<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                +'<Relationship Target="presProps.xml" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/presProps" Id="rId3"/>';
        
        for(String slide:slideList){
            String[] slideName=slide.split('##');
            xmlbody +='<Relationship Target="slides/'+slideName[0]+'.xml" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Id="'+slideName[1]+'"/>';
        }
        xmlbody +='<Relationship Target="slideMasters/slideMaster1.xml" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Id="rId1"/>'
                +'<Relationship Target="tableStyles.xml" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/tableStyles" Id="rId6"/>'
                +'<Relationship Target="theme/theme1.xml" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Id="rId5"/>'
                +'<Relationship Target="viewProps.xml" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/viewProps" Id="rId4"/>'
                +'</Relationships>';
                        
    }
}