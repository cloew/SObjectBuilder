@isTest
public class SObjectDefaults
{
    private static Map<Schema.SObjectType, Map<Schema.SObjectField, Object>> defaults = new Map<Schema.SObjectType, Map<Schema.SObjectField, Object>>
    {
        Account.SObjectType => new Map<Schema.SObjectField, Object>
        {
            Account.Name => 'Test Account'
        },
        Contact.SObjectType => new Map<Schema.SObjectField, Object>
        {
            Contact.LastName => 'Doe'
        },
        Product2.SObjectType => new Map<Schema.SObjectField, Object>
        {
            Product2.Name => 'Test Product'
        }
    };

    public static Map<Schema.SObjectField, Object> getDefaults(Schema.SObjectType objectType)
    {
        Map<Schema.SObjectField, Object> defaultFieldValues = new Map<Schema.SObjectField, Object>();
        if (defaults.containsKey(objectType))
        {
            defaultFieldValues = defaults.get(objectType);
        }

        return defaultFieldValues;
    }
}