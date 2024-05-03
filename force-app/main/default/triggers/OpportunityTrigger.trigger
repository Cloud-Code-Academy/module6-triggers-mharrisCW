trigger OpportunityTrigger on Opportunity (before update, before delete) {
    if(Trigger.isUpdate && Trigger.isBefore){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity opp : Trigger.new){
            if(opp.Amount < 5000){
                oppsToUpdate.add(opp);
            }
        }
        if(!oppsToUpdate.isEmpty()){
            for(Opportunity oppToUpdate : oppsToUpdate){
                oppToUpdate.Amount.addError('Opportunity amount must be greater than 5000');
            }
        }
       Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : Trigger.new){
            accountIds.add(opp.AccountId);      
            }
        Map<Id,Contact> ceosMap = new Map<Id, Contact>();
        for(Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :AccountIds AND Title = 'CEO']){
            ceosMap.put(c.AccountId, c);
        }
        for(Opportunity opp : Trigger.new){
            if(ceosMap.containsKey(opp.AccountId)){
                opp.Primary_Contact__c = ceosMap.get(opp.AccountId).Id;
                oppsToUpdate.add(opp);
                System.debug('Setting primary contat for opportunity ' + opp.id + ' to CEO contact ' + ceosMap.get(opp.AccountId).Id);
            }
        }
    }        

    if(Trigger.isBefore && Trigger.isDelete){
        Set<Id> bankingAccountIds = new Set<Id>();
        for(Opportunity opp : Trigger.old){ 
            bankingAccountIds.add(opp.AccountId);
        } 
        Map<Id, Account> mapOfAccounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :bankingAccountIds]);
        for(Opportunity opp : Trigger.old){ 
            Account oppAcc = mapOfAccounts.get(opp.AccountId);
            if(opp.StageName == 'Closed Won' && oppAcc.Industry == 'Banking'){
                opp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }      
    }
}   
 