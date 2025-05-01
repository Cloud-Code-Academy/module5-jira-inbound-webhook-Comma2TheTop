/**
 * @description Processor for Jira webhooks
 * Handles issue and project events from Jira
 * 
 * STUDENT TASK:
 * Implement the IWebhookProcessor interface to handle Jira webhook events
 * You'll need to process various events like issue/project creation, updates, and deletions
 * 
 * IMPORTANT NOTE: without sharing is used to avoid sharing issues with the Jira_Issue__c and Jira_Project__c objects but it is not a good practice
 * 
 * @author Student Name
 */
public without sharing class JiraWebhookProcessor implements IWebhookProcessor {

    //private static final Nebula.Logger logger = Nebula.Logger.getLogger(JiraWebhookProcessor.class);
    
    // Constants for webhook event types
    private static final String EVENT_ISSUE_CREATED = 'jira:issue_created';
    private static final String EVENT_ISSUE_UPDATED = 'jira:issue_updated';
    private static final String EVENT_ISSUE_DELETED = 'jira:issue_deleted';
    private static final String EVENT_PROJECT_CREATED = 'project_created';
    private static final String EVENT_PROJECT_UPDATED = 'project_updated';
    private static final String EVENT_PROJECT_DELETED = 'project_deleted';
    
    /**
     * @description Validates the incoming Jira webhook request
     * @param request The REST request containing the webhook payload
     * @return Boolean True if the request is valid, false otherwise
     * 
     * STUDENT TASK:
     * Implement validation logic for Jira webhooks
     * - Check for valid JSON by deserializing the request body
     * - Verify the 'webhookEvent' field exists in the payload
     * - You can add further validation like checking for specific headers
     * - Return true if valid, false otherwise
     * 
     * HINT:
     * 1. Use try-catch to handle JSON deserialization errors
     * 2. Cast the deserialized JSON to Map<String, Object>
     * 3. Check if required keys exist using containsKey()
     * 4. Example: if (!payload.containsKey('webhookEvent')) { return false; }
     */
    public Boolean validate(RestRequest request) {
        try {
            // TODO: Implement validation logic
            // Example:
            String requestBody = request.requestBody.toString();
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            if (!payload.containsKey('webhookEvent')) {
                return false;
            }
            System.debug('Webhook validation passed, event: ' + payload.get('webhookEvent'));
            return true;
            
             // Replace with your implementation
        } catch (Exception e) {
            // Log the error and return false
            System.debug('Error validating webhook: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Processes the Jira webhook request
     * @param request The REST request containing the webhook payload
     * 
     * STUDENT TASK:
     * Implement the main processing logic
     * - Parse the JSON payload from the request body
     * - Extract the 'webhookEvent' field to determine the event type
     * - Call the appropriate handler method based on the event type
     * 
     * HINT:
     * 1. Use JSON.deserializeUntyped() to convert the request body to a Map
     * 2. Extract the event type: String webhookEvent = (String) payload.get('webhookEvent');
     * 3. Use if/else or switch statements to call the appropriate handler
     * 4. Example: if (webhookEvent == EVENT_ISSUE_CREATED) { processIssueCreated(payload); }
     */
    public void process(RestRequest request) {
        try {
            // TODO: Implement webhook processing logic
            // Example:
            String requestBody = request.requestBody.toString();
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            String webhookEvent = (String) payload.get('webhookEvent');
            
            if (webhookEvent == EVENT_PROJECT_CREATED) {
                processProjectCreated(payload);
            } else if (webhookEvent == EVENT_PROJECT_UPDATED) {
                processProjectUpdated(payload);
            } else if (webhookEvent == EVENT_PROJECT_DELETED) {
                processProjectDeleted(payload);
            } else if (webhookEvent == EVENT_ISSUE_CREATED) {
                processIssueCreated(payload);
            } else if (webhookEvent == EVENT_ISSUE_UPDATED) {
                processIssueUpdated(payload);
            } else if (webhookEvent == EVENT_ISSUE_DELETED) {
                processIssueDeleted(payload);
            }
            // } // ... and so on for other event types
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing webhook: ' + e.getMessage());
            throw e; // Re-throw to let the caller handle it
        }
    }
    
    /**
     * @description Process an issue_created event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Use this example as a template for other event handlers
     */
    private void processIssueCreated(Map<String, Object> payload) {
        try {
            // Example implementation:
            
            // 1. Extract issue data from the payload
            Map<String, Object> issueData = (Map<String, Object>) payload.get('issue');
            
            // 2. Create a new Jira_Issue__c record using the helper method
            Jira_Issue__c newIssue = createIssueRecord(issueData);
            
            // 3. Insert the new record
            insert newIssue;
            
            // 4. Log success
            System.debug('Created Jira issue record: ' + newIssue.Id);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing issue_created event: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Process an issue_updated event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to update an existing Jira_Issue__c record
     * If the record doesn't exist, create it
     */
    private void processIssueUpdated(Map<String, Object> payload) {
        // TODO: Implement issue update logic
        try{
            Map<String, Object> issueData = (Map<String, Object>) payload.get('issue');
            String issueKey = (String) issueData.get('key');

            Jira_Issue__c  existingIssue = [
                SELECT Id, Summary__c, Description__c, Issue_Type__c, Status__c, Issue_Key__c, Last_Updated__c
                FROM Jira_Issue__c
                WHERE Issue_Key__c = :issueKey
                LIMIT 1
            ];
            
            Jira_Issue__c issueToUpdate = updateIssueRecord(existingIssue, issueData);
    
            update issueToUpdate;
            
            
            System.debug('Created Jira project record: ' + issueToUpdate.Id);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing issue_updated event: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Process an issue_deleted event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to delete a Jira_Issue__c record
     */
    private void processIssueDeleted(Map<String, Object> payload) {
        // TODO: Implement issue deletion logic
        try{
            Map<String, Object> issueData = (Map<String,Object>) payload.get('issue');
            String issueKey = (String) issueData.get('key');

            Jira_Issue__c  existingIssue = [
                SELECT Id, Summary__c, Description__c, Issue_Type__c, Status__c, Issue_Key__c, Last_Updated__c
                FROM Jira_Issue__c
                WHERE Issue_Key__c = :issueKey
                LIMIT 1
            ];
            Jira_Issue__c issueToDelete = deleteIssueRecord(existingIssue);
            //delete issueToDelete;
            System.debug('Deleted Jira issue record: ' + issueToDelete.Id);
            } catch (Exception e){
                System.debug(LoggingLevel.ERROR, 'Error processing issue_deleted event: ' + e.getMessage());
                throw e;
            
            }
        }
    
    
    /**
     * @description Process a project_created event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to create a Jira_Project__c record
     */
    private void processProjectCreated(Map<String, Object> payload) {
        // TODO: Implement project creation logic
        try{
                    Map<String, Object> projectData = (Map<String, Object>) payload.get('project');
                    
                    Jira_Project__c newProject = createProjectRecord(projectData);
            
                    insert newProject;
                    
                    
                    System.debug('Created Jira project record: ' + newProject.Id);
                    
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error processing project_created event: ' + e.getMessage());
                    throw e;
                }
    }
    
    /**
     * @description Process a project_updated event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to update an existing Jira_Project__c record
     * If the record doesn't exist, create it
     */
    private void processProjectUpdated(Map<String, Object> payload) {
        // TODO: Implement project update logic
        try{
            Map<String, Object> projectData = (Map<String, Object>) payload.get('project');
            // String issueKey = (String) issueData.get('key');
            String projectKey = (String) projectData.get('key');

            Jira_Project__c existingProject = [
                SELECT Id, Project_Key__c, Name
                FROM Jira_Project__c
                WHERE Project_Key__c = :projectKey
                LIMIT 1
            ];
            
                       
            Jira_Project__c projectToUpdate = updateProjectRecord(existingProject, projectData);
    
            update projectToUpdate;
            
            
            System.debug('Created Jira project record: ' + projectToUpdate.Id);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing project_updated event: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Process a project_deleted event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to delete a Jira_Project__c record
     */
    private void processProjectDeleted(Map<String, Object> payload) {
        // TODO: Implement project deletion logic
        try{
            Map<String, Object> projectData = (Map<String,Object>) payload.get('project');
            String projectKey = (String) projectData.get('key');
            Jira_Project__c projectToDelete = [SELECT Id FROM Jira_Project__c WHERE Project_Key__c =  :projectKey];
            if(projectToDelete != null) {
            deleteProjectRecord(projectToDelete);
            
            System.debug('Successfully processed project deletion for project ID: ' + projectToDelete.Id);
        } else {
            System.debug('Project with key ' + projectKey + ' not found, no deletion performed.');
        }
        } catch (Exception e) {
        System.debug('Error processing project_deleted event: ' + e.getMessage());
        throw e; // Re-throw the exception if you want higher layers to handle it
        }
    }
    
    /**
     * @description Create a Jira_Issue__c record from issue data
     * @param issueData The issue data from the webhook
     * @return Jira_Issue__c The newly created issue record
     * 
     * STUDENT TASK:
     * Implement logic to extract issue fields and create a record
     * 
     * HINT:
     * 1. Extract data from the issueData map (key, summary, status, etc.)
     * 2. Map the fields to a new Jira_Issue__c record
     */
    private Jira_Issue__c createIssueRecord(Map<String, Object> issueData) {
        // TODO: Implement issue record creation logic
        // Example (incomplete - add other fields as needed):
        String issueKey = (String) issueData.get('key');
        Map<String, Object> fields = (Map<String, Object>) issueData.get('fields');
        Map<String, Object> issueTypeMap = (Map<String, Object>) fields.get('issuetype');
        Map<String, Object> statusMap = (Map<String, Object>) fields.get('status');
        Map<String, Object> projectMap = (Map<String, Object>) fields.get('project');
        String summary = (String) fields.get('summary');
        String description = (String) fields.get('description');
        String issueType = (String) issueTypeMap.get('name');
        String status = (String) statusMap.get('name');
        String projectKey = (String) projectMap.get('key');
    
    //     String requestBody = '{' +
    //     '"webhookEvent": "jira:issue_created",' +
    //     '"issue": {' +
    //         '"key": "TEST-123",' +
    //         '"fields": {' +
    //             '"summary": "Test issue",' +
    //             '"description": "This is a test issue",' +
    //             '"issuetype": {' +
    //                 '"name": "Bug"' +
    //             '},' +
    //             '"status": {' +
    //                 '"name": "Open"' +
    //             '},' +
    //             '"project": {' +
    //                 '"key": "TEST"' +
    //             '}' +
    //         '}' +
    //     '}' +
    // '}';
                
        Jira_Issue__c issue = new Jira_Issue__c(
            Issue_Key__c = issueKey,
            Summary__c = summary,
            Description__c = description,
            Issue_Type__c = issueType,
            Status__c = status,
            Project_Key__c = projectKey

            // Add other fields as needed
        );
        
        return issue;
        
        //return new Jira_Issue__c();
    }
    
    /**
     * @description Update a Jira_Issue__c record from issue data
     * @param existingIssue The existing issue record
     * @param issueData The updated issue data from the webhook
     * @return Jira_Issue__c The updated issue record
     * 
     * STUDENT TASK:
     * Implement logic to extract issue fields and update a record
     */
    private Jira_Issue__c updateIssueRecord(Jira_Issue__c existingIssue, Map<String, Object> issueData) {
        // TODO: Implement issue record update logic
        Map<String, Object> fields = (Map<String, Object>) issueData.get('fields');
        Map<String, Object> issueTypeMap = (Map<String, Object>) fields.get('issuetype');
        Map<String, Object> statusMap = (Map<String, Object>) fields.get('status');
        Map<String, Object> projectMap = (Map<String, Object>) fields.get('project');
        String issueKey = (String) issueData.get('key');
        String summary = (String) fields.get('summary');
        String description = (String) fields.get('description');
        String issueType = (String) issueTypeMap.get('name');
        String status = (String) statusMap.get('name');
        String projectKey = (String) projectMap.get('key');

        existingIssue.Summary__c = summary;
        existingIssue.Description__c = description;
        existingIssue.Issue_Type__c = issueType;
        existingIssue.Status__c = status;
        existingIssue.Issue_Key__c = issueKey;
        existingIssue.Project_Key__c = projectKey;
        existingIssue.Last_Updated__c = DateTime.now();

        // String issueKey = (String) issueData.get('key');
        // Map<String, Object> fields = (Map<String, Object>) issueData.get('fields');
        // Map<String, Object> issueTypeMap = (Map<String, Object>) fields.get('issuetype');
        // Map<String, Object> statusMap = (Map<String, Object>) fields.get('status');
        // Map<String, Object> projectMap = (Map<String, Object>) fields.get('project');
        // String summary = (String) fields.get('summary');
        // String description = (String) fields.get('description');
        // String issueType = (String) issueTypeMap.get('name');
        // String status = (String) statusMap.get('name');
        // String projectKey = (String) projectMap.get('key');

        return existingIssue;
    }
    private Jira_Issue__c deleteIssueRecord(Jira_Issue__c issueToDelete) {
        // TODO: Implement project record update logic
        if (issueToDelete == null) {
            return issueToDelete; // Nothing to update
        }
        
        try{
            delete issueToDelete;
        } catch (DmlException e) {
            System.debug('Error deleting issue record:' + e.getMessage());
        }
        return issueToDelete;
    }
    
    /**
     * @description Create a Jira_Project__c record from project data
     * @param projectData The project data from the webhook
     * @return Jira_Project__c The newly created project record
     * 
     * STUDENT TASK:
     * Implement logic to extract project fields and create a record
     */
    private Jira_Project__c createProjectRecord(Map<String, Object> projectData) {
        // TODO: Implement project record creation logic

        String projectKey = (String) projectData.get('key');
        String projectName = (String) projectData.get('name');
        String projectId = (String) projectData.get('id');
        String description = (String) projectData.get('description');

        Jira_Project__c newProject = new Jira_Project__c (
            Project_Name__c = projectName,
            Project_Key__c = projectKey,
            Project_ID__c = projectId,
            Description__c = description
        );

        return newProject;
    }
    
    /**
     * @description Update a Jira_Project__c record from project data
     * @param existingProject The existing project record
     * @param projectData The updated project data from the webhook
     * @return Jira_Project__c The updated project record
     * 
     * STUDENT TASK:
     * Implement logic to extract project fields and update a record
     */
    private Jira_Project__c updateProjectRecord(Jira_Project__c existingProject, Map<String, Object> projectData) {
        // TODO: Implement project record update logic
        if (existingProject == null || projectData == null) {
            return existingProject; // Nothing to update
        }
        
        String projectKey = (String) projectData.get('key');
        String projectName = (String) projectData.get('name');


        existingProject.Project_Key__c = projectKey;
        existingProject.Project_Name__c = projectName;

        return existingProject;
    }

    private Jira_Project__c deleteProjectRecord(Jira_Project__c projectToDelete) {
        // TODO: Implement project record update logic
        if (projectToDelete == null) {
            return projectToDelete; // Nothing to update
        }
        
        try{
            delete projectToDelete;
        } catch (DmlException e) {
            System.debug('Error deleting project record:' + e.getMessage());
        }
        return projectToDelete;
    }
} 