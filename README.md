# Underscore.sfdc
This is an experiment to see how much of the underscore.js api one could implement using the APEX language on Salesforce.com.  

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

## Filter

This is particularly useful for functions that run on triggers; load all your data at once and do filters as necessary.  No more "100 SOQL query" errors.

		public static void refreshParent(List<LineItem__c> items) {
			US triggered_lineitems = new US(items);

			List<String> parent_ids = (List<String>) triggered_lineitems.pluck('Parent__c');
			List<ParentObj__c> parent_objs = [SELECT id, NoLineItems__c, LineItemsThatAreChecked__c FROM ParentObj__c WHERE id =: parent_ids];
			US all_related_lineitems = new US([SELECT id, Parent__c, CheckboxField__c FROM LineItem__c WHERE Parent__c =: parent_ids]);

			for (ParentObj__c po: parent_objs){
				po.LineItems__c = all_related_lineitems.rewind().filter(new US.FilterFieldIds('Parent__c', po.Id)).size();
				po.CheckboxField__c = all_related_lineitems.filter(new FilterTrueCheckboxFieldOnly()).size();
			}
			update parent_objs;
		}


		public class FilterTrueCheckboxFieldOnly extends US.FilterInterfaceAbstract{
		    public override boolean filterfn(List<SObject> memo, SObject value){
		        return ((LineItem__c) value).CheckboxField__c;
		    }
		} 


The above function is based on an actual situation where we could not count on the Master / Detail field's aggregate field to be available when needed.  The vendor's original item has multiple for loops and multiple SOQL queries involved; 


# Background
As the head of a large Salesforce.com organization, I find that the difficulties that people have with SFDC and its governor limits is related to the Apex language.  It is far too easy to load data in the middle of loops, and far harder to responsibly load data beforehand (to reduce the number of queries).

You could do so with boilerplate, but that means we end up with unreadable spaghetti code. 

If we can abstract away the complexity, it may even be possible to make "beautiful code" with APEX and Salesforce.com.