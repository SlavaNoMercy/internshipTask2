@RestResource(urlMapping='/LeadRest/*')
global class LeadRestApi {	
    @HttpPost
    global static Lead getLeadByIdOrEmail(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        //System.debug(JSON.deserializeuntyped(req.requestbody.toString()));
        Lead returnLead;
        
        String findLead = req.requestBody.tostring();
        //String findLeadjson = JSON.serialize(findLead);
        
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
}