require 'aws-sdk'
require 'csv'

@client = Aws::OpsWorks::Client.new({ region: 'us-east-1', validate_params: false})
stack_details = @client.describe_stacks()

output_csv = CSV.open("deleted_instances_result.csv", "wb")
output_csv << %w[S.No Stack_name Region Instances Owner Comments InstanceType Action Status]
CSV.foreach('stacks.csv', headers: true) do |row|
  row_hash = row.to_hash
  status = ""
  stack_details.stacks.each do |stack_record|
    if row_hash["Stack_name"].eql?(stack_record.name) && row_hash["Action"].gsub(/\s+/, "").eql?("DeleteorMove")
      flag = 0
      sleep(3)
      resp = @client.describe_stack_summary({
                                                stack_id: stack_record.stack_id
                                            })

      if resp.stack_summary.instances_count.online.nil? #if no online instances then remove all stopped instances

        stack_layers = @client.describe_layers({stack_id: stack_record.stack_id})
        stack_layers.layers.each do |layer_obj|
          instance_response = @client.describe_instances({:layer_id => layer_obj.layer_id})
          if instance_response.instances.count > 0
            instance_response.instances.each do |instance|
              puts "Deleted instance details:: stack name is :#{stack_record.name}  InstanceID is :: #{instance.instance_id} instance_status:: #{instance.status}"
              if instance.status.eql?("stopped")
                flag = 1
                ins_resp = @client.delete_instance({
                                                       instance_id: instance.instance_id,
                                                       delete_volumes: true,
                                                   })
                #puts "Response for deleting Instance with ID #{instance.instance_id} is :: #{ins_resp}"
              end
            end
          end
        end
      end
      status = (flag == 1)? "Deleted" : " "
    end
  end
  output_csv << [row_hash["S.No"], row_hash["Stack_name"], row_hash["Region"], row_hash["Instances"], row_hash["Owner"], row_hash["Comments"], row_hash["InstanceType"], row_hash["Action"], status ]
end
output_csv.close