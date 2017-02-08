# Underscore.sfdc
An experiment to see how much of underscore.js one could apply to Salesforce Apex.

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
As the head of a large organization, I also find that the difficulties that people have with SFDC and its governor limits is related to how easy Apex makes it to load data in the middle of loops, and how much boilerplate you need to work around this. (ex: Find all items in a list with a particular ID and to match it to another object, for example).

Some of this is bad design (vendors who don't really know Salesforce) and some of it is the language.  I get it; it is much easier to stick a query in a For loop.  But what if you could abstract away all of the list handling, and expose only the logic which drives the system?

Recently, we have changed how we make SFDC Apex code; we now use a Javascript Promises-inspired style, with chained callbacks and "short circuits" to handle errors.   I find that this has drastically reduced the number of SOQL queries made, and errors in logic too.  Instead of staring at irrelevant boilerplate, I can pay attention to the logic that is going on behind the scenes.

This library is intended to further that process, by bringing more dynamic methods of data handling to Apex.

While Salesforce.com does not allow us to pass functions, or dynamically call functions, I believe one can use classes and interfaces as an approximation.  My hope is that by implementing the functions from underscore.sfdc, my team will be freed to concentrate more on higher orders of logic, while the heavy lifting happens through the use of these functions.
