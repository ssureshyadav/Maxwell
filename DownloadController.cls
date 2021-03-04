public class DownloadController {

    public class Wrapper{
        @auraEnabled public List<sObject> lstRecords {get;set;}
        @auraEnabled public Map<String,String> mapFields {get;set;}
    }
    @AuraEnabled
    public static Wrapper fetchRecords(string objName,string fieldSetName,String relationshipField,String recordId) {
        
        /*Id objrecordid=Id.ValueOf('a440q0000001bHEAAY');
        String fieldsetName ='download_csv_fields';
        String objName = objrecordid.getSObjectType().getDescribe().getName();
        system.debug(objName);*/
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objName);
        Map<String, Schema.SObjectField> fields = sObjType.getDescribe().fields.getMap();
        System.debug(sObjType.getDescribe().fieldSets);
        Map<String, Schema.FieldSet> FsMap = sObjType.getDescribe().fieldSets.getMap();
        System.debug(FsMap);
        System.debug(FsMap.get(fieldsetName));
        Schema.FieldSet fieldSet =FsMap.get(fieldsetName);
       // System.debug(fieldSet.getFields());
        Map<String,String> mapFields=new Map<String,String>();
        for(Schema.FieldSetMember fieldMember:fieldSet.getFields()){
            
            if(Schema.DisplayType.REFERENCE == fieldMember.getType()){
                System.debug(fieldMember);
                System.debug(fieldMember.getSObjectField().getDescribe());
                Schema.DescribeFieldResult fieldDescribe =fieldMember.getSObjectField().getDescribe();
                if(fieldMember.getFieldPath().contains('.')){
                    String[] objNames=fieldMember.getFieldPath().split('\\.');
                    mapFields.put(objNames[0] +'.' +fieldDescribe.getRelationshipName()+'.Name',fieldMember.getLabel());
                    System.debug(objNames[0] +'.' +fieldDescribe.getRelationshipName()+'.Name');
                }else{
                    mapFields.put(fieldDescribe.getRelationshipName()+'.Name',fieldMember.getLabel());
                }
                System.debug(fieldDescribe.getRelationshipName());
                
                //mapFields.put(fieldMember.getFieldPath(),fieldMember.getLabel());
            }else{
                mapFields.put(fieldMember.getFieldPath(),fieldMember.getLabel());
            }
        }
        String fieldsQuery='';
        for(String keyfields:mapFields.keySet()){
            fieldsQuery +=keyfields+',';
        }
        System.debug(fieldsQuery );
        fieldsQuery =fieldsQuery.removeEnd(',');
       // System.debug('Select Id,' + fieldsQuery + ' FROM '+ objName + ' Where Id =' + '\'' + recordId + '\'');
        List<sObject> sobjList= Database.query('Select Id,' + fieldsQuery + ' FROM '+ objName + ' Where '+ relationshipField + ' =' + '\'' + recordId + '\'');
        System.debug(sobjList);
        Wrapper wrap=new Wrapper();
        wrap.lstRecords = sobjList;
        wrap.mapFields = mapFields;
        return wrap;
    }
}