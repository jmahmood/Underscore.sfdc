# Underscore.sfdc
An experiment to see how much of underscore.js one could apply to Salesforce Apex.

# Background
As the head of a large organization, I also find that the difficulties that people have with SFDC and its governor limits is related to how easy Apex makes it to load data in the middle of loops, and how much boilerplate you need to work around this. (ex: Find all items in a list with a particular ID and to match it to another object, for example).

Some of this is bad design (vendors who don't really know Salesforce) and some of it is the language.  I get it; it is much easier to stick a query in a For loop.  But what if you could abstract away all of the list handling, and expose only the logic which drives the system?

Recently, we have changed how we make SFDC Apex code; we now use a Javascript Promises-inspired style, with chained callbacks and "short circuits" to handle errors.   I find that this has drastically reduced the number of SOQL queries made, and errors in logic too.  Instead of staring at irrelevant boilerplate, I can pay attention to the logic that is going on behind the scenes.

This library is intended to further that process, by bringing more dynamic methods of data handling to Apex.

While Salesforce.com does not allow us to pass functions, or dynamically call functions, I believe one can use classes and interfaces as an approximation.  My hope is that by implementing the functions from underscore.sfdc, my team will be freed to concentrate more on higher orders of logic, while the heavy lifting happens through the use of these functions.
