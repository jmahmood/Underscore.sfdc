@isTest
public class US_Test {
    static List<User> test_users(){
        return new List<User>{
            new User(firstname = 'Jawaad', email='FakeEmail1@example.org'),
            new User(firstname = 'Hammy', email='FakeEmail2@example.org'),
            new User(firstname = 'Koby', email='FakeEmail3@example.org'),
            new User(firstname = 'Lily', email='FakeEmail4@example.org'),
            new User(firstname = 'Sue', email='FakeEmail5@example.org')
        };        
    }

    static List<User> test_users_with_gmail_also(){
        List<User> all_test_users  = test_users();
        all_test_users.add(
        	new User(firstname='Dammy', email='Dammy@gmail.com'));
        
        all_test_users.add(
        	new User(firstname='Vinny', email='Vinny@gmail.com')
        );
        
        return all_test_users;
    }
    
    static testmethod void contains_test_without_id(){

		List<User> users = test_users();
        US users_us = new US(users);

        User same_object = users[0];
        User fake_user = new User(firstname = 'I am fake');

        System.assert(users_us.contains(same_object));
        System.assert(!users_us.contains(fake_user));

        User same_name_different_object = new User(firstname = 'Jawaad', email='FakeEmail1@example.org');
        System.assert(users_us.contains(same_name_different_object)); // Uses duck typing

        User same_name_additional_values_object = new User(firstname = 'Jawaad', email='fakeemail@example.org');
        System.assert(!users_us.contains(same_name_additional_values_object));
    }

    static testmethod void unimplemented_tests(){
    	/* This is for items which are marked as unimplemented.  */
        US x = new US([select id, firstname, name, email from User Where isActive = true order by firstname limit 10]);
        try{
	        x.invoke('US.pluck');
	        System.assert(True == False); // If we don't throw an exception, there is a problem.
        }catch(US.UnimplementedUnderscoreException e){
        }

        try{
	        x.max('email');
	        System.assert(True == False); // If we don't throw an exception, there is a problem.
        }catch(US.UnimplementedUnderscoreException e){
        }


        try{
	        x.min('email');
	        System.assert(True == False); // If we don't throw an exception, there is a problem.
        }catch(US.UnimplementedUnderscoreException e){
        }


        try{
	        x.shuffle();
	        System.assert(True == False); // If we don't throw an exception, there is a problem.
        }catch(US.UnimplementedUnderscoreException e){
        }


        try{
	        x.sample(5);
	        System.assert(True == False); // If we don't throw an exception, there is a problem.
        }catch(US.UnimplementedUnderscoreException e){
        }

    }

    static testmethod void wherehas_test(){
        List<User> users = test_users();
        US users_us = new US(users);
        User u = new User(firstname=users[0].firstname);
        users_us.wherehas(u, new String[]{'firstname'}); // Filter users who have the same first name as u.

        for (User u1: (List<User>) users_us.toList() )
            system.Assert(u1.firstname == u.firstname);
    }

    static testmethod void findwhere_test(){
        List<User> users = test_users();
        US users_us = new US(users);
        User u = new User(email='FakeEmail1@example.org');
        User found_user = (User) users_us.findwhere(u, new String[]{'email'});
        system.Assert(found_user.firstname == 'Jawaad');
        system.Assert(found_user.email == 'FakeEmail1@example.org');

        User fake_u = new User(email='NonExistentFakeEmail@example.org');
        User not_found_user = (User) users_us.findwhere(fake_u, new String[]{'email'});
        system.debug(not_found_user);
        system.Assert(not_found_user == null);
    }    

    static testmethod void findnewest_test(){
        List<Opportunity> test_opportunities = new List<Opportunity>{
            new Opportunity(name='OP Test 1', CloseDate=Date.Today().addDays(-5)),
            new Opportunity(name='OP Test 1', CloseDate=Date.Today().addDays(-8)),
            new Opportunity(name='OP Test 2', CloseDate=Date.Today().addDays(-3))
        };
        US x = new US(test_opportunities);
        Opportunity newest = (Opportunity) x.reduce(new US.KeepNewest('CloseDate'));
        for(Opportunity u: test_opportunities){
            system.Assert(u.CloseDate <= newest.CloseDate);
        }
    }

