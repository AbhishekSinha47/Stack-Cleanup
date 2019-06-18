require 'aws-sdk'
require 'csv'

@client = Aws::OpsWorks::Client.new({ region: 'us-east-1', validate_params: false})
stack_details = @client.describe_stacks()

output_csv = CSV.open("stack_deleted_result.csv", "wb")
output_csv << %w[S.No StackName Region Instances Owner Comments InstanceType Action Status LastDeploymentTime(Days) StackStatus]
CSV.foreach('added_deployment_details.csv', headers: true) do |row|
  row_hash = row.to_hash
  stack_status = " "
  status = ""
  stack_details.stacks.each do |stack_record|
    if row_hash["StackName"].eql?(stack_record.name) && row_hash["Comments"].eql?("Can be deleted")
      flag = 0
      stack_layers = @client.describe_layers({stack_id: stack_record.stack_id})
      stack_layers.layers.each do |layer_obj|
        instance_response = @client.describe_instances({:layer_id => layer_obj.layer_id})
        if instance_response.instances.count > 0
          instance_response.instances.each do |instance|
            if instance.status.eql?("online")
              stop_resp = @client.stop_instance({
                                                    instance_id: instance.instance_id,
                                                    force: true,
                                                })
              puts "Stopping instance details:: stack name is :#{stack_record.name}  InstanceID is :: #{instance.instance_id} current instance_status:: #{instance.status}"
              sleep(50)
            end

          end
        end
#delete the stopped instances
        inst_response = @client.describe_instances({:layer_id => layer_obj.layer_id})
        if inst_response.instances.count > 0
          inst_response.instances.each do |inst|
            if inst.status.eql?("stopped") || inst.status.eql?("start_failed")
              flag = 1
              delete_resp = @client.delete_instance({
                                                        instance_id: inst.instance_id,
                                                        delete_volumes: true,
                                                    })
              puts "deleted instance details:: stack name is :#{stack_record.name}  InstanceID is :: #{inst.instance_id} current instance_status:: #{inst.status}"
            end
          end
        end


        layer_del = @client.delete_layer({ layer_id: layer_obj.layer_id }) if instance_response.instances.count.zero?  #delete layer
      end
      if stack_layers.layers.count.zero?
        puts "deleting stack details : #{stack_record.name}"
        #delete the apps if existing
        app_values = @client.describe_apps({
                                               stack_id: stack_record.stack_id,
                                           })
        app_values.apps.each do |app|
          app_del = @client.delete_app({
                                           app_id: app.app_id, # required
                                       })
        end

        #delete instances, if any - existing even without layers
        instances_values = @client.describe_instances({
                                                          stack_id: stack_record.stack_id,
                                                      })
        instances_values.instances.each do |instan|
          if instan.status.eql?("stopped")
            delete_resp = @client.delete_instance({
                                                      instance_id: instan.instance_id,
                                                      delete_volumes: true,
                                                  })
          end
        end
        stack_del = @client.delete_stack({ stack_id: stack_record.stack_id })
        stack_status =  "Stack Deleted"
      end
      status = (flag == 1)? "Deleted" : " "
    end
  end
  output_csv << [row_hash["S.No"], row_hash["Stack_name"], row_hash["Region"], row_hash["Instances"], row_hash["Owner"], row_hash["Comments"], row_hash["InstanceType"], row_hash["Action"], status, row_hash["LastDeploymentTime(Days)"], stack_status ]
end
output_csv.close