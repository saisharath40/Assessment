public class CalendarController {

    public list<calEvent> events {get;set;}
     public Id contactID {get; set;}
    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formatted correctly
    String dtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';
     
    //constructor
    public CalendarController(ApexPages.StandardController stdController) {
        contactId=stdController.getId();
    }
     
    public void pageLoad() {
        events = new list<calEvent>();
        //List of Events already scheduled
            for(Event evnt: [select Id, Subject, isAllDayEvent, StartDateTime, EndDateTime from Event where OwnerID = :UserInfo.getUserId()]){
                DateTime startDT = evnt.StartDateTime;
                DateTime endDT = evnt.EndDateTime;
                calEvent myEvent = new calEvent();
                 
                myEvent.title = evnt.Subject;
                myEvent.allDay = evnt.isAllDayEvent;
                myEvent.startString = startDT.format(dtFormat);
                myEvent.endString = endDT.format(dtFormat);
                myEvent.url = '/' + evnt.Id;
                myEvent.className = 'Meeting';
                events.add(myEvent);
            }
       // System.debug(events.size());
    }
     
    
}