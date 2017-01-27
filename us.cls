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

    /*	These abstract classes allow us to implement the logical function only */
    public abstract class ReduceRightInterfaceAbstract implements ReduceRightInterface{
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
        public SObject reduce(List<SObject> objs){ /*	This probably has to be copied into an abstract class so we only implmeent the fn itself.*/
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
    
    public abstract class FilterInterfaceAbstract implements FilterInterface{
        public List<SObject> filter(List<SObject> lst){
            List<SObject> memo = new List<SObject>();
            for (SObject value : lst){
                filterfn(memo, value);
            }
            return memo;
        }
        
        public abstract void filterfn(List<SObject> memo, SObject value);
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

    public LC filter(FilterInterfaceAbstract behavior){ // This implies that the field value is an SObject.
        objs = behavior.filter(objs);
        return this;
    }

    public LC(List<SObject> items){
        objs = items;
        original_objs = items;
        mutated = false;
        i = 0;
    }
    
}
