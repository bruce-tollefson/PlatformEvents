public class PlatformEventService {

    public static void publishEvent(sObject event, Set<Id> identifierSet, String loggingStr){
        publishEvent(new List<sObject>{event}, IdConverter.convertIdToString(identifierSet), loggingStr);
    }
    
    public static void publishEvent(sObject event, Set<String> identifierSet, String loggingStr){
        publishEvent(new List<sObject>{event}, identifierSet, loggingStr);
    }
    
    public static void publishEvent(List<sObject> eventList, Set<Id> identifierSet, String loggingStr){
        publishEvent(eventList, IdConverter.convertIdToString(identifierSet), loggingStr);
    }
    
    public static void publishEvent(List<sObject> eventList, Set<String> identifierSet, String loggingStr){
        List<Database.SaveResult> results = EventBus.publish(eventList);
        List<Database.Error> errorPayloadList = new List<Database.Error>();
        
        Boolean error = false;
        for(Database.SaveResult sr :results){
            if(!sr.isSuccess()){
                error = true;
                for(Database.Error err : sr.getErrors()){
                    errorPayloadList.add(err);
                }
            }
        }
        if(error){
            //Logging service goes here PEs don't have Ids so this is different than regular logging - can use         String platformEventType = String.ValueOf(eventList.getsObjectType()); to log the type of event as an example , loggingStr could be the name of the method/class that created the error, identifierSet could the the list Ids that created the PEs or an external Id, etc.
        }
    }
}
