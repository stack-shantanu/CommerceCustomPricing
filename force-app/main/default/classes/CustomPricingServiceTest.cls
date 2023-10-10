@IsTest
private class CustomPricingServiceTest {

    @IsTest
    static void testProcessPrice() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account', Legal_Name__c = 'Test Name');
        insert testAccount;

        // Create test products
        Product2 testProduct1 = new Product2(Name = 'Product 1');
        Product2 testProduct2 = new Product2(Name = 'Product 2');
        insert new List<Product2>{ testProduct1, testProduct2 };

        // Create test price records
        Account_Product_Price__c testPrice1 = new Account_Product_Price__c(
            Account__c = testAccount.Id,
            Product__c = testProduct1.Id,
            Price__c = 15.00
        
        );
        Account_Product_Price__c testPrice2 = new Account_Product_Price__c(
            Account__c = testAccount.Id,
            Product__c = testProduct2.Id,
            Price__c = 20.00
        );
        insert new List<Account_Product_Price__c>{ testPrice1};

        // Create a test pricing request
        commercestorepricing.PricingRequest testRequest = new commercestorepricing.PricingRequest();
        testRequest.setEffectiveAccountId(testAccount.Id);

        List<commercestorepricing.PricingRequestItem> testItems = new List<commercestorepricing.PricingRequestItem>();
        commercestorepricing.PricingRequestItem testItem1 = new commercestorepricing.PricingRequestItem(testProduct1.Id);
        testItems.add(testItem1);

        commercestorepricing.PricingRequestItem testItem2 = new commercestorepricing.PricingRequestItem(testProduct2.Id);
        testItems.add(testItem2);

        testRequest.addPricingRequestItem(testItem1);
        testRequest.addPricingRequestItem(testItem2);

        // Call the processPrice() method
        CustomPricingService customPricingService = new CustomPricingService();
        commercestorepricing.PricingResponse testResponse = customPricingService.processPrice(testRequest);
  	
		List<commercestorepricing.PricingResponseItem> responseItems = new List<commercestorepricing.PricingResponseItem>();

        // Retrieve a PricingResponseItem from the PricingResponseItemCollection
        commercestorepricing.PricingResponseItem responseItem = testResponse.getPricingResponseItems().get(0);
        
        // Add the responseItem to the list
        responseItems.add(responseItem);
    }
    
    @isTest static void testProcessTransactionalPrice() {
        Decimal defaultPrice = 333;
        
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account', Legal_Name__c = 'Test Name');
        insert testAccount;
        // Create test products
        Product2 testProduct1 = new Product2(Name = 'Product 1');
        insert testProduct1;
        
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        List<Webstore> webIds = [Select Id from Webstore];
        System.debug('Webstores');
        System.debug(webIds);
        
        // Create a TransactionalPricingRequest object
        commercestorepricing.TransactionalPricingRequest request = new commercestorepricing.TransactionalPricingRequest();
        request.setEffectiveAccountId(testAccount.Id);
        request.setWebStoreId(testWebStore.Id);
        request.setCurrencyIsoCode('USD');
        
        // Set up the TxnPricingRequestItemCollection and add a TransactionalPricingRequestItem

        commercestorepricing.TransactionalPricingRequestItem item = new commercestorepricing.TransactionalPricingRequestItem(testProduct1.Id, testProduct1.Id, 1);
        request.addTxnPricingRequestItem(item);
        
        // Insert a test Account_Product_Price__c record
        Account_Product_Price__c testPrice = new Account_Product_Price__c(Account__c = testAccount.Id, Product__c = testProduct1.Id, Price__c = defaultPrice);
        insert testPrice;
        
        // Call pricing method
        CustomPricingService customPricingService = new CustomPricingService();
        commercestorepricing.TransactionalPricingResponse response = customPricingService.processTransactionalPrice(request);
        
        // Assertions
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals(defaultPrice, response.getTotalAmount(), 'TotalAmount should be 333');
        System.assertEquals(defaultPrice, response.getTotalListPrice(), 'TotalListPrice should be 333');
        System.assertEquals(defaultPrice, response.getTotalProductAmount(), 'TotalProductAmount should be 333');
        
    }
}
