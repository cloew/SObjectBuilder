@isTest
public class SObjectFieldValueProviders
{
    static Integer counter = 0;

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

    public virtual class UniqueStringProvider implements ISObjectFieldValueProvider
    {
        private String base;
        
        public UniqueStringProvider(String base)
        {
            this.base = base;
        }

        public virtual Object getValue()
        {
            String result = base + String.valueOf(counter);
            counter++;
            return result;
        }
    }

    public class DummyIdProvider extends UniqueStringProvider
    {
        private String idPrefix;
        
        public DummyIdProvider(Schema.SObjectType sObjectType)
        {
            super('');
            idPrefix = sObjectType.getDescribe().getKeyPrefix();
        }

        public override Object getValue()
        {
            String idBase = (String) super.getValue();
            String idSuffix = idBase.leftPad(12);
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
        private Integer index = 0;
        
        public ListValueProvider(List<Object> values)
        {
            this.values = values;
        }

        public Object getValue()
        {
            Object value = values[index];
            index++;
            index = math.mod(index, values.size());
            return value;
        }
    }
}