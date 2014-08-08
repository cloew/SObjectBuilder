/*
How it works:
    build([recordCount], objectType, [fieldToValue])
        - buildAndInsert an SObject but do not return it
        - optionally specify how many of this SObject type to buildAndInsert
        - optionally specify a map of field to value
    buildAndInsert([recordCount], objectType, [fieldToValue])
        - same overloading structure, but SObjects are inserted
*/
@IsTest
public class SObjectFactory
{
    public static SObject build(Schema.SObjectType objectType) { return build(1, objectType)[0]; }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType)
    {
        return build(recordCount, objectType, null);
    }
    public static SObject build(Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue)
    {
        return build(1, objectType, fieldToValue)[0];
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, Map<Schema.SObjectField, Object> customFieldToValue)
    {
        Map<Schema.SObjectField, Object> fieldToValue = new Map<Schema.SObjectField, Object>(SObjectDefaults.getDefaults(objectType));
        fieldToValue.putAll(customFieldToValue);

        SObject record = objectType.newSObject();
        return copy(recordCount, record, fieldToValue);
    }
    
    public static SObject buildAndInsert(Schema.SObjectType objectType) { return buildAndInsert(1, objectType)[0]; }
    public static List<SObject> buildAndInsert(Integer recordCount, Schema.SObjectType objectType)
    {
        return buildAndInsert(recordCount, objectType, null);
    }
    public static SObject buildAndInsert(Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue)
    {
        return buildAndInsert(1, objectType, fieldToValue)[0];
    }
    public static List<SObject> buildAndInsert(Integer recordCount, Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue)
    {
        List<SObject> records = build(recordCount, objectType, fieldToValue);
        insert records;
        return records;
    }

    public static SObject copy(SObject record, Map<Schema.SObjectField, Object> fieldToValue)
    {
        SObject copy = record.clone(/* Preserve Id */ true, /* Deep */ true, /* Preserve Timestamps */ true, /* Preserve Auto-Numbers */ true);
        setSObjectFields(copy, fieldToValue);
        return copy;
    }

    public static List<SObject> copy(Integer recordCount, SObject record)
    {
        return copy(recordCount, record, null);
    }

    public static List<SObject> copy(Integer recordCount, SObject record, Map<Schema.SObjectField, Object> fieldToValue)
    {
        List<SObject> copies = new List<SObject>();
        for (Integer i = 0; i < recordCount; i++)
        {
            copies.add(copy(record, fieldToValue));
        }
        return copies;
    }
    public static List<SObject> copy(List<SObject> records, Map<Schema.SObjectField, Object> fieldToValue)
    {
        List<SObject> copies = new List<SObject>();
        for (SObject record : records)
        {
            copies.add(copy(record, fieldToValue));
        }
        return copies;
    }
    
    private static void setSObjectFields(SObject record, Map<Schema.SObjectField, Object> fieldToValue)
    {
        if (fieldToValue != null)
        {
            for (Schema.SObjectField field : fieldToValue.keySet())
            {
                Object value = fieldToValue.get(field);
            
                if (value instanceof SObjectFieldValueProviders.ISObjectFieldValueProvider)
                {
                    SObjectFieldValueProviders.ISObjectFieldValueProvider valueProvider = (SObjectFieldValueProviders.ISObjectFieldValueProvider) value;
                    value = valueProvider.getValue();
                }
                record.put(field, value);
            }
        }
    }
}