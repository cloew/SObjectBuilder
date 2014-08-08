@isTest
public class SObjectBuilder
{
    private Schema.SObjectType objectType;
    private Integer numberToBuild = 1;
    private Map<Schema.SObjectField, Object> fieldToValue;

    private List<Object> parentValues = null;
    private Schema.SObjectField destinationField = null;
    private Integer numberForEach = 1;

    private Map<Schema.SObjectField, SObjectBuilder> fieldToParentBuilder = new Map<Schema.SObjectField, SObjectBuilder>();

    public SObjectBuilder(Schema.SObjectType objectType)
    {
        this.objectType = objectType;
        fieldToValue = new Map<Schema.SObjectField, Object>();
    }

    public SObjectBuilder count(Integer numberToBuild)
    {
        this.numberToBuild = numberToBuild;
        return this;
    }

    public SObjectBuilder parents(List<SObject> parents, Schema.SObjectField lookupField)
    {
        List<Object> values = new List<Id>();
        for (SObject record : parents)
        {
            values.add(record.Id);
        }
        return forEach(values, lookupField);
    }

    public SObjectBuilder forEach(Set<Object> values, Schema.SObjectField destinationField)
    {
        return forEach(new List<Object>(values), destinationField);
    }

    public SObjectBuilder forEach(List<Object> values, Schema.SObjectField destinationField)
    {
        this.parentValues = values;
        this.destinationField = destinationField;
        return this;
    }

    public SObjectBuilder countForEach(Integer numberForEach)
    {
        this.numberForEach = numberForEach;
        return this;
    }

    public SObjectBuilder field(Schema.SObjectField field, Object value)
    {
        this.fieldToValue.put(field, value);
        return this;
    }

    public SObjectBuilder fields(Map<Schema.SObjectField, Object> fieldToValue)
    {
        this.fieldToValue.putAll(fieldToValue);
        return this;
    }

    public SObjectBuilder with(Schema.SObjectType parentType, Schema.SObjectField destinationField)
    {
        fieldToParentBuilder.put(destinationField, new SObjectBuilder(parentType));
        return this;
    }

    public SObjectBuilder with(SObjectBuilder parentBuilder, Schema.SObjectField destinationField)
    {
        fieldToParentBuilder.put(destinationField, parentBuilder);
        return this;
    }

    public List<SObject> build()
    {
        for (Schema.SObjectField field : fieldToParentBuilder.keySet())
        {
            SObject parent = fieldToParentBuilder.get(field).buildAndInsert()[0];
            fieldToValue.put(field, parent.Id);
        }

        if (parentValues == null || destinationField == null)
        {
            return buildBasic(fieldToValue);
        }
        else
        {
            return buildFromParents(fieldToValue);
        }
    }

    private List<SObject> buildBasic(Map<Schema.SObjectField, Object> fieldToValue)
    {
        return SObjectFactory.build(numberToBuild, objectType, fieldToValue);
    }

    private List<SObject> buildFromParents(Map<Schema.SObjectField, Object> fieldToValue)
    {
        List<SObject> results = new List<SObject>();
        for (Object value : parentValues)
        {
            fieldToValue.put(destinationField, value);
            results.addAll(SObjectFactory.build(numberForEach, objectType, fieldToValue));
        }

        return results;
    }

    public List<SObject> buildAndInsert()
    {
        List<SObject> records = build();
        insert records;
        return records;
    }
}