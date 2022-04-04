global class InformContactOwners implements Database.Batchable<sObject>, Schedulable {

   // List<String> owners = new List<String>();
   // Map<Contact,String> ownersAndContacts = new Map<Contact,String>();
   // static final String CRONStr = '0 0 12 * * ?';
    Map<Id,List<Contact>> ownersAndContacts;
    Set<Id> owners;
    
    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(
            'SELECT ID, LastName, OwnerId '+
            ' FROM Contact WHERE Possible_Outdated__c=True'
        );
    }
 
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        
        ownersAndContacts = new Map<Id,List<Contact>>();
        owners = new Set<Id>();
        for(Integer i = 0;i<scope.size();i++){
            owners.add(scope.get(i).OwnerId);            
		}
        for(Id owner : owners){
            List<Contact> contacts = new List<Contact>();
            for(Contact con : scope){
                if(con.OwnerId==owner){
                    contacts.add(con);
                }
        	}
            ownersAndContacts.put(owner, contacts);
        }        
    }
    
    global void execute(System.SchedulableContext ctx){
        Database.executebatch(this);
/*
 * Execute Anonymous code: 
InformContactOwners ico = new InformContactOwners();
static final String CRONStr = '0 0 12 * * ?';
String jobID = System.schedule('Inform Contact Owners',CRONStr, ico);
*/
		        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

        for (Id owner : owners) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String [] ownerArray = new String [] {owner};
            mail.setToAddresses(ownerArray);
            mail.setSenderDisplayName('Apex Batch Processing Module');
            mail.setSubject('The list of possible outdated Contacts that needs review!');
            String body = 'Contacts that need review: ';
            for (Contact con : ownersAndContacts.get(owner)) { //я не поменял ссылку
                    body += '['+ con.LastName +
                    '](https://senla8-dev-ed.lightning.force.com/lightning/r/Contact/'+
                    con.Id + '/view)' + ' ';
            }
            mail.setPlainTextBody(body);
            mailsToSend.add(mail);
            System.debug('Email Sent');
        }
        //String[] email = owners;
        //mail.setReplyTo('Your email for reply'); 
        Messaging.sendEmail(mailsToSend);

    }
    
}