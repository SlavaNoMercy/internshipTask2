@isTest
public class LeadRestApiTest {
	@isTest static void testGetLeadById() {
        Lead record = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://senla8-dev-ed.my.salesforce.com/services/apexrest/LeadRest';
        request.httpMethod = 'POST';
        String reqBody = JSON.serialize(record);
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        // Call the method to test
        Lead thisLead = LeadRestApi.getLeadByIdOrEmail();
        // Verify results
        System.assert(thisLead != null);

    }
    @isTest static void testGetLeadByEmail() {
        Lead record = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://senla8-dev-ed.my.salesforce.com/services/apexrest/LeadRest';
        request.httpMethod = 'POST';
        String reqBody = JSON.serialize(record);
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        // Call the method to test
        Lead thisLead = LeadRestApi.getLeadByIdOrEmail();
        // Verify results
        System.assert(thisLead != null);
        System.assertEquals('testLead@mails.ru', thisLead.Email);
    }
    
    @isTest static void createTaskForLead() {
        Lead record = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://senla8-dev-ed.my.salesforce.com/services/apexrest/LeadRest';
        request.httpMethod = 'POST';
        String reqBody = JSON.serialize(record);
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        
        Task taskRecord = createTestRecordTask(record);
        // Call the method to test
        Task thisTask = LeadRestApi.createTaskForLead();
        // Verify results
        System.assert(thisTask != null);
        System.assertEquals('Other',thisTask.Subject);
    }
    
    static Lead createTestRecord(){
        Lead newLead = new Lead(Email='testLead@mails.ru',
                               OwnerId='0055j000005ZNfWAAW');
        newLead.LastName = 'TestLead';
        newLead.Company = 'qwe';
        insert newLead;
        return newLead;
    }
    static Task createTestRecordTask(Lead targetLead){
        Task newTask = new Task(Subject = 'Other' ,
                               Status = 'Not Started',
                               WhoID = targetLead.Id, 
                               OwnerId = targetLead.OwnerId);
        insert newTask;
        return newTask;
    }
}