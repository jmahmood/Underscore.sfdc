public class US { 
    /*	Inspired by Underscore.js.  
     * The purposes is to allow you to concentrate on logic vs. loops and other code clutter that 
     * clouds (har har) the actual work you are doing.
     */

    public interface FilterInterface { // Please see US_Test to see how to use this.
        // Cannot use "Map" due to it being a reserved term in Apex.
        // Is there a way to prevent anything passed into this from being "changed" (ie this should only filter?)
        List<SObject> filter(List<SObject> lst);
        Void filterfn(List<SObject> memo, SObject value);
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
            for (SObject value : lst){
                if(!filterfn(memo, value)){
                    return false
                }
            }
            return true;
        }

        public Boolean some(List<SObject> lst){
            for (SObject value : lst){
                if(filterfn(memo, value)){
                    return true
                }
            }
            return false;
        }

        public abstract boolean filterfn(List<SObject> memo, SObject value);
    }

    
        
    public interface ReduceRightInterface { // Please see US_Test to see how to use this.
        // This is challenging as we may want to return a string or an integer, 
        // but with an SObject we could hopefully have both or all of these in the end.
        // There is no need for Memo and Value to be the same kind of SObject.
        SObject reduceright(List<SObject> objs); 
        SObject reducerightfn(SObject Memo, SObject value, Integer index, List<SObject> lst);
    }

    @testvisible List<SObject> objs;
    Final List<SObject> original_objs;
    Boolean mutated;
    Integer i;
    
    public List<SObject> collect(CollectInterface behavior){
        // This mutates the object; you cannot rewind after this is done.
        mutated = true;
        return behavior.collect(objs);
    }

    public List<SObject> each(EachInterface behavior){
        // This mutates the object; you cannot rewind after this is done.
        mutated = true;
        return behavior.each(objs);
    }

    public SObject reduce(ReduceInterface behavior){
        // This mutates the object; you cannot rewind after this is done.
        mutated = true;
        return behavior.reduce(objs);
    }

    public SObject reduceright(ReduceRightInterface behavior){
        // This mutates the object; you cannot rewind after this is done.
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
        x.filter('id', something).filter('field__c', something)...*/
    public US filter(String fqdn_behavior_cls){
        Type t = Type.forName(fqdn_behavior_cls);
        FilterInterface behavior = (FilterInterface)t.newInstance();

        objs = behavior.filter(objs);
        return this;
    }

    /*
        Because mixing types isn't easy in a Map, initializing (but not saving) an SObject and passing along the vlaues (or passing along an SObject that already exists and the related value)
        works for this.
    */

    public US where(SObject properties, List<String> property_fields){
        List<SObject> ret = new List<SObject>();
        for (SObject o: objs){
            boolean allowed = true;

            for (field f: property_fields)
                allowed = allowed && properties.get(f) == o.get(f);

            if (allowed)
                ret.add(o);
        }
        return this;
    }

    public US findwhere(SObject properties, List<String> property_fields){
        for (SObject o: objs){
            boolean allowed = true;

            for (field f: property_fields)
                allowed = allowed && properties.get(f) == o.get(f);

            if (allowed)
                return o;
        }
        return null;
    }

    /*  
    EXAMPLE: 
    US x = new US([select id, email from User]);
    x.filter('MyClass.GmailEmailsOnly').reject('MyClass.CreatedToday');
    (Get all Users w/ Gmail emails which were not in User objects that were created today)


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
        x.filter('id', something).filter('field__c', something)...*/
    public US reject(String fqdn_behavior_cls){
        Type t = Type.forName(fqdn_behavior_cls);
        FilterInterface behavior = (FilterInterface)t.newInstance();

        objs = behavior.reject(objs);
        return this;
    }

    public US every(String fqdn_behavior_cls){
        Type t = Type.forName(fqdn_behavior_cls);
        FilterInterface behavior = (FilterInterface)t.newInstance();

        objs = behavior.reject(objs);
        return this;
    }


    public US some(String fqdn_behavior_cls){
        Type t = Type.forName(fqdn_behavior_cls);
        FilterInterface behavior = (FilterInterface)t.newInstance();

        objs = behavior.some(objs);
        return this;
    }

    public US(List<SObject> items){
        objs = items;
        original_objs = items;
        mutated = false;
        i = 0;
    }
    
}
