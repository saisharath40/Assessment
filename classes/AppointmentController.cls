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
        if(eHour!=null){
           if(Integer.valueOf(ehour)>=12){
			eAMPM='PM';
            if(Integer.valueOf(ehour)!=12)
            eHour=String.valueOf(Integer.valueof(eHour)-12);
        }
        else{
			eAMPM='AM';
        } 
            
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
                
                shour=String.valueOf(Integer.valueOf(shour)+12);
            }
             if(eAMPM=='PM'){
                
                ehour=String.valueOf(Integer.valueOf(ehour)+12);
            }
            e.StartDateTime= DateTime.newInstance(Integer.valueOf(year), Integer.valueOf(month)+1, Integer.valueOf(dateSelected), Integer.valueOf(sHour), Integer.valueOf(sMinute), 0);
            e.EndDateTime= DateTime.newInstance(Integer.valueOf(year), Integer.valueOf(month)+1, Integer.valueOf(dateSelected), Integer.valueOf(eHour),Integer.valueOf(eMinute), 0);
           
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
                String body = 'Dear ' +contactRecord.FirstName + ' '+contactRecord.LastName+', \n Your Appointment with Joe is Confirmed between '+e.StartDateTime+' and '+e.EndDateTime+' .For more details, please logon to Salesforce' ;
                mail.setHtmlBody(body);
                mails.add(mail);
                Messaging.SendEmailResult[] results=Messaging.sendEmail(mails);
                for(Messaging.SendEmailResult result:results){
                    system.debug(result);
                }
                return new PageReference('/lightning/r/Event/'+e.id+'/view');
            }
           // return new PageReference('/lightning/r/Event/'+e.id+'/view');
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
}