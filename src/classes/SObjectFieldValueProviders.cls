@isTest
public class SObjectFieldValueProviders
{
    public interface ISObjectFieldValueProvider
    {
        Object getValue();
    }

    public class ParentProvider implements ISObjectFieldValueProvider
    {
        private Schema.SObjectType objectType;
        private SObject record;
        
        public ParentProvider(Schema.SObjectType objectType)
        {
            this.objectType = objectType;
        }

        public Object getValue()
        {
            if (record == null)
            {
                record = new SObjectBuilder(objectType).buildAndInsert()[0];
            }
            return record.Id;
        }
    }
}