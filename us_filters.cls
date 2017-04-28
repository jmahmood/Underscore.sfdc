public class US_Filters{
    /*  *********************************  */
    /*  Generic Filters                    */
    /*  *********************************  */

    public virtual class MapContainsKey extends US.FilterInterfaceAbstract {
        /*
        Use case: We have a Map generated elsewhere, with a set of valid keys.
        We check the map to make sure that the SObject we are passing is valid, based on whether a field exists in the map's keys.
  		*/
        final private Map<Object, SObject> filter_mp;
        final private String filter_field;
        
        public MapContainsKey(String field, Map<Object, SObject> mp){
            filter_mp = mp;
            filter_field = field;
        }
        
        public virtual override boolean filterfn(List<SObject> memo, SObject value){
            return filter_mp.containsKey(value.get(filter_field));
        }
    }
}
