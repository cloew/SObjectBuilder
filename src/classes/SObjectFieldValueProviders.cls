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

    public class UniqueStringProvider implements ISObjectFieldValueProvider
    {
        static Integer counter = 0;
        private String base;
        
        public UniqueStringProvider(String base)
        {
            this.base = base;
        }

        public Object getValue()
        {
            String result = base + String.valueOf(counter);
            counter++;
            return result;
        }
    }

    public class DummyIdProvider extends UniqueStringProvider
    {
        private String idPrefix;
        
        public UniqueIdProvider(Schema.SObjectType sObjectType)
        {
            super('');
            idPrefix = sObjectType.getDescribe().getKeyPrefix();
        }

        public Object getValue()
        {
            String idSuffix = super.getValue().leftPad(12);
            idSuffix = idSuffix.replace(' ', '0');
            return idPrefix + idSuffix;
        }
    }

    public class SpecificRecordProvider implements ISObjectFieldValueProvider
    {
        private String query;
        private SObject record;
        
        public SpecificRecordProvider(String query)
        {
            this.query = query;
        }

        public Object getValue()
        {
            return getRecord().Id;
        }

        private SObject getRecord()
        {
            if (record == null)
            {
                record = Database.query(query);
            }
            return record;
        }
    }

    public class ListValueProvider implements ISObjectFieldValueProvider
    {
        private List<Object> values;
        private Integer counter = 0;
        
        public ListValueProvider(List<Object> values)
        {
            this.values = values;
        }

        public Object getValue()
        {
            Object value = values[counter];
            counter++;
            counter %= values.size();
            return value;
        }
    }
}