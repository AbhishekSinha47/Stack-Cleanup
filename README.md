# Automated scripts for Stacks Cleanup.

Below are the automated scripts to perform stack cleanup and corresponding status update:

1. instances_cleanup.rb : Script for Deleting and logging status for all the instances from stacks which had all stopped instances alone.

2. stack_deployment_details.rb : Updating the stack's Last deployment date interval in days(By user and not Opsworks) for further action on online instances.

3. stop_instances_delete_stack.rb : For given stacks, stopping the online instances(if any), deleting them followed by layers and respective stack deletion with proper edge cases handling.


Note:
1. All the automated scripts are written assuming a csv file as input containing the stack details(mainly, stack name is required)
2. Have generated the above mentioned csv file from the google sheet provided with stack details. 
