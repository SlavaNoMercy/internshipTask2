@RestResource(urlMapping='/LeadRest/*')
global class LeadRestApi {	
    @HttpPost
    global static Lead getLeadByIdOrEmail(/*String body*/){  // 1)if method accepts body
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //req.requestBody.set(body);                         // 2) apply accepted body

        Lead returnLead;
        
        String findLead = req.requestBody.tostring();
        
        Map<String, Object> parMap = (Map<String, Object>) JSON.deserializeUntyped(findLead);
        String leadId = parMap.get('id').toString();
        String leadEmail = parMap.get('email').toString();
        if(leadId != null && leadId.length() == 18){
             returnLead = [SELECT Id, Name, OwnerId
                      FROM Lead
                      WHERE Id = :leadId
                      LIMIT 1];
        }
        else if(leadEmail != null && leadEmail.contains('@')){
             returnLead = [SELECT Id, Name, OwnerId
                      FROM Lead
                      WHERE Email = :leadEmail
                      LIMIT 1];
        }
        else {
            System.debug('Cannot find the Lead!');
            returnLead =  null;
        }
        
        System.debug(returnLead);
        res.statusCode = 200;
        return returnLead;    
    }
    @HttpPut
    global static Task createTaskForLead(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;                         

        Lead targetLead;
        
        String findLead = req.requestBody.tostring();
        
        Map<String, Object> parMap = (Map<String, Object>) JSON.deserializeUntyped(findLead);
        String leadId = parMap.get('id').toString();
        String leadEmail = parMap.get('email').toString();
        if(leadId != null && leadId.length() == 18){
             targetLead = [SELECT Id, Name, OwnerId
                      FROM Lead
                      WHERE Id = :leadId
                      LIMIT 1];
        }
        else if(leadEmail != null && leadEmail.contains('@')){
             targetLead = [SELECT Id, Name, OwnerId
                      FROM Lead
                      WHERE Email = :leadEmail
                      LIMIT 1];
        }
        else {
            System.debug('Cannot find the Lead!');
            targetLead =  null;
        }
        
        Task newTask = new Task(Subject = 'Other' ,
                               Status = 'Not Started',
                               WhoID = targetLead.Id, 
                               OwnerId = targetLead.OwnerId);
        //insert newTask;  it works! but commented for test
        return newTask;
    }
}