    public Class ModifyEachEmail extends US.EachInterfaceAbstract{
        public override void eachfn(List<SObject> lst, SObject value, Integer index){
            User u = (User) value;
            u.email = 'each.' + u.email;
        }
    }

    static testmethod void each_fn(){
        US x = new US(test_users());
        ModifyEachEmail update_emails = new ModifyEachEmail();
        x.each(update_emails);

        for (User u: (List<User>) x.toList()){
            system.Assert(u.email.startsWith('each.'));
        }
    }

    static testmethod void each_fn_v2(){
        US x = new US(test_users());
        x.each('email', 'fakeemail@example.org');

        for (User u: (List<User>) x.toList()){
            system.Assert(u.email == 'fakeemail@example.org');
        }
    }
    
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
        public override SObject reduceFn(List<SObject> lst, SObject value, SObject memo, Integer index){
            memo.put('firstname', (String) value.get('firstname'));
            return memo;
        }
    }
    
    public Class GmailOnly extends US.FilterInterfaceAbstract{
        public override boolean filterfn(List<SObject> memo, SObject value){
            return ((String) value.get('email')).contains('gmail');
        }
    }

    public Class ExampleEmailsOnly extends US.FilterInterfaceAbstract{
        public override boolean filterfn(List<SObject> memo, SObject value){
            return ((String) value.get('email')).contains('example.org');
        }
    }

    static testmethod void collect_interface_test(){
        List<User> users = test_users();
        US x = new US(users);
        List<Object> test_firstnames = x.collect(new CollectInterfaceTest());
        for (Object t_fn: test_firstnames){
            system.Assert(((String) t_fn).startsWith('test: '));
        }
    }

    static testmethod void collect_interface_stringify_test(){
        List<User> users = test_users();
        US x = new US(users);
        List<Object> test_firstnames = x.collect(new CollectInterfaceTest());

        for (String t_fn: US.stringify(test_firstnames)){
            system.Assert(t_fn.startsWith('test: '));
        }
    }

    static testmethod void reduce_edgecase_test(){
        List<User> users = new List<User>();
        US x = new US(users);
        system.assert(x.first() == null);
        system.assert(x.reduce(new ReduceInterfaceTest()) == null);

        List<User> users_v2 = new List<User>{test_users()[0]};
        x = new US(users_v2);
        system.assert(x.reduce(new ReduceInterfaceTest()) == users_v2[0]);
    }


    static testmethod void reduceright_edgecase_test(){
        List<User> users = new List<User>();
        US x = new US(users);
        system.assert(x.first() == null);
        system.assert(x.reduceright(new ReduceRightInterfaceTest()) == null);

        List<User> users_v2 = new List<User>{test_users()[0]};
        x = new US(users_v2);
        system.assert(x.reduceright(new ReduceRightInterfaceTest()) == users_v2[0]);
    }
    
    static testmethod void reduce_interface_test(){
        List<User> users = test_users();
        US x = new US(users);
        x.reduce(new ReduceInterfaceTest());
        system.Assert(users[0].firstname == users[4].firstname);
        system.Assert(users[0].email != users[4].email);
    }

    static testmethod void reduceright_interface_test(){
        List<User> users = test_users();
        US x = new US(users);
        x.reduceright(new ReduceRightInterfaceTest());
        system.Assert(users[4].firstname == users[0].firstname);
        system.Assert(users[4].email != users[0].email);
    }

    static testmethod void filter_interface_test(){
        List<User> users = test_users_with_gmail_also();
        US x = new US(users);
        x.filter(new GmailOnly());
        for(User u: (List<User>) x.toList()){
	        system.Assert(u.email.contains('gmail'));
        }

        // TODO: probably should move to its own method.
        List<User> users_nogmail = test_users();
        US x_nogmail = new US(users_nogmail);
        system.assert(x_nogmail.some(new GmailOnly()) == false);
        system.assert(x_nogmail.every(new ExampleEmailsOnly()));
    }

    static testmethod void filterstrings_test(){
        List<User> users = test_users();
        US x = new US(users);

        US.FilterFieldStrings name_filter = new US.FilterFieldStrings('firstname', users[0].firstname);
        x.filter(name_filter);

        for(User u: (List<User>) x.toList()){
            system.Assert(u.firstname == users[0].firstname);
        }
    }

    static testmethod void filterintegers_noclass_test(){
        US users_us = new US(new List<User>{
            new User(Latitude =20),
            new User(Latitude =30),
            new User(Latitude =40),
            new User(Latitude =50),
            new User(Latitude =10)
        });
        
        users_us.filter('Latitude', '>=', Double.valueOf('30'));

        for(User u: (List<User>) users_us.toList()){
            system.Assert(u.Latitude >= 30);
        }
        
        system.assert(users_us.size() == 3);

        users_us.rewind().filter('Latitude', '>', Double.valueOf('30'));

        for(User u: (List<User>) users_us.toList()){
            system.Assert(u.Latitude > 30);
        }

        system.assert(users_us.size() == 2);
        
        users_us.rewind().filter('Latitude', '<=', Double.valueOf('30'));

        for(User u: (List<User>) users_us.toList()){
            system.Assert(u.Latitude <= 30);
        }

        system.assert(users_us.size() == 3);
        
        users_us.rewind().filter('Latitude', '<', Double.valueOf('30'));

        for(User u: (List<User>) users_us.toList()){
            system.Assert(u.Latitude < 30);
        }

        system.assert(users_us.size() == 2);

    }
    
    static testmethod void rejectintegers_noclass_test(){
        US users_us = new US(new List<User>{
            new User(Latitude =20),
            new User(Latitude =30),
            new User(Latitude =40),
            new User(Latitude =50),
            new User(Latitude =10)
        });
        
        users_us.reject('Latitude', '>=', Double.valueOf('30'));

        for(User u: (List<User>) users_us.toList()){
            system.Assert(u.Latitude < 30);
        }
        
        system.assert(users_us.size() == 2);

        users_us.rewind().reject('Latitude', '>', Double.valueOf('30'));

        for(User u: (List<User>) users_us.toList()){
            system.Assert(u.Latitude <= 30);
        }

        system.assert(users_us.size() == 3);
        
        users_us.rewind().reject('Latitude', '<=', Double.valueOf('30'));

        for(User u: (List<User>) users_us.toList()){
            system.Assert(u.Latitude > 30);
        }

        system.assert(users_us.size() == 2);
        
        users_us.rewind().reject('Latitude', '<', Double.valueOf('30'));

        for(User u: (List<User>) users_us.toList()){
            system.Assert(u.Latitude >= 30);
        }

        system.assert(users_us.size() == 3);

    }


    static testmethod void filterstrings_noclass_test(){
        List<User> users = [select id, firstname, name, email from User Where isActive = true and firstname != '' order by firstname limit 10];
        US x = new US(users);

        x.filter('firstname', users[0].firstname);

        for(User u: (List<User>) x.toList()){
            system.Assert(u.firstname == users[0].firstname);
        }

        x.rewind().filter('firstname', new List<String>{users[0].firstname, users[1].firstname});

        for(User u: (List<User>) x.toList()){
            system.Assert(u.firstname == users[0].firstname || u.firstname == users[1].firstname);
        }

        x.rewind().filter('firstname', new Set<String>{users[0].firstname, users[1].firstname});

        for(User u: (List<User>) x.toList()){
            system.Assert(u.firstname == users[0].firstname || u.firstname == users[1].firstname);
        }
    }    


    static testmethod void rejectstrings_noclass_test(){
        List<User> users = test_users();
        US x = new US(users);

        x.rewind().reject('firstname', users[0].firstname);

        for(User u: (List<User>) x.toList()){
            system.Assert(u.firstname != users[0].firstname);
        }

        // Set<String> is not recognized as a subset of Set<Object>; you need to declare your list of objects as Set<Object>
        x.rewind().reject('firstname', new Set<Object>{users[0].firstname, users[1].firstname});
        for(User u: (List<User>) x.toList()){
            system.Assert(u.firstname != users[0].firstname);
            system.Assert(u.firstname != users[1].firstname);
        }
        
        x.rewind().reject('firstname', new List<String>{users[0].firstname, users[1].firstname});
        for(User u: (List<User>) x.toList()){
            system.Assert(u.firstname != users[0].firstname && u.firstname != users[1].firstname);
        }

        try{
	        x.rewind().reject('firstname', '==', users[0].firstname);
            system.assert(False); // you cannot use this for a string comparison.
        }
        catch(US.InvalidComparatorException e){
            system.assert(True);
        }

        // TODO: Probably should move this elsewhere; where?
        try{
	        x.rewind().filter('firstname', 'FakeComparison', users[0].firstname);
            system.assert(False); // you cannot use this for a string comparison.
        }
        catch(US.InvalidComparatorException e){
            system.assert(True);
        }        
        
        try{
	        x.rewind().reject('firstname', 'FakeComparison', users[0].firstname);
            system.assert(False); // you cannot use this for a string comparison.
        }
        catch(US.InvalidComparatorException e){
            system.assert(True);
        }
    }
    
    static testmethod void rejectstrings_test(){
        List<User> users = test_users();
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
        List<User> users = test_users();
        US x = new US(users);

        US.FilterFieldStrings name_filter = new US.FilterFieldStrings('firstname', users[0].firstname);
        System.assert(x.some(name_filter));

    }

    static testmethod void pluck_string_test(){
        // Same order and same values, just untyped.
        // 
        List<User> users = test_users();
        US x = new US(users);
        List<Object> firstname_untyped = x.pluck('firstname');
        List<String> firstname_typed = (List<String>) x.pluck(List<String>.class, 'firstname');
        List<String> firstname_typed_ol = (List<String>) US.OL(test_users()).pluck(List<String>.class, 'firstname');
        system.assert(firstname_untyped.size() == firstname_typed.size());
        
        for(Integer i=0; i< firstname_untyped.size(); i++){
			Object fu = firstname_untyped[i];
			String ft = firstname_typed[i];
			String ftol = firstname_typed_ol[i];
            system.assert(fu == ft);
            system.assert(fu == ftol);
        }
        List<String> multipluck = (List<String>) x.pluck(List<String>.class, new String[]{'firstname', 'email'});
        List<Object> multipluck_v2 = x.pluck(new String[]{'firstname', 'email'});
        system.assert(multipluck.size() == multipluck_v2.size());

        Set<String> plucked_vals = new Set<String>(multipluck);
        for(User u : (List<User>) x.toList()){
            system.assert(plucked_vals.contains(u.firstname));
            system.assert(plucked_vals.contains(u.email));
        }
    }

    static testmethod void filterids_test(){
        List<User> users = [select id, firstname, name, email, ManagerId from User where isActive = true and ManagerId != null and ManagerId != '' limit 2];

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
        List<User> all_users = test_users_with_gmail_also();

        US x = new US(all_users);
        PartitionEjEmails partition_emails = new PartitionEjEmails();
        Map<String, List<Object>> grouped_users = x.groupby(partition_emails);

        Integer gmail_user_count = 0;
        for(Object u: grouped_users.get('gmail')){
            System.Assert( ((User) u).Email.contains('gmail'));
            gmail_user_count += 1;
        }

        for(Object u: grouped_users.get('other')){
            System.Assert(!((User)u).Email.contains('gmail'));
        }

        Map<String, Integer> counted_users = x.rewind().countby(partition_emails);
        system.assert(counted_users.get('gmail') == gmail_user_count);

        Map<String, Object> index_users = x.rewind().indexby(partition_emails);
        system.assert( ((User) index_users.get('gmail')).email.contains('gmail'));

        system.assert((User) x.rewind().find(new GmailOnly()) != null);

    }
}
