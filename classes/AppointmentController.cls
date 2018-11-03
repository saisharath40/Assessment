public class AppointmentController {

    public Id contactId {get; set;}
    public Contact contactRecord {get; set;}
    public String sHour {get; set;}
    public String sMinute {get; set;}
    public String eHour {get; set;}
    public String eMinute {get; set;}
    public String sAMPM {get; set;}
    public String eAMPM {get; set;}
    public String subj {get; set;}
    public String show {get; set;}
    public String year {get;set;}
    public String dateSelected {get;set;}
    public String month {get;set;}
    
    public AppointmentController() {
        contactId = ApexPages.currentPage().getParameters().get('id');
        sHour = ApexPages.currentPage().getParameters().get('stH');
        sMinute = ApexPages.currentPage().getParameters().get('smM');
        eHour = ApexPages.currentPage().getParameters().get('enH');
        eMinute = ApexPages.currentPage().getParameters().get('enM');
        year=ApexPages.currentPage().getParameters().get('year');
        dateSelected=ApexPages.currentPage().getParameters().get('date');
        month=ApexPages.currentPage().getParameters().get('month');
        if(eHour==null){
            eHour=String.valueOf(Integer.valueOf(sHour)+1); 
            if(Integer.valueOf(ehour)==24){
                eHour=String.valueOf(0);
            }
        }
        if(eMinute==null){
			eMinute=String.valueOf(Integer.valueOf(sMinute));        
        }
        if(Integer.valueOf(shour)>=12){
			sAMPM='PM';
             if(Integer.valueOf(shour)!=12)
            sHour=String.valueOf(Integer.valueof(sHour)-12);
        }
        else{
			sAMPM='AM';
        }

       if(Integer.valueOf(ehour)>=12){
	   	   eAMPM='PM';
           if(Integer.valueOf(ehour)!=12)
           eHour=String.valueOf(Integer.valueof(eHour)-12);
        }
        else{
			eAMPM='AM';
        }                
       subj = 'Appointment';
        show = 'Busy';
        contactRecord = [SELECT Id, FirstName, LastName,Owner.Name,Email,Phone FROM Contact WHERE Id =: contactId];
    }
    
    public List<SelectOption> getHours() {
        List<SelectOption> hours = new List<SelectOption>();
         hours.add(new SelectOption('0', '0'));
        hours.add(new SelectOption('1', '1'));	hours.add(new SelectOption('2', '2'));
        hours.add(new SelectOption('3', '3'));	hours.add(new SelectOption('4', '4'));
        hours.add(new SelectOption('5', '5'));	hours.add(new SelectOption('6', '6'));
        hours.add(new SelectOption('7', '7'));	hours.add(new SelectOption('8', '8'));
        hours.add(new SelectOption('9', '9'));	hours.add(new SelectOption('10', '10'));
        hours.add(new SelectOption('11', '11'));	hours.add(new SelectOption('12', '12'));
        
        return hours;
    }
    
    public List<SelectOption> getMinutes() {
        List<SelectOption> minutes = new List<SelectOption>();
        for(integer i = 0; i < 61; i++) {
            minutes.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        
        return minutes;
    }
    
    public List<SelectOption> getAMPM() {
        List<SelectOption> ampm = new List<SelectOption>();
        ampm.add(new SelectOption('AM', 'AM'));
        ampm.add(new SelectOption('PM', 'PM'));
        
        return ampm;
    }
    
    public List<SelectOption> getSubjects() {
        List<SelectOption> subjects = new List<SelectOption>();
        subjects.add(new SelectOption('Appointment', 'Appointment'));
        subjects.add(new SelectOption('Call', 'Call'));
        subjects.add(new SelectOption('Email', 'Email'));
        subjects.add(new SelectOption('Meeting', 'Meeting'));
        subjects.add(new SelectOption('Send Letter/Quote', 'Send Letter/Quote'));
        subjects.add(new SelectOption('Other', 'Other'));
        
        return subjects;
    }
    
    public List<SelectOption> getShowAs() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Busy', 'Busy'));
        options.add(new SelectOption('Out of Office', 'Out of Office'));
        options.add(new SelectOption('Free', 'Free'));
        
        return options;
    }
    
    public Pagereference saveAppointment(){
        Event e=new Event();
        try{
            e.WhoId=contactId;
            e.ownerId=UserInfo.getUserId();
            if(sAMPM=='PM'){
                if(Integer.valueOf(shour)!=12){
                	shour=String.valueOf(Integer.valueOf(shour)+12);
                }
            }
             if(eAMPM=='PM'){
                if(Integer.valueOf(ehour)!=12){
                	ehour=String.valueOf(Integer.valueOf(ehour)+12);
                }
            }
            if(Integer.valueOf(eHour) < Integer.valueOf(sHour)){
                 e.StartDateTime= DateTime.newInstanceGMT(Integer.valueOf(year), Integer.valueOf(month)+1, Integer.valueOf(dateSelected), Integer.valueOf(sHour), Integer.valueOf(sMinute), 0);
                 e.EndDateTime= DateTime.newInstanceGMT(Integer.valueOf(year), Integer.valueOf(month)+1, Integer.valueOf(dateSelected)+1, Integer.valueOf(eHour),Integer.valueOf(eMinute), 0);
            }
            else{
                 e.StartDateTime= DateTime.newInstanceGMT(Integer.valueOf(year), Integer.valueOf(month)+1, Integer.valueOf(dateSelected), Integer.valueOf(sHour), Integer.valueOf(sMinute), 0);
            	e.EndDateTime= DateTime.newInstanceGMT(Integer.valueOf(year), Integer.valueOf(month)+1, Integer.valueOf(dateSelected), Integer.valueOf(eHour),Integer.valueOf(eMinute), 0);
            }
            
           	//System.debug(e.startDateTime+' '+e.EndDateTime);
            //System.debug(DateTime.now());
            subj+=' with '+contactRecord.FirstName+' '+contactRecord.LastName;
            e.Subject=subj;
            e.Description='New Event Added with '+contactRecord.FirstName;
            if(e.StartDateTime < DateTime.now() || e.EndDateTime < DateTime.now())
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'StartDate/EndDate is a past date. Please close the window & create an Appointment at a future date'));
            	throw new InvalidDtException('Invalid Date');
            }
            else{
                insert e;
                List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //Set list of people who should get the email
                List<String> sendTo = new List<String>();
                sendTo.add(contactRecord.Email);
                mail.setToAddresses(sendTo);
                mail.setReplyTo('sharath.sai12@gmail.com');
                mail.setSenderDisplayName('Joe');
                mail.setSubject('Meeting Appointment');
               /* List<String> ccAddress=new List<String>();
                ccAddress.add('emailtosalesforce@w-324xzba3xt9ciep16loiacsjy8q0d1e5rcl3ye5fszcmfooyos.6f-2z8nruak.ap4.le.salesforce.com');
                ccAddress.add(contactRecord.Email);
                ccAddress.add(contactRecord.Id);
                mail.setCcAddresses(ccAddress);*/
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        		attach.filename = 'meeting.ics';
        		attach.ContentType = 'text/calendar;';
        		attach.inline = true;
        		attach.body=invite(e.StartDateTime,e.EndDateTime,contactRecord.Email);
        		mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
                String body = 'Dear ' +contactRecord.FirstName + ' '+contactRecord.LastName+' ,';
                    body+=' \n'+' Your Appointment with Joe is Scheduled .For more details, please logon to Salesforce' ;
                	/*body+='<a href="'+URL.getSalesforceBaseUrl()+'/services/apexrest/Events/'+e.Id+'?Confirm=Yes">Accept</a>';
                	body+='\n';
                	body+='<a href="'+URL.getSalesforceBaseUrl()+'/services/apexrest/Events/'+e.Id+'?Confirm=No">Reject</a>';
                	body+='\n';*/
                mail.setHtmlBody(body);
                mails.add(mail);
                Messaging.SendEmailResult[] results=Messaging.sendEmail(mails);
                for(Messaging.SendEmailResult result:results){
                    system.debug(result);
                }
                return new PageReference('/lightning/r/Event/'+e.id+'/view');
            }
        }
        catch(InvalidDtException exc){
            System.debug(exc.getMessage());
            return null;
            
        }
        catch(Exception exc){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,exc.getMessage()));
            return null;
        }
            
    }
    public Blob invite(Datetime startTime, DateTime endTime,String recipient){
        String nowString = '';
        System.debug(startTime+' '+endTime);
        Datetime nowDT = Datetime.now();
        nowString += nowDT.year();
        nowString += ('0' + nowDT.month()).right(2);
        nowString += ('0' + nowDT.day()).right(2);
        nowString += 'T';
        nowString += ('0' + nowDT.hour()).right(2);
        nowString += ('0' + nowDT.minute()).right(2);
        nowString += ('0' + nowDT.second()).right(2);
        nowString += 'Z';
       //nowString+='+05:30';
            
        String startString = '';
        startString += startTime.year();
        startString += ('0' + startTime.month()).right(2);
        startString += ('0' + startTime.day()).right(2);
        startString += 'T';
        startString += ('0' + startTime.hour()).right(2);
        startString += ('0' + startTime.minute()).right(2);
        startString += ('0' + startTime.second()).right(2);
       	startString += 'Z';
        //startString+='+05:30';
    
        String endString = '';
        endString += endTime.year();
        endString += ('0' + endTime.month()).right(2);
        endString += ('0' + endTime.day()).right(2);
        endString += 'T';
        endString += ('0' + endTime.hour()).right(2);
        endString += ('0' + endTime.minute()).right(2);
        endString += ('0' + endTime.second()).right(2);
        endString += 'Z';
        //endString+='+05:30';
        String txtInvite = '';
        txtInvite += 'BEGIN:VCALENDAR\n';
        txtInvite += 'PRODID:-//Google Inc//Google Calendar 70.9054//EN\n';
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'CALSCALE:GREGORIAN\n';
        txtInvite += 'METHOD:REQUEST\n';
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'DTSTART:' +startString  + '\n';
        txtInvite += 'DTEND:' + endString + '\n';
        txtInvite += 'DTSTAMP:' + startString+ '\n';
        txtInvite += 'ORGANIZER;CN=' + UserInfo.getUserName() + ':MAILTO:' + UserInfo.getUserEmail() + '\n';
        txtInvite += 'ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=\n';
        txtInvite += ' TRUE;X-NUM-GUESTS=0:mailto:' + recipient + '\n';
        txtInvite += 'CREATED:' + nowString + '\n';
        txtInvite += 'LAST-MODIFIED:' + nowString + '\n';
        txtInvite += 'LOCATION:ONLINE\n';
        txtInvite += 'STATUS:CONFIRMED\n';
        txtInvite += 'SUMMARY: Meeting Invite with ' + recipient + '\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR\n';
        return Blob.valueOf(txtInvite);
    } 
}