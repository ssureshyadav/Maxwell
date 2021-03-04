public class PieChartController {
public List<PieWedgeData> getPieData() {

List<PieWedgeData> data = new List<PieWedgeData>();
     list<Standard__c> totalsdos=[select id from Standard__c where Alias__c!='Other' AND (Status__c='Active' OR 
                        Status__c='Confidential') ];
    data.add(new PieWedgeData(' SDOs',totalsdos.size()));
 list<Standards_Working_Group__c> sdowg=[select id from Standards_Working_Group__c where (status__C='Active' OR 
                 status__c='Confidential')];
         data.add(new PieWedgeData(' SDO WG',sdowg.size()));
 list<Internal_Participant__c> parti=[select id from Internal_Participant__c where (Leadership_Position__c='Board Member'
              OR Leadership_Position__c='Chair' OR Leadership_Position__c='Secretary'  OR Leadership_Position__c='Editor' OR Leadership_Position__c='Other' )
                                            AND Participant_Status__c='Active'];
         data.add(new PieWedgeData(' Leadership Position',parti.size()));
 list<Standards_Working_Group__c> totamount=[select id from Standards_Working_Group__c where Dues_Amount__c!= null];
        data.add(new PieWedgeData('Total Amount',totamount.size()));
return data;
}
// Wrapper class
public class PieWedgeData {
public String name { get; set; }
public Integer data { get; set; }
public PieWedgeData(String name, Integer data) {
this.name = name;
this.data = data;
}
}
}