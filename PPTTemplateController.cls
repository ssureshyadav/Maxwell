public class PPTTemplateController {

    public String body { get; set; }

    public String xmlHeader {get; set;}
    public List<String> textList {get; set;}
    public List<String> imageList {get; set;}

    public PPTTemplateController() {
        body ='';
        xmlHeader = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
        String serializeTextList = ApexPages.currentPage().getParameters().get('textList');
        String serializeimageList = ApexPages.currentPage().getParameters().get('imageList');
        if(serializeTextList == null){
            List<String> lstParams=new List<String>{'Apex', 'Create', 'XLSX', 'Suresh','ImageName'};
            textList =lstParams;
        }else{
            textList = (List<String>) System.JSON.deserialize(serializeTextList, List<String>.class);
        }
        
        if(serializeimageList == null){
            List<String> lstParams=new List<String>{'picture 2##rId2'};
            imageList=lstParams;
        }else{
            imageList = (List<String>) System.JSON.deserialize(serializeimageList , List<String>.class);
        }
        populateBody(textList,imageList);
            
    }
    
    public void populateBody(List<String> params,List<String> images){
        
          body ='<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">'
                  +'<p:cSld><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>'
                  +'<p:sp><p:nvSpPr><p:cNvPr id="6" name="TextBox 5"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr><p:spPr><a:xfrm><a:off x="-24063" y="49506"/><a:ext cx="8660336" cy="369332"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom>'
                  +'<a:noFill/></p:spPr><p:txBody><a:bodyPr wrap="square" rtlCol="0"><a:spAutoFit/></a:bodyPr><a:lstStyle/><a:p><a:r><a:rPr lang="en-IN" dirty="0"><a:solidFill><a:srgbClr val="66B2FF"/></a:solidFill></a:rPr>'
                  +'<a:t>'+params[0]+'</a:t></a:r><a:r><a:rPr lang="en-IN" dirty="0"><a:solidFill><a:srgbClr val="00FFE1"/></a:solidFill></a:rPr><a:t> </a:t></a:r><a:r><a:rPr lang="en-IN" dirty="0"><a:solidFill><a:srgbClr val="D3D3D3"/></a:solidFill>'
                  +'</a:rPr><a:t>|</a:t></a:r><a:r><a:rPr lang="en-IN" dirty="0"/><a:t> </a:t></a:r><a:r><a:rPr lang="en-IN" b="1" dirty="0"/><a:t>'+params[1]+'</a:t></a:r></a:p></p:txBody></p:sp><p:cxnSp><p:nvCxnSpPr><p:cNvPr id="9" name="Straight Connector 8"/>'
                  +'<p:cNvCxnSpPr/><p:nvPr/></p:nvCxnSpPr><p:spPr><a:xfrm><a:off x="15171" y="'+ (params[1].length() < 75 ?'418838':(params[1].length() < 150 ? '885970':'1244412')) +'"/><a:ext cx="9144000" cy="0"/></a:xfrm><a:prstGeom prst="line"><a:avLst/>'
                  +'</a:prstGeom><a:ln><a:solidFill><a:srgbClr val="D3D3D3"/></a:solidFill></a:ln></p:spPr><p:style><a:lnRef idx="1"><a:schemeClr val="accent1"/></a:lnRef><a:fillRef idx="0"><a:schemeClr val="accent1"/></a:fillRef><a:effectRef idx="0">'
                  +'<a:schemeClr val="accent1"/></a:effectRef><a:fontRef idx="minor"><a:schemeClr val="tx1"/></a:fontRef></p:style></p:cxnSp><p:sp><p:nvSpPr><p:cNvPr id="15" name="TextBox 14"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr><p:spPr><a:xfrm>'
                  +'<a:off x="-17603" y="1244412"/><a:ext cx="8928992" cy="307777"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/></p:spPr><p:txBody><a:bodyPr wrap="square" rtlCol="0"><a:spAutoFit/></a:bodyPr><a:lstStyle/>'
                +'<a:p><a:r><a:rPr lang="en-IN" sz="1400" b="1" dirty="0"/><a:t>Inventor(s): </a:t></a:r><a:r><a:rPr lang="en-IN" sz="1400" dirty="0"/><a:t>'+ params[2] +'</a:t></a:r></a:p></p:txBody></p:sp><p:sp><p:nvSpPr><p:cNvPr id="16" name="TextBox 15"/>'
                +'<p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr><p:spPr><a:xfrm><a:off x="15171" y="2377763"/><a:ext cx="4164015" cy="523220"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/></p:spPr><p:txBody><a:bodyPr wrap="square" rtlCol="0">'
                +'<a:spAutoFit/></a:bodyPr><a:lstStyle/><a:p>'
                +'<a:r><a:rPr lang="en-IN" sz="1400" b="1" dirty="0"/><a:t>Invention: </a:t></a:r></a:p><a:p><a:r><a:rPr lang="en-IN" sz="1400" dirty="0"/><a:t>'+params[4]+'</a:t></a:r></a:p></p:txBody></p:sp><p:sp><p:nvSpPr><p:cNvPr id="17" name="TextBox 16"/>'
                +'<p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr><p:spPr><a:xfrm><a:off x="0" y="1811087"/><a:ext cx="4164015" cy="307777"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/></p:spPr><p:txBody><a:bodyPr wrap="square" rtlCol="0">'
                +'<a:spAutoFit/></a:bodyPr><a:lstStyle/><a:p><a:r><a:rPr lang="en-IN" sz="1400" b="1" dirty="0"/><a:t>Project Name: </a:t></a:r><a:endParaRPr lang="en-IN" sz="1400" dirty="0"/></a:p><a:p><a:r><a:rPr lang="en-IN" sz="1400" dirty="0"/>'
                +'<a:t>'+params[3]+'</a:t></a:r></a:p></p:txBody></p:sp>';
                for(String image:images){
                    String[] splitImageName=image.split('##');
                body += '<p:pic>'
                    +'<p:nvPicPr>'
                    +'<p:cNvPr name="'+splitImageName[0]+'" id="10">'
                    +'<a:extLst>'
                    +'<a:ext uri="{FF2B5EF4-FFF2-40B4-BE49-F238E27FC236}">'
                    +'<a16:creationId id="{9C88443A-6C37-46DD-BA9B-835C02B88858}" xmlns:a16="http://schemas.microsoft.com/office/drawing/2014/main"/>'
                    +'</a:ext>'
                    +'<a:ext uri="{FF2B5EF4+FFF2+40B4+BE49+F238E27FC236}">'
                    +'<a16:creationId id="{97827992+35DD+438F+9A3B+3879423C5F78}" xmlns:a16="http://schemas.microsoft.com/office/drawing/2014/main" xmlns=""/>'
                    +'</a:ext>'
                    +'</a:extLst>'
                    +'</p:cNvPr>'
                    +'<p:cNvPicPr>'
                    +'<a:picLocks noChangeAspect="1"/>'
                    +'</p:cNvPicPr>'
                    +'<p:nvPr/>'
                    +'</p:nvPicPr>'
                    +'<p:blipFill>'
                    +'<a:blip r:embed="'+splitImageName[1]+'">'
                    +'<a:extLst>'
                    +'<a:ext uri="{28A0092B+C50C+407E+A947+70E740481C1C}">'
                    +'<a14:useLocalDpi val="0" xmlns="" xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main"/>'
                    +'</a:ext>'
                    +'</a:extLst>'
                    +'</a:blip>'
                    +'<a:stretch>'
                    +'<a:fillRect/>'
                    +'</a:stretch>'
                    +'</p:blipFill>'
                    +'<p:spPr>'
                    +'<a:xfrm>'
                    +'<a:off y="1811128" x="4678025"/>' //  
                    +'<a:ext cy="3952875" cx="3760838"/>' //3952875 
                    +'</a:xfrm>'
                    +'<a:prstGeom prst="rect">'
                    +'<a:avLst/>'
                    +'</a:prstGeom>'
                    +'</p:spPr>'
                    +'</p:pic>';
                }
                body +='</p:spTree>'
                +'<p:extLst>'
                +'<p:ext uri="{BB962C8B-B14F-4D97-AF65-F5344CB8AC3E}">'
                +'<p14:creationId val="2674253215" xmlns:p14="http://schemas.microsoft.com/office/powerpoint/2010/main"/>'
                +'</p:ext>'
                +'</p:extLst>'
                +'</p:cSld>'
                +'<p:clrMapOvr>'
                +'<a:masterClrMapping/>'
                +'</p:clrMapOvr>'
                +'</p:sld>';
    }
}