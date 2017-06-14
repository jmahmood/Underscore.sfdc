/*  All Examples come here. */
public class us_example {
    
    /*  Creates a Map of a employee's Reporting Line
     *  You must initialize the class by passing in a map with all users.
     *  How to test (Independently):
     *  Map<Id, User> all_users = new Map<Id, User>([Id, ManagerId, Manager.ManagerID, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId from User where Department = 'IS' or Department = '']);
     *  User jawaad = all_users.get('...');
     *  ReportingLineMapId = new ReportingLineMapId(all_users);
     *  system.debug(ReportingLineMapId.groupBy(new List<User>{jawaad}));
     *
     * Or with US it would be
     *  US all_users = new US([Id, ManagerId, Manager.ManagerID, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId from User where Department = 'IS' or Department = '']);
     *  Map<Id, List<User>> reporting_lines = = all_users.filter('Alias', 'jawaad').groupby(new ReportingLineMapId(all_users));
     * 
     */
     class ReportingLineMapId implements US.GroupByInterface {
        public Map<Id, User> AllUsers;
        
        public ReportingLineMapId(Map<Id, User> all_users){
            AllUsers = all_users; // This is a map of all users who exist.
        }
    
        public Map<String, List<Object>> groupBy(List<Object> objs){ // objs = requesting users.
            Map<String, List<User>> ret = new Map<String, List<User>>();
    
            for (Object u: objs){
                List<User> ReportingLine = new List<User>();
                User y = (User) u;
                while (y.ManagerId != null && AllUsers.get(y.ManagerId) != null){
                    ReportingLine.add(AllUsers.get(y.ManagerId));
                    y = AllUsers.get(y.ManagerId);
                }
                ret.put(((User) u).Id, ReportingLine);
            }
            return ret;
        }
    }


    public static void how_to_user(){
        Map<Id, User> all_users = new Map<Id, User>([Select Id, name, COA_Acronym__c, COA_Group__c, ManagerId, Manager.ManagerID, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId 
        from User where isActive=true]);
        US all_users_us = new us(all_users.values());
        Map<String, List<User>> ReportingLines = (Map<String, List<User>>) all_users_us.filter('alias', 'jawaad').groupBy(ReportingLineMapId(Map<String, List<User>>.class, all_users));
        List<User> jawaad_reporting_line = ReportingLines.get(jawaad.id));
    } 
    

}
