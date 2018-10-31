public class CalendarController {

    public list<calEvent> events {get;set;}
     public Id contactID {get; set;}
    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated correctly
    String dtFormat = 'EEE, d MMM yyyy HH:mm:ss z';
     
    //constructor
    public CalendarController(ApexPages.StandardController stdController) {
        contactId=stdController.getId();
    }
     
    public void pageLoad() {
        events = new list<calEvent>();
            for(Event evnt: [select Id, Subject, isAllDayEvent, StartDateTime, EndDateTime from Event where OwnerID = :UserInfo.getUserId()]){
                DateTime startDT = evnt.StartDateTime;
                DateTime endDT = evnt.EndDateTime;
                calEvent myEvent = new calEvent();
                 
                myEvent.title = evnt.Subject;
                myEvent.allDay = evnt.isAllDayEvent;
                myEvent.start = startDT.format(dtFormat);
                myEvent.endDt = endDT.format(dtFormat);
                myEvent.url = '/' + evnt.Id;
                myEvent.className = 'event-personal';
                events.add(myEvent);
            }
        System.debug(events.size());
    }
     
    
 
     
    //Class to hold calendar event data
    public class calEvent{
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public String start {get;set;}
        public String endDt {get;set;}
        public String url {get;set;}
        public String className {get;set;}
    }
}