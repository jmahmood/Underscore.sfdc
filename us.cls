public class US {
    /*  God bless Am.. I mean Underscore.js
     * The purposes is to allow you to concentrate on logic vs. loops and other code clutter that 
     * clouds (har har) the actual work you are doing.
     */

    @testvisible List<SObject> objs;
    Final List<SObject> original_objs;
    Boolean mutated;
    Integer i;
    
    /*  *********************************  */
    /*  Generic Filters                    */
    /*  *********************************  */
	public class KeepNewest extends ReduceInterfaceAbstract{
		public String DateField;

		public KeepNewest(String date_field){
			DateField = date_field;
		}

        public override SObject reducefn(SObject Memo, SObject value, Integer index, List<SObject> lst){
        	if (((Date) Memo.get(DateField)) >= ((Date) value.get(DateField)))
                return Memo;
            return value;
        }		
    }

    public class FilterFieldStrings extends US.FilterInterfaceAbstract {
        String filter_val;
        String filter_field;
        public FilterFieldStrings(String field, String val){
            filter_field = field;
            filter_val = val;
        }
        public override boolean filterfn(List<SObject> memo, SObject value){
            return (String) value.get(filter_field) == filter_val;
        }
    } 
	
    public class FilterFieldIds extends US.FilterInterfaceAbstract {
        Id filter_val;
        String filter_field;
        public FilterFieldIds(String field, Id val){
            filter_field = field;
            filter_val = val;
        }
        public override boolean filterfn(List<SObject> memo, SObject value){
            return (Id) value.get(filter_field) == filter_val;
        }
    } 

    /*  *********************************  */
    /*  Exceptions                         */
    /*  *********************************  */

    public virtual class UnimplementedUnderscoreException extends Exception{}
    
    /*  *********************************  */
    /*  Interfaces                         */
    /*  *********************************  */

    public interface FilterInterface { // Please see US_Test to see how to use this.
        // Cannot use "Map" due to it being a reserved term in Apex.
        // Is there a way to prevent anything passed into this from being "changed" (ie this should only filter?)
        List<SObject> filter(List<SObject> lst);
        boolean filterfn(List<SObject> memo, SObject value);
    }

    public interface CollectInterface { // Please see US_Test to see how to use this.
        // Cannot use "Map" due to it being a reserved term in Apex.
        List<SObject> collect(List<SObject> lst);
    }

    public interface EachInterface { // Please see US_Test to see how to use this.
        List<SObject> each(List<SObject> objs);
        SObject eachfn(SObject Element, Integer index, List<SObject> lst);
    }

    public interface ReduceInterface { // Please see US_Test to see how to use this.
        // This is challenging as we may want to return a string or an integer, 
        // but with an SObject we could hopefully have both or all of these in the end.
        // There is no need for Memo and Value to be the same kind of SObject.
        SObject reduce(List<SObject> objs); 
        SObject reducefn(SObject Memo, SObject value, Integer index, List<SObject> lst);
    }

    public interface GroupByInterface {
        String groupByFn(SObject obj);
    }

    public interface IndexByInterface {
        String indexByFn(SObject obj);
    }

    public interface CountByInterface {
        String countByFn(SObject obj);
    }


    public interface ReduceRightInterface { // Please see US_Test to see how to use this.
        // This is challenging as we may want to return a string or an integer, 
        // but with an SObject we could hopefully have both or all of these in the end.
        // There is no need for Memo and Value to be the same kind of SObject.
        SObject reduceright(List<SObject> objs); 
        SObject reducerightfn(SObject Memo, SObject value, Integer index, List<SObject> lst);
    }

    /*  *********************************  */
    /*  Abstract Classes                   */
    /*  *********************************  */

    public abstract class ReduceRightInterfaceAbstract implements ReduceRightInterface{
        /*  These abstract classes allow us to implement the logical function only */
        public SObject reduceright(List<SObject> objs){
            if (objs.size() == 0){
                return null;
            }
            if (objs.size() == 1){
                return objs[0];
            }
            SObject memo = objs[objs.size()-1];
            for(Integer i = objs.size()-1; i >= 0; i--){
                memo = reducerightfn(memo, objs[i], objs.size()-1-i, objs);
            }
            return memo;
        }
        SObject reducerightfn(SObject Memo, SObject value, Integer index, List<SObject> lst){
            return Memo;
        }
    }

    public abstract class ReduceInterfaceAbstract implements ReduceInterface{
        public SObject reduce(List<SObject> objs){
            if (objs.size() == 0){
                return null;
            }
            if (objs.size() == 1){
                return objs[0];
            }
            SObject memo = objs[0];
            for(Integer i = 1; i < objs.size(); i++){
                memo = reduceFn(memo, objs[i], i-1, objs);
            }
            return memo;
        } 
        SObject reducefn(SObject Memo, SObject value, Integer index, List<SObject> lst){
            return Memo;
        }
    }
    /*
    TODO: Consider renaming FilterInterface to TruthyInterface, as we are using it for all true tests.
    */
    public abstract class FilterInterfaceAbstract implements FilterInterface{
        public abstract boolean filterfn(List<SObject> memo, SObject value);
        
        public List<SObject> filter(List<SObject> lst){
            List<SObject> memo = new List<SObject>();
            for (SObject value : lst){
                if(filterfn(memo, value)){
                    memo.add(value);
                }
            }
            return memo;
        }
        
        public List<SObject> reject(List<SObject> lst){
            List<SObject> memo = new List<SObject>();
            for (SObject value : lst){
                if(!filterfn(memo, value)){
                    memo.add(value);
                }
            }
            return memo;
        }
        
        public Boolean every(List<SObject> lst){
            List<SObject> memo = new List<SObject>();
            for (SObject value : lst){
                if(!filterfn(memo, value)){
                    return false;
                }
            }
            return true;
        }

        public Boolean some(List<SObject> lst){
            List<SObject> memo = new List<SObject>();
            for (SObject value : lst){
                if(filterfn(memo, value)){
                    return true;
                }
            }
            return false;
        }
    }

    /*  *********************************  */
    /*  Functions                          */
    /*  *********************************  */

    public List<SObject> collect(CollectInterface behavior){
        // This mutates the object.  Rewinding only restores the original list, not the original values.
        mutated = true;
        return behavior.collect(objs);
    }

    public List<SObject> each(EachInterface behavior){
        // This mutates the object.  Rewinding only restores the original list, not the original values.
        mutated = true;
        return behavior.each(objs);
    }

    public SObject reduce(ReduceInterface behavior){
        // This mutates the object.  Rewinding only restores the original list, not the original values.
        mutated = true;
        return behavior.reduce(objs);
    }

    public SObject reduceright(ReduceRightInterface behavior){
        // This mutates the object.  Rewinding only restores the original list, not the original values.
        mutated = true;
        return behavior.reduceright(objs);
    }

    public SObject find(FilterInterface behavior){
        objs = behavior.filter(objs);
        return objs.size() > 0 ? objs[0] : null;
    }


    /*  
    WHY:  Remove the loop / matching boilerplate from the main function expression.
    WHY:  Create reusable filters which can be applied to all SObjects
    WHY:  Create side-effects which push best practices 
    HOW:  Create a class which extends FilterInterfaceAbstract and has a name which implies its function.
    EXAMPLE: 
    US x = new US([select id, email from User]);
    x.filter('MyClass.GmailEmailsOnly').filter('MyClass.CreatedToday');


    class CreatedToday extends FilterInterfaceAbstract{
        public override boolean filterfn(List<SObject> memo, SObject value){
            return (Date) value.get('CreatedDate') == System.today();
        }
    }

    class GmailEmailsOnly extends FilterInterfaceAbstract{
        public override void filterfn(List<SObject> memo, SObject value){
            return ((String) value.get('email')).contains('gmail');
        }
    }

    TODO: A sane default interface 
        x.filter('id', something).filter('field__c', something)...


    */

    /*  What is the benefit of dynamically creating the object when we can't pass variables?  
    public US filter(String fqdn_behavior_cls){
        Type t = Type.forName(fqdn_behavior_cls);
        FilterInterface behavior = (FilterInterface)t.newInstance();

        objs = behavior.filter(objs);
        return this;
    }*/

    public US filter(FilterInterfaceAbstract behavior){
        objs = behavior.filter(objs);
        return this;
    }

    public US reject(FilterInterfaceAbstract behavior){
        objs = behavior.reject(objs);
        return this;
    }

    public Boolean every(FilterInterfaceAbstract behavior){
        return behavior.every(objs);
    }

    public Boolean some(FilterInterfaceAbstract behavior){
        return behavior.some(objs);
    }
    
    public Boolean contains(SObject x){
        /*  Why no class?  Contains seems, to me, to be testing for the presence of an object, and has a very 
        clear meaning in SFDC.  If you want to look for a specific condition existing, you would use "some".

        Thoughts: This is dependent on the Set Contains function, which has certain limitations.  
        Matching by ID may be more sensible for SObjects.
        */
        return (new Set<SObject>(objs)).contains(x);
    }
    
    public void invoke(String fqdn_behavior_cls){
        // We cannot dynamically invoke a function or a method in Salesforce.
        // you should use collect / map to mutate the function 
        throw new UnimplementedUnderscoreException('Invoke is not available on Salesforce');
    }

    public List<Object> pluck(String field){
        List<Object> ret = new List<Object> ();
        for(Sobject o: objs){
            ret.add(o.get(field));
        }
        return ret;
    }

    public Object max(String field){
        /*
            I can imagine many different ways to implement this, but what should the default use case be?
        */

        throw new UnimplementedUnderscoreException('Invoke is not available on Salesforce');
    }
    
    public US sortBy(){
        /*  SFDC standard sorting methodology. */
        objs.sort();
        return this;
    }

    public Map<String, Set<SObject>> groupBy(GroupByInterface behavior){
        Map<String, Set<SObject>> ret = new Map<String, Set<SObject>>();

        for(Sobject o: objs){
            String group_name = behavior.groupByFn(o);
            if (ret.get(group_name) == null)
                ret.put(group_name, new Set<SObject>());
            ret.get(group_name).add(o);
        }

        return ret;
    }


    public Map<String, SObject> indexBy(IndexByInterface behavior){
        Map<String, SObject> ret = new Map<String, SObject>();

        for(Sobject o: objs){
            String group_name = behavior.indexByFn(o);
            ret.put(group_name, o);
        }

        return ret;
    }


    public Map<String, Integer> countBy(CountByInterface behavior){
        Map<String, Integer> ret = new Map<String, Integer>();

        for(Sobject o: objs){
            String group_name = behavior.countByFn(o);
            if (ret.get(group_name) == null)
                ret.put(group_name, 0);
            ret.put(group_name, ret.get(group_name) + 1);
        }

        return ret;
    }

    public void shuffle(){
        throw new UnimplementedUnderscoreException('Shuffle is not implemented (What\'s the point?');
    }

    public void sample(Integer n){
        throw new UnimplementedUnderscoreException('Sample is not implemented.');
    }

    /*
        Because mixing types isn't easy in a Map, initializing (but not saving) an SObject and passing along the vlaues (or passing along an SObject that already exists and the related value)
        works for this.
    */
    
    // Where is a reserved word in Apex so we are using the name whreHas instead.
    public US whereHas(SObject properties, List<String> property_fields){
        List<SObject> ret = new List<SObject>();
        for (SObject o: objs){
            boolean allowed = true;

            for (String f: property_fields)
                allowed = allowed && properties.get(f) == o.get(f);

            if (allowed)
                ret.add(o);
        }
        objs = ret;
        return this;
    }

    public SObject findwhere(SObject properties, List<String> property_fields){
        for (SObject o: objs){
            boolean allowed = true;

            for (String f: property_fields)
                allowed = allowed && properties.get(f) == o.get(f);

            if (allowed)
                return o;
        }
        return null;
    }

    public List<SObject> toList(){
        return objs;
    }

    public US rewind(){
        objs = original_objs;
        return this;
    }

    public US(List<SObject> items){
        objs = items;
        original_objs = items;
        mutated = false;
        i = 0;
    }
}
