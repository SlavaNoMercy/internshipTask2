global class InformContactOwners implements Database.Batchable<sObject>, Schedulable {

    List<String> owners = new List<String>();
    Map<Contact,String> ownersAndContacts = new Map<Contact,String>();
    static final String cronStr = '0 0 12 * * ?';

    global database.querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(
            'SELECT ID, LastName, OwnerId '+
            ' FROM Contact WHERE Possible_Outdated__c="True"'
        );
    }
    global void execute(SchedulableContext ctx) {
        InformContactOwners informContactOwners = new InformContactOwners();
        //String cronStr = '0 0 12 * * ?';
        String jobID = System.schedule('Send Notifications', cronStr, informContactOwners); 
 	}
 
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {
		List<Contact> contacts = new List<Contact>();        
        for (Contact contact : scope) {
            if (owners.contains(contact.OwnerId)) {
                ownersAndContacts.put(contact,(String)contact.OwnerId);
            }
            else {
                owners.add((String)contact.OwnerId);
                ownersAndContacts.put(contact,(String)contact.OwnerId);
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
       
        AsyncApexJob a = [SELECT a.TotalJobItems, 
                                 a.Status
                          FROM AsyncApexJob a 
                          WHERE id = :BC.getJobId()];

        for (String owner : owners) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String [] ownerArray = new String [] {owner};
            mail.setToAddresses(ownerArray);
            mail.setSenderDisplayName('Apex Batch Processing Module');
            mail.setSubject('Batch Processing '+ a.Status + 
            '\nThe list of possible outdated Contacts that needs review!');
            String body = 'Contacts that need review: ';
            for (Contact con : ownersAndContacts.keySet()) {
                if(ownersAndContacts.get(con)==owner){
                    body += '['+ con.LastName +
                    '](https://senla8-dev-ed.lightning.force.com/lightning/r/Contact/'+
                    con.Id + '/view)' + ' ';
                }
            /*    for (Contact con : contactsOfCurrentOwner) {
                    body += '['+ con.LastName +
                    '](https://senla8-dev-ed.lightning.force.com/lightning/r/Contact/'+
                    con.Id + '/view)' + ' ';  
                }*/
            }
            mail.setPlainTextBody(body);
            mailsToSend.add(mail);
        }
        //String[] email = owners;
        //mail.setReplyTo('Your email for reply'); 
        Messaging.sendEmail(mailsToSend);

    }
    
}