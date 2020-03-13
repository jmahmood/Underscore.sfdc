# Underscore.sfdc
This is an on-again off-again experiment to see how much of the underscore.js api one could implement using the APEX language on Salesforce.com.  

This code isn't stable and will change between versions.  Use at your own risk.

# Goal

- I want an excellent, easy-to-use, list processing library, with examples, that I can pass to my vendors.

- I want a developer who knows JavaScript and a little Java to be able to come in and outperform our vendors.

- I want to eliminate, forever, the "too many SOQL queries" nonsense by replacing queries with list comprehensions and list functions.

# Current Status
Collections: 20 / 25
Arrays: 0 / 20
Functions: 0 / 14
Objects: 0 / 38 
Utility: 0 / 14


# How to Use

There are "sane" default implementations of most collection-related functions, as well as behavior-altering classes that you can override and pass to each function.  Some of the more common ones are detailed below.


## US.OL

US.OL ("One-liner") allows you to chain various requests without storing a newly initialized US object.

		public static void setStatusToUnavailable(List<Account> accounts) {
			List<Account> accounts_to_update = (List<Account>) US.OL(accounts).exclude('status__c', "==", "unavailable").toList();
			US.OL(accounts_to_update).each('status__c', 'unavailable');
		}


## Filter

Allows you to extract all records that meet a specific criteria.

### Simple Use Case

By allowing you to easily filter out accounts related to a specific person, it is far easier to bulkify your requests.

		public static List<Account> findSalespersonAccounts(List<Account> all_accounts, User salesperson) {
			return (List<Account>) US.OL(all_accounts).filter('OwnerId', salesperson.Id).toList();
		}


### Real-World Use Case

Salesforce's formula and roll-up fields are quite useful, but they do not trigger changes or events if there is a change made to a child object (as they are only determed at query time).  If you have an integration that is dependent on this, you may want to use a trigger to update the parent object.

The actual case below has LineItem__c objects which have not yet been saved, and pre-existing LineItem__c items that need to be merged and examined.  

The benefit of Underscore.sfdc is that you can reduce the noise around the two lines that matter.


		public static void loadAndRefreshParents(List<LineItem__c> items) {
			// A trigger updates a large set of LineItem__c objects.  
			List<String> parent_ids = (List<String>) US.OL(items).pluck('Parent__c');


			// Load related parent objects.
			List<ParentObj__c> parent_objs = [SELECT id, NoLineItems__c, LineItemsThatAreChecked__c FROM ParentObj__c WHERE id =: parent_ids];


			// Load any other lineitems that already exist but are not being used.
			List<LineItem__c> preexisting_lineitems = [SELECT id, Parent__c, CheckboxField__c FROM LineItem__c WHERE Parent__c =: parent_ids];


			for (ParentObj__c po: parent_objs){
				US related_pre_existing_lineitems = US.OL(preexisting_lineitems).filter('Parent__c', po.Id);

				US related_new_lineitems = US.OL(items).filter('Parent__c', po.Id);


				po.LineItemCount__c = related_lineitems.size() + related_pre_existing_lineitems.size();
				po.CheckboxFieldCount__c = related_lineitems.filter('CheckboxField__c', true).size() + related_pre_existing_lineitems.filter('CheckboxField__c', true).size();
			}
			update parent_objs;
		}


## Reject

The opposite of filter; reject removes any records in an object list that match a criteria.


### Simple Use Case

		public static List<Account> findUnrelatedAccounts(List<Account> all_accounts, User salesperson) {
			return (List<Account>) US.OL(all_accounts).reject('OwnerId', salesperson.Id).toList();
		}

### Real-World Use Case

N/A


## Every

### Simple Use Case

N/A

### Real-World Use Case

N/A


## Some

### Simple Use Case

N/A

### Real-World Use Case

N/A


## Collect

Apply a function to a pre-existing List<SObject> and yields a completely different List.  This should not necessarily modify the original objects themselves.

A side note is that we use the term "Collect" instead of "Map" as Map is a keyword that already has a seperate meaning in Apex.	

### Simple Use Case

We do not have a sane default for the Collect object just yet.  The `Pluck()` behaves similarly to what I would imagine a basic use case would be (extract a single variable from an object list)

### Real-World Use Case

It's important to realize that Collect does not necessarily retain a link to the original object itself.  The case below generates a list of Integers, which are completely different from the original object.

	    public Class CalculateLineitemTotal extends US.CollectInterfaceAbstract{
	        public override Object collectfn(List<SObject> lst, SObject value, Integer index){
	            return (Integer) value.get('tax__c') + (Integer) value.get('price__c');
	        }
	    }


		public static List<Integer> calculateLineitemTotals(Account my_account, List<LineItem__c> items) {
			List<Integer> total_income = (List<Integer>) US.OL(items).filter("parent__c", my_account.id).collect(List<Integer>.class, new CalculateLineitemSum());
			return total_income;
		}


## Each

Mutate all SObjects within a list.

### Simple Use Case
Ensure that no one can send an email by accident by updating the emails for anyone who sets their "marketting email" setting to false.

	public static List<Account> resetClosedAccountEmails(List<Account> all_accounts) {
		return (List<Account>) US.OL(all_accounts).filter('wants_mail__c', false).each('marketting_email__c', 'do.not.send@example.org');
	}


### Real-World Use Case

N/A


## Reduce

*The Reduce function will probably undergo some changes so that it can perform relatively normal Reduce operations (such as defining a different return type and performing summations).  For the time being, you can find examples in the us_test.*


## Find

Returns the first item we find which matches the value we are looking for.

*The Find function will probably undergo some changes so it has "sane defaults" that don't require creating a new Object*

### Simple Use Case

		public static User findUserInCountry(String Country, List<User> users) {
			return US.OL(users).findwhere(new User(country='Canada'), new String[]{'Country'});
		}

### Real-World Use Case

N/A


## Find

Returns the first item we find which matches the value we are looking for.

*The Find function will probably undergo some changes so it has "sane defaults" that don't require creating a new Object*

### Simple Use Case

		public static User findUserInCountry(String Country, List<User> users) {
			return (User) US.OL(users).findwhere(new User(country='Canada'), new String[]{'Country'});
		}

### Real-World Use Case

N/A



## WhereHas

Returns the all items we find which matches the value we are looking for.

Using the name *WhereHas* instead of *Where* because *Where* is a reserved word in Apex.

*The WhereHas function will probably undergo some changes so it has "sane defaults" that don't require creating a new Object*

### Simple Use Case

		public static List<User> findUsersInCountry(String Country, List<User> users) {
			return (List<User>) US.OL(users).whereHas(new User(country='Canada'), new String[]{'Country'}).toList();
		}

### Real-World Use Case

N/A


## GroupBy

### Simple Use Case

N/A

### Real-World Use Case

N/A


## IndexBy

### Simple Use Case

N/A

### Real-World Use Case

N/A


## countBy

### Simple Use Case

N/A

### Real-World Use Case

N/A


# Background
As the former head of a large Salesforce.com organization, I find that the difficulties that people have with SFDC and its governor limits is related to the Apex language.  It is far too easy to load data in the middle of loops, and far harder to responsibly load data beforehand (to reduce the number of queries).

You could do so with boilerplate, but that means we end up with unreadable spaghetti code. 

Alternatively, adding multiple libraries to handle each possible type is a pain.

If we can abstract away the complexity, it may even be possible to make "beautiful code" with APEX and Salesforce.com.
