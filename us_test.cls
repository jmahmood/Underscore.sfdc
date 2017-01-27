@isTest
public class LC_Test {
    public Class CollectInterfaceTest implements LC.CollectInterface{
        public List<SObject> collect(List<SObject> objs){
            for(SObject o: objs){
                o.put('firstname', 'test: ' + (String) o.get('firstname'));
            }
            return objs;
        }
    }

    public Class ReduceRightInterfaceTest extends LC.ReduceRightInterfaceAbstract{
        public SObject reducerightfn(SObject memo, SObject value, Integer index, List<SObject> lst){
            memo.put('firstname', (String) value.get('firstname'));
            return memo;
        }
    }
    
    public Class ReduceInterfaceTest extends LC.ReduceInterfaceAbstract{
        public SObject reduceFn(SObject memo, SObject value, Integer index, List<SObject> lst){
            memo.put('firstname', (String) value.get('firstname'));
            return memo;
        }
    }
    
    public Class FilterTest extends LC.FilterInterfaceAbstract{
        public override void filterfn(List<SObject> memo, SObject value){
            if (((String) value.get('email')).contains('gmail'))
                memo.add(value);
        }
    }

    static testmethod void collect_interface_test(){
        List<User> users = [select id, firstname, name from User limit 10];
        LC x = new LC(users);
        x.collect(new CollectInterfaceTest());
        for (User u: users){
            system.Assert(u.firstname.startsWith('test: '));
        }
    }

    static testmethod void reduce_interface_test(){
        List<User> users = [select id, firstname, name, email from User limit 10];
        LC x = new LC(users);
        x.reduce(new ReduceInterfaceTest());
        system.Assert(users[0].firstname == users[9].firstname);
        system.Assert(users[0].email != users[9].email);
        system.Assert(users[0].name != users[9].name);
    }

    static testmethod void reduceright_interface_test(){
        List<User> users = [select id, firstname, name, email from User limit 10];
        LC x = new LC(users);
        x.reduceright(new ReduceRightInterfaceTest());
        system.Assert(users[9].firstname == users[0].firstname);
        system.Assert(users[9].email != users[0].email);
        system.Assert(users[9].name != users[0].name);
    }


    static testmethod void filter_interface_test(){
        List<User> users = [select id, firstname, name, email from User limit 10];
        LC x = new LC(users);
        x.filter(new FilterTest());
        for(Sobject u: x.objs){
	        system.Assert(((String) u.get('email')).contains('gmail'));
        }
    }
    
}
