@isTest
public class US_Test {
    public Class PartitionEjEmails extends US.PartitionInterfaceAbstract{
        public override String partitionFn(SObject obj){
            if (((User) obj).Email.contains('gmail')){
                return 'gmail';
            }
            return 'other';
        } // generates partition name
    }

    public Class CollectInterfaceTest extends US.CollectInterfaceAbstract{
        public override Object collectfn(List<SObject> lst, SObject value, Integer index){
            return 'test: ' + (String) value.get('firstname');
        }
    }

    public Class ReduceRightInterfaceTest extends US.ReduceRightInterfaceAbstract{
        /*  Keep the intitial object, just change the name every time to the first name of the value object passed. */
        public override SObject reducerightfn(List<SObject> lst, SObject value, SObject memo, Integer index){
            memo.put('firstname', (String) value.get('firstname'));
            return memo;
        }
    }
    
    public Class ReduceInterfaceTest extends US.ReduceInterfaceAbstract{
        public override SObject reduceFn(List<SObject> lst, SObject memo, SObject value, Integer index){
            memo.put('firstname', (String) value.get('firstname'));
            return memo;
        }
    }
    
    public Class GmailOnly extends US.FilterInterfaceAbstract{
        public override boolean filterfn(List<SObject> memo, SObject value){
            return ((String) value.get('email')).contains('gmail');
        }
    }

    static testmethod void collect_interface_test(){
        List<User> users = [select id, firstname, name from User where isActive = true limit 10];
        US x = new US(users);
        List<Object> test_firstnames = x.collect(new CollectInterfaceTest());
        for (Object t_fn: test_firstnames){
            system.Assert(((String) t_fn).startsWith('test: '));
        }
    }

    static testmethod void collect_interface_stringify_test(){
        List<User> users = [select id, firstname, name from User where isActive = true limit 10];
        US x = new US(users);
        List<Object> test_firstnames = x.collect(new CollectInterfaceTest());

        for (String t_fn: US.stringify(test_firstnames)){
            system.Assert(t_fn.startsWith('test: '));
        }
    }
    static testmethod void reduce_interface_test(){
        List<User> users = [select id, firstname, name, email from User where isActive = true limit 10];
        US x = new US(users);
        x.reduce(new ReduceInterfaceTest());
        system.Assert(users[0].firstname == users[9].firstname);
        system.Assert(users[0].email != users[9].email);
        system.Assert(users[0].name != users[9].name);
    }

    static testmethod void reduceright_interface_test(){
        List<User> users = [select id, firstname, name, email from User where isActive = true limit 10];
        US x = new US(users);
        x.reduceright(new ReduceRightInterfaceTest());
        system.Assert(users[9].firstname == users[0].firstname);
        system.Assert(users[9].email != users[0].email);
        system.Assert(users[9].name != users[0].name);
    }

    static testmethod void filter_interface_test(){
        List<User> users = [select id, firstname, name, email from User where isActive = true limit 10];
        US x = new US(users);
        x.filter(new GmailOnly());
        for(Sobject u: x.objs){
            system.Assert(((String) u.get('email')).contains('gmail'));
        }
    }

    static testmethod void findnewest_test(){
        List<Account> accounts = [select Id, name, LastActivityDate from Account where LastActivityDate != null limit 10];
        US x = new US(accounts);
        Account newest = (Account) x.reduce(new US.KeepNewest('LastActivityDate'));
        for(Account u: accounts){
            system.Assert(u.LastActivityDate <= newest.LastActivityDate);
        }
    }

    static testmethod void filterstrings_test(){
        List<User> users = [select id, firstname, name, email from User Where isActive = true order by firstname limit 10];
        US x = new US(users);

        US.FilterFieldStrings name_filter = new US.FilterFieldStrings('firstname', users[0].firstname);
        x.filter(name_filter);

        for(User u: (List<User>) x.toList()){
            system.Assert(u.firstname == users[0].firstname);
        }
    }


    static testmethod void rejectstrings_test(){
        List<User> users = [select id, firstname, name, email from User Where isActive = true order by firstname limit 10];
        US x = new US(users);

        US.FilterFieldStrings name_filter = new US.FilterFieldStrings('firstname', users[0].firstname);
        x.reject(name_filter);

        for(User u: (List<User>) x.toList()){
            system.Assert(u.firstname != users[0].firstname);
        }
    }


    static testmethod void everystrings_test(){
        List<User> users = [select id, firstname, name, email from User Where isActive = true limit 10];
        US x = new US(users);

        US.FilterFieldIds id_filter = new US.FilterFieldIds('id', users[0].Id);
        System.assert(!x.every(id_filter));
    }


    static testmethod void somestrings_test(){
        List<User> users = [select id, firstname, name, email from User Where isActive = true order by firstname limit 10];
        US x = new US(users);

        US.FilterFieldStrings name_filter = new US.FilterFieldStrings('firstname', users[0].firstname);
        System.assert(x.some(name_filter));

    }


    static testmethod void filterids_test(){
        List<User> users = [select id, firstname, name, email, ManagerId from User where isActive = true and ManagerId != null limit 2];

        US x = new US(users);

        List<User> managers = [select id, firstname, name, email, ManagerId from User where id=: (List<Id>) x.pluckid('ManagerId')];

        US y = new US(managers);

        for (User u: users){
            US.FilterFieldIds manager_filter = new US.FilterFieldIds('Id', u.ManagerId);
            y.rewind().filter(manager_filter);
            system.Assert(((User) y.first()).Id == u.ManagerId);
        }
    }


    static testmethod void filterparition_fn(){
        List<User> users = [select id, firstname, name, email from User Where isActive = true order by firstname limit 10];
        List<User> gmail_users = [select id, firstname, name, email from User Where email LIKE '%gmail%' AND isActive = true order by firstname limit 10];
        List<User> all_users = new List<User>();
        all_users.addAll(users);
        all_users.addAll(gmail_users);

        US x = new US(all_users);
        PartitionEjEmails partition_emails = new PartitionEjEmails();
        Map<String, Set<SObject>> grouped_users = x.groupby(partition_emails);

        Integer gmail_user_count = 0;
        for(SObject u: grouped_users.get('gmail')){
            System.Assert( ((User) u).Email.contains('gmail'));
            gmail_user_count += 1;
        }
        for(SObject u: grouped_users.get('other')){
            System.Assert(! ((User)u).Email.contains('gmail'));
        }

        Map<String, Integer> counted_users = x.rewind().countby(partition_emails);
        system.assert(counted_users.get('gmail') == gmail_user_count);

        Map<String, SObject> index_users = x.rewind().indexby(partition_emails);
        system.assert( ((User) index_users.get('gmail')).email.contains('gmail'));

    }

}