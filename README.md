# Automated scripts for Stacks Cleanup.

Below are the automated scripts to perform stack cleanup and corresponding status update:

1. instances_cleanup.rb : Script for Deleting and logging status for all the instances from stacks which had all stopped instances alone.<br/>
                           Input : Google Sheet downloaded as a CSV file. 
                           Output: 'deleted_instances_result.csv' file.
                           
2. stack_deployment_details.rb : Updating the stack's Last deployment date interval in days(By user and not Opsworks) for further action on online instances.<br/>
                                  Input : 'deleted_instances_result.csv' file i.e. output of first script.  
                                  Output: 'added_deployment_details.csv' file.
                                 
3. stop_instances_delete_stack.rb : For given stacks, stopping the online instances(if any), deleting them followed by layers and respective stack deletion with proper edge cases handling.<br/>
                                     Input : 'added_deployment_details.csv' file i.e. output of second script.  
                                     Output: 'stack_deleted_result_final.csv' file.
   

Note:
1. All the automated scripts are written assuming a csv file as input containing the stack details(mainly, stack name is required)
2. Have generated the above mentioned CSV file from the google sheet provided with stack details. 
3. Finally, each script generates a CSV file with action/status performed as a new column.
4. Just import the generated the CSV file in a new google spreadsheet and thus the sheet is ready with required activity logged.

