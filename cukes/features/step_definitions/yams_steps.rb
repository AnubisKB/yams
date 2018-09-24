Given("a message exists that is going to be deleted") do
  postgres_client.create('kburns', ['tearle','kstalzer','larry'], 'DELETE ME', 'This is a test message and should (have) be(en) deleted by the cukes!')
end


When("a request is issued to the YAMS service to create a new message with:") do |yams_data_table|
  message_data = yams_data_table.symbolic_hashes.first
  
  payload = {
	  from: message_data[:from_address],
    to: message_data[:to_addresses].split(','), 
    subject: message_data[:message_subject],
    body: message_data[:message_body]
  }

  yams_api_client.create(payload)
end

When("a request is issued to the YAMS service to get all messages") do
  yams_api_client.index
end

When("a request is issued to the YAMS service to get a specific message with Message Id {string}") do |message_id|
  yams_api_client.get(message_id)
end

When("a request is issused to the YAMS service to delete that message") do
  yams_api_client.delete(postgres_client.new_message_id)
end

When("a request is issued to the YAMS service to delete a specific message with Message Id {string}") do |message_id|
  yams_api_client.delete(message_id)
end


Then("the message is created in the database") do
  message_id = JSON.parse(yams_api_client.response_body)['message_id']
  postgres_client.get(message_id)
  expect(postgres_client.results).to_not be_nil
  postgres_client.delete(message_id)
end

Then("the message identifier is returned") do
  message_id = JSON.parse(yams_api_client.response_body)['message_id']
  expect(message_id > 0).to eql(true)
end

Then("there is no message in the database with Message Body {string}") do |body|
  expect(postgres_client.message_in_database?(body)).to eql(false)
end

Then("the response status code is {int}") do |response_code|
  expect(yams_api_client.response_code).to eql(response_code)
end

Then("all the messages are returned:") do |messages_table|
    expected_messages = messages_table.symbolic_hashes
    actual_messages = JSON.parse(yams_api_client.response_body).map do |msg|
        {
            :from_address => msg['from_address'],
            :to_addresses => msg['to_addresses'].join(','),
            :message_subject => msg['message_subject'],
            :message_body => msg['message_body']
        }
    end
    
    all_messages_found = actual_messages.all? { |msg| expected_messages.include?(msg) }

    expect(all_messages_found).to eql(true)
end

Then("the following message is returned:") do |message_table|
  expected_message = message_table.symbolic_hashes.first
  returned_message = JSON.parse(yams_api_client.response_body)
  actual_message = {
    :from_address => returned_message['from_address'],
    :to_addresses => returned_message['to_addresses'].join(','),
    :message_subject => returned_message['message_subject'],
    :message_body => returned_message['message_body']
  }

  expect(actual_message).to eql(expected_message)
end

Then("the message cannot be found in the database") do
  expect(postgres_client.message_in_database?('This is a test message and should (have) be(en) deleted by the cukes!')).to eql(false)
end

Then("the response Message Body contains an error message") do
    res = JSON.parse(yams_api_client.response_body)
    expect(res.keys).to include('error')
end


private

    def yams_api_client
        @yams_api_client ||= YamsApiClient.new
    end

    def postgres_client
        @postgres_client ||= PostgresClient.new
    end
