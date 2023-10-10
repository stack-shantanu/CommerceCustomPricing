public class CustomPricingService extends commercestorepricing.PricingService {
    
    public override commercestorepricing.PricingResponse processPrice(
        commercestorepricing.PricingRequest request) {
            // get account ID from the request parameter
            String accountId = request.getEffectiveAccountId();
            
            // get all products from request parameter
            Set<String> products = new Set<String>();
            
            String pbeId = '01s3x000000oyz5AAA';
            Map<String, Decimal> pbeMap = new Map<String, Decimal>();
            List<PriceBookEntry> pbeList = [Select Id, Product2Id, UnitPrice from PriceBookEntry where Pricebook2Id = :pbeId];
            
            commercestorepricing.PricingRequestItemCollection items = request.getPricingRequestItems();
            
            // logic to map all product ids to a list called products
            for (PriceBookEntry pbe : pbeList) {
                pbeMap.put(pbe.Product2Id, pbe.UnitPrice);
            }
            
            // logic to map all product ids to a list called products
            for (Integer i = 0; i < items.size(); i++) {
                commercestorepricing.PricingRequestItem item = items.get(i);
                products.add(item.getProductId());
            }
            
            // grab all account product prices
            List<Account_Product_Price__c> priceRecords = [
                SELECT Price__c, Product__c
                FROM Account_Product_Price__c
                WHERE Account__c = :accountId AND Product__c IN :products
            ];
            
            // store results in map 
            Map<String, Decimal> accountProductPrices = new Map<String, Decimal>();
            
            for (Account_Product_Price__c app : priceRecords) {
                accountProductPrices.put(app.Product__c, app.Price__c);
            }
            
            // Create a response using the account product prices
            commercestorepricing.PricingResponse response = new commercestorepricing.PricingResponse('USD');
            
            // iterate through all items
            for (Integer i = 0; i < items.size(); i++) {
                String productId = items.get(i).getProductId();
                if (accountProductPrices == null || accountProductPrices.get(productId) == null) {
                    Decimal price = 0;
                    if(pbeMap.get(productId) != null) {
                        price = pbeMap.get(productId);
                    }
                    // if blank set price to null
                    commercestorepricing.PricingResponseItem responseItem = new commercestorepricing.PricingResponseItem(
                        productId,
                        null,
                        null,
                        price,
                        price
                    );
                    responseItem.setError(
                        'No prices available for this product.',
                        'No prices available for this product.'
                    );
                    response.addPricingResponseItem(responseItem);
                } else {
                    // if not blank then assign the account product price to the reponse item
                    Decimal productPrice = accountProductPrices.get(ProductId);
                    commercestorepricing.PricingResponseItem responseItem = new commercestorepricing.PricingResponseItem(
                        productId,
                        null,
                        null,
                        productPrice,
                        productPrice
                    );
                    response.addPricingResponseItem(responseItem);
                }
            }
            return response;
        }
    

    public override commercestorepricing.TransactionalPricingResponse processTransactionalPrice(
        commercestorepricing.TransactionalPricingRequest request2) {
            
        Decimal defaultPrice = 333;
            
        // get account ID from the request parameter
        String accountId = request2.getEffectiveAccountId();
        
        // get all products from request parameter
        Set<String> products = new Set<String>();
        
        commercestorepricing.TxnPricingRequestItemCollection items = request2.getTxnPricingRequestItems();
        
        
        // logic to map all product ids to a list called products
        for (Integer i = 0; i < items.size(); i++) {
            commercestorepricing.TransactionalPricingRequestItem item = items.get(i);
            products.add(item.getProductId());
        }
        
        // grab all account product prices
        List<Account_Product_Price__c> priceRecords = [
            SELECT Price__c, Product__c
            FROM Account_Product_Price__c
            WHERE Account__c = :accountId AND Product__c IN :products
        ];
        
        // store results in map 
        Map<String, Decimal> accountProductPrices = new Map<String, Decimal>();
        
        for (Account_Product_Price__c app : priceRecords) {
            accountProductPrices.put(app.Product__c, app.Price__c);
        }
        
        System.debug('Request');
        System.debug(request2);
            
        // Create a response using the account product prices
        commercestorepricing.TransactionalPricingResponse txnResponse = super.processTransactionalPrice(request2);
            //commercestorepricing.TransactionalPricingResponse txnResponse = new commercestorepricing.TransactionalPricingResponse(defaultPrice, defaultPrice, 0, defaultPrice, 'USD');
        
        commercestorepricing.TxnPricingResponseItemCollection txnItemCollection = txnResponse.getTxnPricingResponseItems();
        for (Integer j = 0; j < txnItemCollection.size(); j++) {
            commercestorepricing.TransactionalPricingResponseItem txnItem = txnItemCollection.get(j);
            System.debug('Request Item');
        	System.debug(txnItem);
            String prodId = txnItem.getProductId();
            Decimal price = accountProductPrices.get(prodId);
            txnItem.setUnitPrice(defaultPrice);
            txnItem.setListPrice(defaultPrice);
            txnItem.setTotalLineAmount(defaultPrice);
            txnItem.setTotalListPrice(defaultPrice);
            txnItem.setTotalPrice(defaultPrice);
        }
            txnResponse.setTotalAmount(defaultPrice);
            txnResponse.setTotalListPrice(defaultPrice);
            txnResponse.setTotalProductAmount(defaultPrice);

        txnResponse.setTotalAmount(
            txnResponse.getTotalProductAmount() + txnResponse.getTotalAdjustmentAmount()
        );
        
        return txnResponse;
    }

}
