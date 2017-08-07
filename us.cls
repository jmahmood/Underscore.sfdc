public with sharing class  US {
    /*  God bless Am.. I mean Underscore.js
     * The purposes is to allow you to concentrate on logic vs. loops and other code clutter that 
     * clouds (har har) the actual work you are doing.
     */

    @testvisible List<SObject> objs;

    private static FilterFieldEqualToValue default_filter_behavior_eq;
    private static FilterFieldInValueCollection default_filter_behavior_col;
    private static FilterCompareFieldToValue default_filter_behavior_cmp;

    Final List<SObject> original_objs;
    Boolean mutated;
    Integer i;
    
    /*  *********************************  */
    /*  Generic Filters                    */
    /*  *********************************  */
    public class KeepNewest extends ReduceInterfaceAbstract{

         /**
         * This class implements a common list manipulation use case;
         * to reduce a list of SObjects to the newest element based on a specific date field.
         * 
         * Example:
         *    x = new US([select id, name, CreatedDate from User limit 10]);
         *    User newest_created_user = (User) x.reduce(new US.KeepNewest('CreatedDate'));
         *
         * @param DateField A string that represents the name of the date field in the SObject.
         */

      final private String DateField;

      public KeepNewest(String date_field){
        DateField = date_field;
      }

      public override SObject reducefn(List<SObject> lst, SObject value, SObject memo, Integer index){
        if (((Date) value.get(DateField)) >= ((Date) memo.get(DateField)))
          return value;
        return memo;
      } 
    
    } // KeepNewest


    public class FilterFieldStrings extends US.FilterInterfaceAbstract {
       /**
       * This class implements a common list manipulation use case;
       * to confirm whether or not a string field on an SObject is of the same value as the value passed initially.
       * This can be used with multiple functions, not just filters.
       * 
       * Example:
       *    x = new US([select id, name, CreatedDate from User limit 10]);
       *    List<User> UsersNamedJawaad = x.filter(new US.FilterFieldStrings('Name', 'Jawaad')).toList();
       *    List<User> UsersNotNamedJawaad = x.rewind().reject(new US.FilterFieldStrings('Name', 'Jawaad')).toList();
       *    Boolean AreAllUsersJawaad = x.rewind().every(new US.FilterFieldStrings('Name', 'Jawaad'));
       *    Boolean AreSomeUsersJawaad = x.rewind().some(new US.FilterFieldStrings('Name', 'Jawaad'));
       * @param field A string that represents the name of the Id field in the SObject.
       * @param val A constant String value that we want to filter for.
       */

        final private String filter_val;
        final private String filter_field;

        public FilterFieldStrings(String field, String val){
            filter_field = field;
            filter_val = val;
        }

        public override boolean filterfn(List<SObject> memo, SObject value){
            return (String) value.get(filter_field) == filter_val;
        }
    } 
  
    public class FilterFieldIds extends US.FilterInterfaceAbstract {
       /**
       * This class implements a common list manipulation use case;
       * to confirm whether or not an ID field on an SObject is of the same value as a value passed to the system.
       * This can be used with multiple functions, not just filters.
       * 
       * Example:
       *    x = new US([select id, name, CreatedDate from User limit 10]);
       *    List<User> UsersWithId = x.filter(new US.FilterFieldStrings('Id', 'xxxxxxxxxxxxxx')).toList();
       *    List<User> UsersWithoutId = x.rewind().reject(new US.FilterFieldStrings('Id', 'xxxxxxxxxxxxxx')).toList();
       *    Boolean AreAllUsersWithIdX = x.rewind().every(new US.FilterFieldStrings('Id', 'xxxxxxxxxxxxxx'));
       *    Boolean AreSomeWithIdX = x.rewind().some(new US.FilterFieldStrings('Id', 'xxxxxxxxxxxxxx'));
       * @param field A string that represents the name of the Id field in the SObject.
       * @param value A constant ID value that we want to filter for.
       */

        final private Id filter_val;
        final private String filter_field;

        public FilterFieldIds(String field, Id val){
            filter_field = field;
            filter_val = val;
        }

        public override boolean filterfn(List<SObject> memo, SObject value){
            return (Id) value.get(filter_field) == filter_val;
        }
    } 

    public class FilterFieldEqualToValue extends US.FilterInterfaceAbstract {
        private Object filter_val;
        private String filter_field;

        public FilterFieldEqualToValue(String field, Object val){
            set(field, val);
        }

        public void set(String field, Object val){
            filter_field = field;
            filter_val = val;
          }


        public override boolean filterfn(List<SObject> memo, SObject value){
            return value.get(filter_field) == filter_val;
        }
    }

    public class FilterFieldInValueCollection extends US.FilterInterfaceAbstract {
        private Set<Object> filter_val;
        private String filter_field;

        public FilterFieldInValueCollection(String field, Set<Object> val){
          set(field, val);
        }

        public void set(String field, Set<Object> val){
            filter_field = field;
            filter_val = val;
          }

        public override boolean filterfn(List<SObject> memo, SObject value){
            return filter_val.contains(value.get(filter_field));
        }
    }    
    
    public class FilterCompareFieldToValue extends US.FilterInterfaceAbstract {
        private Object filter_val;
        private String filter_field;
        private String filter_comparitor;

        public FilterCompareFieldToValue(String field, String comparitor, Object val){
          set(field, comparitor, val);
        }


        public void set(String field, String comparitor, Object val){
            filter_field = field;
            filter_val = val;
            filter_comparitor = comparitor;
        }


        public override boolean filterfn(List<SObject> memo, SObject value){
            Boolean gt = filter_comparitor == '>' || filter_comparitor == '>=';
            Boolean lt = filter_comparitor == '<' || filter_comparitor == '<=';
            Boolean eq = filter_comparitor == '==' || filter_comparitor == '<='  || filter_comparitor == '>=';

            return filter_val instanceof Integer && (
                    (gt && (Integer) value.get(filter_field) > (Integer) filter_val) || (lt && (Integer) value.get(filter_field) < (Integer) filter_val) || (eq && (Integer) value.get(filter_field) == (Integer) filter_val)
                )  || filter_val instanceof String && (
                    (eq && (String) value.get(filter_field) == (String) filter_val)
                )  || filter_val instanceof Decimal && (
                    (gt && (Decimal) value.get(filter_field) >  (Decimal) filter_val) || (lt && (Decimal) value.get(filter_field) <  (Decimal) filter_val) || (eq && (Decimal) value.get(filter_field) == (Decimal) filter_val)
                ) || filter_val instanceof Date && (
                    (gt && (Date) value.get(filter_field) > (Date) filter_val) || (lt && (Date) value.get(filter_field) < (Date) filter_val) || (eq && (Date) value.get(filter_field) == (Date) filter_val)
                ) || filter_val instanceof Datetime && (
                    (gt && (Datetime) value.get(filter_field) > (Datetime) filter_val) || (lt && (Datetime) value.get(filter_field) < (Datetime) filter_val) || (eq && (Datetime) value.get(filter_field) == (Datetime) filter_val)
                ) || filter_val instanceof Time && (
                    (gt && (Time) value.get(filter_field) > (Time) filter_val) || (lt && (Time) value.get(filter_field) < (Time) filter_val) || (eq && (Time) value.get(filter_field) == (Time) filter_val)
                ) || filter_val instanceof Long && (
                    (gt && (Long) value.get(filter_field) > (Long) filter_val) || (lt && (Long) value.get(filter_field) < (Long) filter_val) || (eq && (Long) value.get(filter_field) == (Long) filter_val)
                );
        }
    }
    
    /*  *********************************  */
    /*  Exceptions                         */
    /*  *********************************  */

    public virtual class UnimplementedUnderscoreException extends Exception{}
    
    /*  *********************************  */
    /*  Interfaces                         */
    /*  *********************************  */

    public interface FilterInterface {
       /**
       * This interface allows us to create dynamic conditions to determine whether or not
       * an SObject meets a boolean condition.
       * 
       * You can override US.FilterInterfaceAbstract to get the most likely configuration 
       * you want for filter.
       *
       * @see FilterInterfaceAbstract
       */
        List<SObject> filter(List<SObject> lst);
        boolean filterfn(List<SObject> memo, SObject value);
    }

    public interface CollectInterface { 
       /**
       * @Beta
       * This interface allows us to create a new list based on all of the items in a list of SObjects.
       *
       * Use "Collect" if you just want to create a new list that stores the result of a function on a 
       * US Obj list, use "Each" if you want to modify the actual object itself.
       * 
       * You can override US.CollectInterfaceAbstract to get the most likely configuration 
       * you want for collect.
       *
       * @see CollectInterfaceAbstract
       *
       * We use the term "collect" instead of "Map" because "Map" is a keyword that
       * refers to the Associative Array / JavaScript Object / Python Dict type of collection
       * in Apex.
       */
        List<Object> collect(List<SObject> lst);
        Object collectfn(List<SObject> lst, SObject value, Integer index);
    }

    public interface EachInterface { 
       /**
       * @Beta
       * This interface allows us to pass all elements in the list to a function.
       *
       * WARNING: Collect (map) overlaps functionally with Each.  Practically, we pass each item 
       * in a list to a function which then can either modify the data or execute some other function
       * with the data.
       * 
       * I currently do not believe that there is any meaningful difference that can be implemented
       * in Salesforce without something hacky.
       *
       * In the future I may change this behavior, depending on user feedback.
       *
       * Use "Each" if you want to call an external function on the object  or use the object to modify 
       * some sort of external state.  Use "Collect" if you just want to mutate data on an object.
       * 
       * You can override US.EachInterfaceAbstract to get the most likely configuration 
       * you want for collect.
       *
       * @see CollectInterface
       * @see EachInterfaceAbstract
       */
        List<SObject> each(List<SObject> objs);
        void eachfn(List<SObject> lst, SObject value, Integer index);
    }

    public interface ReduceInterface { 
        /**
        * This interface allows us to execute a reduce, which permits you to
        * convert a set of values into a single sobject value.
        *
        * You can override US.ReduceInterfaceAbstract to get the most likely configuration 
        * you want for collect.
        *
        * Note: Memo does not have to be the same kind of object as iteratee or lst.
        * For example, it could be a parent value generated from a list of child objects).
        *
        * @see ReduceInterfaceAbstract
        * @see KeepNewest
        */
        SObject reduce(List<SObject> objs); 
        SObject reducefn(List<SObject> lst, SObject value, SObject memo, Integer index);
    }

    public interface ReduceRightInterface {
        /**
        * This interface allows us to execute a "right reduce", which permits you to
        * convert a set of values into a single sobject value.  
        *
        * This differs from a "reduce" as the values are taken from the right side, not
        * the left.  This is not entirely meaningful in Apex, but is here for the
        * sake of completeness.
        *
        * You can override US.ReduceInterfaceAbstract to get the most likely configuration 
        * you want for collect.
        *
        * Note: Memo does not have to be the same kind of object as iteratee or lst.
        * For example, it could be a parent value generated from a list of child objects).
        *
        * @see ReduceInterface
        * @see ReduceRightInterfaceAbstract
        */
        SObject reduceright(List<SObject> objs); 
        SObject reducerightfn(List<SObject> lst, SObject value, SObject memo, Integer index);
    }

    public interface PartitionInterface {
        String partitionFn(SObject obj);
    }

    public interface GroupByInterface {
        /**
        * Classes implementing this will group a list of SObjects on the basis of a 
        * partition function.
        *
        * You can override US.PartitionInterfaceAbstract to get the most likely configuration 
        * you want for GroupBy.  (You also get IndexBy and CountBy for free)
        *
        * @see IndexByInterface
        * @see CountByInterface
        * @see PartitionInterface
        * @see PartitionInterfaceAbstract
        *
        * Changelog: Switched from Set<SObject> to List<Object> as 1. we may need an ordered list, 
        * and 2. we are moving to using Object instead of SObject (as we can still do casting as necessary)
        */
        Map<String, List<Object>> groupBy(List<Object> objs);
    }

    public interface IndexByInterface {
        /**
        * Classes implementing this will generate a map on the basis of a 
        * partition function.  This should only be used when you are using a unique
        * key to partition (think ID) or want to keep only the last item which matches
        * the partition value.
        *
        * You can override US.PartitionInterfaceAbstract to get the most likely configuration 
        * you want for IndexBy.  (You also get GroupBy and CountBy for free)
        * 
        * You can use this also for a Map<String, Map<...>> type.
        *
        * @see GroupByInterface
        * @see CountByInterface
        * @see PartitionInterface
        * @see PartitionInterfaceAbstract
        */
        Map<String, Object> indexBy(List<Object> objs);
    }

    public interface CountByInterface {
        /**
        * Classes implementing this will generate a map on the basis of a 
        * partition function, with the number of times that partition is repeated.
        *
        * You can override US.PartitionInterfaceAbstract to get the most likely configuration 
        * you want for CountBy.  (You also get GroupBy and IndexBy for free)
        *
        * @see GroupByInterface
        * @see IndexByInterface
        * @see PartitionInterface
        * @see PartitionInterfaceAbstract
        */
        Map<String, Integer> countBy(List<SObject> objs);
    }


    /*  *********************************  */
    /*  Abstract Classes                   */
    /*  *********************************  */

    public abstract class PartitionInterfaceAbstract implements GroupByInterface, IndexByInterface, CountByInterface, PartitionInterface{
        /**
        * This class handles the majority of the Partition-related functions.  
        * You only need to override the partitionFn object.
        *
        * @param objs A list of SObjects on which you want to use the partition function.
        * @see GroupByInterface
        * @see IndexByInterface
        * @see CountByInterface
        * @see PartitionInterface
        */

        public Map<String, List<Object>> groupBy(Type retType, List<Object> objs){
            /*  By adding the type value, we are simplifying how we cast objects back. */
            Map<String, List<Object>> ret = (Map<String, List<Object>>)retType.newInstance();

            for(Object o: objs){
                String group_name = partitionFn((SObject) o);
                if (ret.get(group_name) == null)
                    ret.put(group_name, new List<SObject>());
                ret.get(group_name).add(o);
            }
            return ret;
        }

        public Map<String, List<Object>> groupBy(List<Object> objs){
            return groupBy(Map<String, List<Object>>.class, objs);
        }
        
        public Map<String, Object> indexBy(List<Object> objs){
            Map<String, SObject> ret = new Map<String, SObject>();

            for(Object o: objs){
                SObject so = (SObject) o;
                String group_name = partitionFn(so);
                ret.put(group_name, so);
            }
            return ret;
        }


        public Map<String, Integer> countBy(List<SObject> objs){
            Map<String, Integer> ret = new Map<String, Integer>();

            for(Sobject o: objs){
                String group_name = partitionFn(o);
                Integer val = ret.get(group_name) == null ? 1 : ret.get(group_name) + 1;
                ret.put(group_name, val);
            }
            return ret;
        }

        public abstract String partitionFn(SObject obj); // generates partition name
    }

    
    public abstract class ReduceRightInterfaceAbstract implements ReduceRightInterface{
        // TODO: Should we merge this with ReduceInterfaceAbstract?  Seems to make more sense that way.

        public SObject reduceright(List<SObject> objs){
            if (objs.size() == 0){
                return null;
            }
            if (objs.size() == 1){
                return objs[0];
            }
            SObject memo = objs[objs.size()-1]; // initial object.
            for(Integer i = objs.size()-1; i >= 0; i--){
                memo = reducerightfn(objs, objs[i], memo, objs.size()-1-i);
            }
            return memo;
        }
        public abstract SObject reducerightfn(List<SObject> lst, SObject iteratee, SObject memo, Integer index);
    }

    public abstract class ReduceInterfaceAbstract implements ReduceInterface{
        // TODO: Should we merge this with ReduceRightInterfaceAbstract?  Seems to make more sense that way.

        public SObject reduce(List<SObject> objs){
            if (objs.size() == 0){
                return null;
            }
            if (objs.size() == 1){
                return objs[0];
            }
            SObject memo = objs[0];
            for(Integer i = 1; i < objs.size(); i++){
                memo = reduceFn(objs, objs[i], memo, i-1);
            }
            return memo;
        } 

        public abstract SObject reducefn(List<SObject> lst, SObject value, SObject memo, Integer index);
    }

    public abstract Class CollectInterfaceAbstract implements CollectInterface{
 
        public abstract Object collectfn(List<SObject> lst, SObject value, Integer index);

        public List<Object> collect(List<SObject> objs){
            Integer i = 0;
            List<Object> ret = new List<Object>();
            for(SObject o: objs){
                ret.add(collectfn(objs, o, i));
                i += 1;
            }
            return ret;
        }
    }

    public abstract Class EachInterfaceAbstract implements EachInterface{
        public abstract void eachfn(List<SObject> lst, SObject value, Integer index);

        public List<SObject> each(List<SObject> objs){
            Integer i = 0;
            for(SObject o: objs){
                eachfn(objs, o, i);
                i += 1;
            }
            return objs;
        }
    }


    public abstract class FilterInterfaceAbstract implements FilterInterface{
        // TODO: Should we rename this as it implements items other than filter?

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
                    system.debug(memo);
                    system.debug(value);
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

    public List<Object> collect(CollectInterface behavior){
      /**
      * Produces a new array of values by mapping each value in list 
      * through a transformation function (behavior.collectfn). The collectfn is 
      * passed three arguments: the value, then the index (or key) of 
      * the iteration, and finally a reference to the entire list.
      */
        // This mutates the object.  Rewinding only restores the original list, not the original values.
        return behavior.collect(objs);
    }

    public US each(EachInterface behavior){
        // This mutates the object.  Rewinding only restores the original list, not the original values.
        mutated = true;
        objs = behavior.each(objs);
        return this;
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
        // Returns the first item we find which matches the value we are looking for.
        objs = behavior.filter(objs);
        return objs.size() > 0 ? objs[0] : null;
    }


    /** 
    * WHY:  Remove the loop / matching boilerplate from the main function expression.
    * WHY:  Create reusable filters which can be applied to all SObjects
    * WHY:  Create side-effects which push best practices 
    * HOW:  Create a class which extends FilterInterfaceAbstract and has a name which implies its function.
    * EXAMPLE: 
    *       US x = new US([select id, email from User]);
    *       x.filter('MyClass.GmailEmailsOnly').filter('MyClass.CreatedToday');
    *
    *
    *       class CreatedToday extends FilterInterfaceAbstract{
    *           public override boolean filterfn(List<SObject> memo, SObject value){
    *               return (Date) value.get('CreatedDate') == System.today();
    *           }
    *       }
    *       
    *       class GmailEmailsOnly extends FilterInterfaceAbstract{
    *           public override void filterfn(List<SObject> memo, SObject value){
    *               return ((String) value.get('email')).contains('gmail');
    *           }
    *       }
    *
    * TODO: A sane default interface 
    *    x.filter('id', something).filter('field__c', something)...
    *
    *
    */

    public class InvalidComparatorException extends Exception {
    
    }

    public US filter(FilterInterfaceAbstract behavior){
        objs = behavior.filter(objs);
        return this;
    }

    public US filter(String field, Object val){
        if(val instanceof List<Object>){
            val = new Set<Object>((List<Object>)val);
        }

        if(val instanceof Set<Object>){
            if (default_filter_behavior_col == null) 
                default_filter_behavior_col = new FilterFieldInValueCollection(field, (Set<Object>) val);
            else default_filter_behavior_col.set(field, (Set<Object>) val);
            return filter(default_filter_behavior_col);
        }
        if (default_filter_behavior_eq == null) default_filter_behavior_eq = new FilterFieldEqualToValue(field, val);
        else default_filter_behavior_eq.set(field, val);
        return filter(default_filter_behavior_eq);
    }

    public US filter(String field, String comparitor, Object val){
        Set<String> VALID_COMPARITORS = new Set<String>{'<', '>', '<=', '>=', '=='}; // ()
        if (!VALID_COMPARITORS.contains(comparitor)){
          throw new InvalidComparatorException();
        }
        if (default_filter_behavior_cmp == null) default_filter_behavior_cmp = new FilterCompareFieldToValue(field, comparitor, val);
        else default_filter_behavior_cmp.set(field, comparitor, val);
        return filter(default_filter_behavior_cmp);
    }

    public US reject(FilterInterfaceAbstract behavior){
        objs = behavior.reject(objs);
        return this;
    }

    public US reject(String field, Object val){

        if(val instanceof List<Object>){
            system.debug('List reject');
            val = new Set<Object>((List<Object>)val);
        }
        
        if(val instanceof Set<Object>){
            system.debug('Set / List FilterFieldInValueCollection reject');
			FilterFieldInValueCollection behavior = new FilterFieldInValueCollection(field, (Set<Object>) val);
            return reject(behavior);
        }

        system.debug('Regular reject');
        if (default_filter_behavior_eq == null) default_filter_behavior_eq = new FilterFieldEqualToValue(field, val);
        else default_filter_behavior_eq.set(field, val);

        return reject(default_filter_behavior_eq);
    }

    public US reject(String field, String comparitor, Object val){
        Set<String> VALID_COMPARITORS = new Set<String>{'<', '>', '<=', '>=', '=='};
        if (!VALID_COMPARITORS.contains(comparitor)){
          throw new InvalidComparatorException();
        }
        if (default_filter_behavior_cmp == null) default_filter_behavior_cmp = new FilterCompareFieldToValue(field, comparitor, val);
        else default_filter_behavior_cmp.set(field, comparitor, val);
        return reject(default_filter_behavior_cmp);
    }
    
    public Boolean every(FilterInterfaceAbstract behavior){
        return behavior.every(objs);
    }

    public Boolean some(FilterInterfaceAbstract behavior){
        return behavior.some(objs);
    }
    
    public Boolean contains(SObject x){
        /*  Why no class behavior?  Contains seems, to me, to be testing for the presence of an object, and has a very 
        clear meaning in SFDC.  If you want to look for a specific condition existing, you would use "some".

        Thoughts: This is dependent on the Set Contains function, which has certain limitations.  
        Matching by ID may be more sensible for SObjects.
        */
        return (new Set<SObject>(objs)).contains(x);
    }
    
    public void invoke(String fqdn_behavior_cls){
        // We cannot dynamically invoke a function or a method in Salesforce.
        // you should use collect / map to mutate the collection 
        throw new UnimplementedUnderscoreException('Invoke is not available on Salesforce');
    }

    public List<Object> pluck(Type resListType, String field){
        List<Object> ret = (List<Object>)resListType.newInstance();
        for(Sobject o: objs){
            ret.add(o.get(field));
        }
        return ret;
    }

    public List<Object> pluck(String field){ /* Needs clarity wrt object vs. sobject */
        List<Object> ret = new List<Object> (); 
        for(Sobject o: objs){
            ret.add(o.get(field));
        }
        return ret;
    }
    
    public List<Id> pluckid(String field){ // This happens so often that we can add this as a case.
      return (List<Id>) US.stringify(pluck(field));
    }

    public Object max(String field){
        /*
            Is there a way to handle Max w/ the default Object instead of 
            casting & passing a function?  Does it work with something else? 
        */

        throw new UnimplementedUnderscoreException('Not yet implemented.');
    }

    public Object min(String field){
        /*
            Is there a way to handle min w/ the default Object instead of 
            casting & passing a function?  Does it work with something else? 
        */

        throw new UnimplementedUnderscoreException('Not yet implemented.');
    }
        
    public US sortBy(){
        /*  SFDC standard sorting methodology. */
        objs.sort();
        return this;
    }

    public Map<String, List<Object>> groupBy(GroupByInterface behavior){
        return behavior.groupBy(objs);
    }


    public Map<String, Object> indexBy(IndexByInterface behavior){
        return behavior.indexBy(objs);
    }


    public Map<String, Integer> countBy(CountByInterface behavior){
        return behavior.countBy(objs);
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

    public SObject first(){
      if (objs.size() > 0)
        return objs[0];
      return null;
    }

    
    public US rewind(){
        objs = original_objs;
        return this;
    }

    public Integer size(){
        return objs.size();
    }
    
    public US(List<SObject> items){
        objs = items;
        original_objs = items;
        mutated = false;
        i = 0;
    }

    /*  Static functions to deal with returned data; we may want to modify how we handle this in teh future.*/
    
    public static List<String> stringify(List<Object> objs){
        /* How to integrate this? */
        List<String> ret = new List<String>();
        for (Object o: objs){
            ret.add((String) o);
        }
        return ret;
    }

}
