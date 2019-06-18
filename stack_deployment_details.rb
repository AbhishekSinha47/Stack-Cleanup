require 'aws-sdk'
require 'csv'
require 'date'

@client = Aws::OpsWorks::Client.new({ region: 'us-east-1', validate_params: false})
stack_details = @client.describe_stacks()

output_csv = CSV.open("added_deployment_details.csv", "wb")
output_csv << %w[S.No StackName Region Instances Owner Comments InstanceType Action Status LastDeploymentTime(Days)]
CSV.foreach('deleted_instances_result.csv', headers: true) do |row|
  row_hash = row.to_hash
  #last_deployed_date = ""
  days = " "
  stack_details.stacks.each do |stack_record|
    if row_hash["StackName"].eql?(stack_record.name) && !row_hash["Status"].gsub(/\s+/, "").eql?("Deleted")
      resp = @client.describe_deployments({
                                              stack_id: stack_record.stack_id
                                          })
      #fetching the last successfully user deployment date
      not_deployed = true
      resp.deployments.each do |deployment|
        if !deployment.iam_user_arn.nil? && deployment.status.eql?("successful")
          last_deployed_date = Date.parse deployment.completed_at
          #days
          #last_deployed_date = Date.parse last_deployed_date
          current_date = Time.now.strftime("%d/%m/%Y %H:%M")
          current_date = Date.parse current_date
          days = (current_date - last_deployed_date).to_i
          not_deployed = false
          puts "Stack deployment details:: stack name:#{stack_record.name}  deployment id:#{deployment.deployment_id}  last_user_ran_date:#{last_deployed_date}  and days_from_now: #{days}"
          break
        end
      end
      days = "Opsworks deployment" if not_deployed
    end
  end
  output_csv << [row_hash["S.No"], row_hash["StackName"], row_hash["Region"], row_hash["Instances"], row_hash["Owner"], row_hash["Comments"], row_hash["InstanceType"], row_hash["Action"],row_hash["Status"], days]
end
output_csv.close