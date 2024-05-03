trigger AccountTrigger on Account (before insert, after insert) {
    If(Trigger.isBefore && Trigger.isInsert){
        for(Account acc : Trigger.new){
            if(acc.Type == null){
                acc.Type = 'Prospect';
            }
            if(acc.ShippingStreet != null && acc.ShippingCity != null && acc.ShippingState != null && acc.ShippingPostalCode != null && acc.ShippingCountry != null){
                acc.BillingCity = acc.ShippingCity;
                acc.BillingState = acc.ShippingState;
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingCountry = acc.ShippingCountry;
            }
            if(acc.Phone != null && acc.Website != null && acc.Fax != null){
                acc.Rating = 'Hot';
            }   
            System.debug('Account ID: ' + acc.Id);
        } 
    }   
    If(Trigger.isAfter && Trigger.isInsert){
        List<Contact> contactsToInsert = new List<Contact>(); 
        For(Account acc : Trigger.new){
            Contact newContact = new Contact(
                LastName = 'DefaultContact',
                Email = 'default@email.com',
                AccountId = acc.Id
            );

            System.debug('Contact Account Id: ' + newContact.AccountId);
            contactsToInsert.add(newContact);
        }
        if(!contactsToInsert.isEmpty()){
            insert contactsToInsert;
        }
    }
}
