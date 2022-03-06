trigger OpportunityChangeEventTrigger on OpportunityChangeEvent (after insert) {

    List<Generic_Event__e> geList = new List<Generic_Event__e>();
    Set<Id> OpportunityIdSet = new Set<Id>();
    for(OpportunityChangeEvent event  :Trigger.New){
        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
        checkRecordIds(header.recordIds);//headers could have multiple recordIds
    }
    
    Map<Id, Opportunity> ownerMap = new Map<Id, Opportunity>([Select Id, Owner.External_Id__c from Opportunity]);
    for(OpportunityChangeEvent event  :Trigger.New){
        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
        for(String recordId :header.recordIds){//there is potential for multiple messages to be sent with the same record Id and the owner may be different so they all will need to be separated
            Generic_Event__e ge = new Generic_Event__e(Generic_Payload_Text_1__c=JSON.serialize(event,true),//serialize event to string
                                                      External_Owner_Id__c= ownerMap.get(recordId).Owner.External_Id__c);//add the external Id to the event
            geList.add(ge);//add to list for publish
        }
    }
    
    pubishEvents(geList);
    
    
    private static void checkRecordIds(List<String> recordIdList){
        for(String headerId :recordIdList){
            try{
                Id recordId = (Id)headerId;
                OpportunityIdSet.add(recordId);
            }catch(Exception e){
                //We encountered an invalid Id likely this was due to a wildcard id: https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_event_fields_header.htm
            	//do something with the events that don't have full headers
            }
        }
    }
    
    private static void pubishEvents(List<Generic_Event__e> genericEventList){
        
        List<Database.SaveResult> results = EventBus.publish(genericEventList);
        for(Database.SaveResult sr : results){
            if(!sr.isSuccess()){
                //do something with unsuccessful publishes
            }
        }
    }
}