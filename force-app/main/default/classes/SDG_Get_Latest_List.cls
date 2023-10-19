/**
 * @description       :
 * @author            : Stewart Anderson
 * @group             :
 * @last modified on  : 10-18-2023
 * @last modified by  : Stewart Anderson
**/
public with sharing class SDG_Get_Latest_List {

    public class sdgAppException extends Exception {}

    // INVOCABLE METHOD
    @InvocableMethod(label='Fetch Goals' description='Fetches SDG Goals from API')
    public static List<Boolean> invocableFetchGoals(List<Boolean> shouldExecute) {
        if (shouldExecute == null || shouldExecute.isEmpty() || !shouldExecute[0]) {
            return new List<Boolean> {false};
        }
        try {
            fetchGoals();
            return new List<Boolean> {true};
        } catch(Exception e) {
            System.debug('Error fetching goals: ' + e.getMessage());
            return new List<Boolean> {false};
        }
    }

    // FETCH GOALS
    public static void fetchGoals() {

        // FETCH GOALS
        String SDG_goals_endpoint = 'https://unstats.un.org/sdgapi/v1/sdg/Goal/List?includechildren=false';
        HttpRequest goals_request = new HttpRequest();
        goals_request.setEndpoint(SDG_goals_endpoint);
        goals_request.setMethod('GET');
        HttpResponse goals_response = new Http().send(goals_request);

        // PROCESS GOALS
        if (goals_response.getStatusCode() == 200) {

            List<Object> tempGoals = (List<Object>) JSON.deserializeUntyped(goals_response.getBody());
            List<Map<String, Object>> goals = new List<Map<String, Object>>();
            for (Object temp : tempGoals) {
                goals.add((Map<String, Object>) temp);
            }

            // UPSERT
            List<sdgsfdev__SDG_Goal__c> goalsToInsert = new List<sdgsfdev__SDG_Goal__c>();

            // Loop to populate the SDG_Goal__c objects
            for(Map<String, Object> goal : goals) {
                sdgsfdev__SDG_Goal__c newGoal = new sdgsfdev__SDG_Goal__c(
                    sdgsfdev__Code__c = (String) goal.get('code'),
                    sdgsfdev__Title__c = (String) goal.get('title'),
                    sdgsfdev__Description__c = (String) goal.get('description')
                );
                goalsToInsert.add(newGoal);
            }

            // Bulk insert goals
            upsert as user goalsToInsert sdgsfdev__Code__c;

            if (!Test.isRunningTest()){
                for(Integer i = 0; i < goals.size(); i++) {
                    System.enqueueJob(new AsyncFetchTargets(goalsToInsert[i].sdgsfdev__Code__c, goalsToInsert[i].Id));
                }
            } else {
                System.debug('Skipping additional call as test is running.');
            }

        } else {
            System.debug('FetchGoals API callout failed. Status code: ' + goals_response.getStatusCode());
            System.debug('Response: ' + goals_response.getBody());
            throw new sdgAppException('Request Failed');
        }
    }

    @future(callout=true)
    public static void fetchTargets(String goalCode, Id goalId) {

        // FETCH Targets
        System.debug('Loading Data from UN API');
        String SDG_targets_endpoint = 'https://unstats.un.org/sdgapi/v1/sdg/Goal/'+ goalCode +'/Target/List?includechildren=true';
        HttpRequest target_request = new HttpRequest();
        target_request.setEndpoint(SDG_targets_endpoint);
        target_request.setMethod('GET');
        HttpResponse target_response = new Http().send(target_request);

        // PROCESS TARGETS
        if (target_response.getStatusCode() == 200) {

            System.debug('Response OK');

            List<sdgsfdev__SDG_Goal_Target__c> targetsToInsert = new List<sdgsfdev__SDG_Goal_Target__c>();

            // Deserialize the JSON into a list of maps
            List<Object> tempGoals = (List<Object>) JSON.deserializeUntyped(target_response.getBody());
            List<Map<String, Object>> goals = new List<Map<String, Object>>();
            for (Object temp : tempGoals) {
                goals.add((Map<String, Object>) temp);
            }

            System.debug('Total Goals to Process: ' + goals.size());

            List<List<Map<String, Object>>> allIndicators = new List<List<Map<String, Object>>>();

            for(Map<String, Object> goal : goals) {
                // Access the 'targets' array within each 'goal' object
                List<Object> tempTargets = (List<Object>) goal.get('targets');
                List<Map<String, Object>> targets = new List<Map<String, Object>>();
                for (Object temp : tempTargets) {
                    targets.add((Map<String, Object>) temp);
                }

                System.debug('Total Targets to Process: ' + targets.size());

                // Loop through each target object
                for(Map<String, Object> target : targets) {
                    sdgsfdev__SDG_Goal_Target__c newTarget = new sdgsfdev__SDG_Goal_Target__c(
                        sdgsfdev__Goal__c = goalId,
                        sdgsfdev__Code__c = (String) target.get('code'),
                        sdgsfdev__Title__c = (String) target.get('title'),
                        sdgsfdev__Description__c = (String) target.get('description')
                    );
                    targetsToInsert.add(newTarget);

                    // Get indicators for this target
                    List<Object> tempIndicators = (List<Object>) target.get('indicators');
                    List<Map<String, Object>> indicators = new List<Map<String, Object>>();
                    for (Object temp : tempIndicators) {
                        indicators.add((Map<String, Object>) temp);
                    }
                    allIndicators.add(indicators);

                    System.debug('Total Indicators to Process: ' + allIndicators.size());
                }
            }

            System.debug('Upserting Targets');
            upsert as user targetsToInsert sdgsfdev__Code__c;

            Map<Id, List<sdgsfdev__SDG_Target_Indicator__c>> targetToIndicatorsMap = new Map<Id, List<sdgsfdev__SDG_Target_Indicator__c>>();

            // Loop through targets and populate targetToIndicatorsMap
            for(Integer i = 0; i < targetsToInsert.size(); i++) {
                Id targetId = targetsToInsert[i].Id;
                List<Map<String, Object>> indicatorsMapList = allIndicators[i];

                List<sdgsfdev__SDG_Target_Indicator__c> indicatorsList = new List<sdgsfdev__SDG_Target_Indicator__c>();
                for(Map<String, Object> indicatorMap : indicatorsMapList) {
                    sdgsfdev__SDG_Target_Indicator__c newIndicator = new sdgsfdev__SDG_Target_Indicator__c(
                        sdgsfdev__Goal_Target__c = targetId,
                        sdgsfdev__Code__c = (String) indicatorMap.get('code'),
                        sdgsfdev__Description__c = (String) indicatorMap.get('description'),
                        sdgsfdev__Tier__c = (String) indicatorMap.get('tier')
                    );
                    indicatorsList.add(newIndicator);
                }
                targetToIndicatorsMap.put(targetId, indicatorsList);
            }

            // Now pass the entire map to a Queueable or batch class for processing
            System.debug('Building Indicators Map for Batch Process');
            String serializedMap = JSON.serialize(targetToIndicatorsMap);
            System.enqueueJob(new AsyncBulkInsertIndicators(serializedMap));

        } else {
            System.debug('FetchTarget API callout failed. Status code: ' + target_response.getStatusCode());
            System.debug('Response: ' + target_response.getBody());
        }
    }

    public class AsyncFetchTargets implements Queueable {
        public String goalCode;
        public Id goalId;

        public AsyncFetchTargets(String goalCode, Id goalId) {
            this.goalCode = goalCode;
            this.goalId = goalId;
        }

        public void execute(QueueableContext context) {
            SDG_Get_Latest_List.fetchTargets(this.goalCode, this.goalId);
        }
    }

    public class AsyncBulkInsertIndicators implements Queueable {
        public String serializedMap;

        public AsyncBulkInsertIndicators(String serializedMap) {
            this.serializedMap = serializedMap;
        }

        public void execute(QueueableContext context) {
            Map<Id, List<sdgsfdev__SDG_Target_Indicator__c>> targetToIndicatorsMap =
                (Map<Id, List<sdgsfdev__SDG_Target_Indicator__c>>) JSON.deserialize(
                    this.serializedMap,
                    Map<Id, List<sdgsfdev__SDG_Target_Indicator__c>>.class
                );

            List<sdgsfdev__SDG_Target_Indicator__c> allIndicatorsToInsert = new List<sdgsfdev__SDG_Target_Indicator__c>();

            for (Id targetId : targetToIndicatorsMap.keySet()) {
                List<sdgsfdev__SDG_Target_Indicator__c> indicatorsForTarget = targetToIndicatorsMap.get(targetId);
                allIndicatorsToInsert.addAll(indicatorsForTarget);
            }

            System.debug('Upserting Indicators');
            upsert as user allIndicatorsToInsert sdgsfdev__Code__c;
        }
    }

}
