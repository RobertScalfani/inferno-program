# frozen_string_literal: true

# NOTE: This is a generated file. Any changes made to this file will be
#       overwritten when it is regenerated

require_relative '../../../../test/test_helper'

describe Inferno::Sequence::USCore310PractitionerSequence do
  before do
    @sequence_class = Inferno::Sequence::USCore310PractitionerSequence
    @base_url = 'http://www.example.com/fhir'
    @client = FHIR::Client.new(@base_url)
    @token = 'ABC'
    @instance = Inferno::Models::TestingInstance.create(token: @token, selected_module: 'uscore_v3.1.0')
    @patient_id = '123'
    @instance.patient_id = @patient_id
    set_resource_support(@instance, 'Practitioner')
    @auth_header = { 'Authorization' => "Bearer #{@token}" }
  end

  describe 'Practitioner read test' do
    before do
      @practitioner_id = '456'
      @test = @sequence_class[:resource_read]
      @sequence = @sequence_class.new(@instance, @client)
    end

    it 'skips if the Practitioner read interaction is not supported' do
      @instance.server_capabilities.destroy
      @instance.reload
      exception = assert_raises(Inferno::SkipException) { @sequence.run_test(@test) }

      skip_message = 'This server does not support Practitioner read operation(s) according to conformance statement.'
      assert_equal skip_message, exception.message
    end

    it 'skips if no Practitioner has been found' do
      exception = assert_raises(Inferno::SkipException) { @sequence.run_test(@test) }

      assert_equal 'No Practitioner references found from the prior searches', exception.message
    end

    it 'fails if a non-success response code is received' do
      Inferno::Models::ResourceReference.create(
        resource_type: 'Practitioner',
        resource_id: @practitioner_id,
        testing_instance: @instance
      )

      stub_request(:get, "#{@base_url}/Practitioner/#{@practitioner_id}")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 401)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Bad response code: expected 200, 201, but found 401. ', exception.message
    end

    it 'fails if no resource is received' do
      Inferno::Models::ResourceReference.create(
        resource_type: 'Practitioner',
        resource_id: @practitioner_id,
        testing_instance: @instance
      )

      stub_request(:get, "#{@base_url}/Practitioner/#{@practitioner_id}")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Expected Practitioner resource to be present.', exception.message
    end

    it 'fails if the resource returned is not a Practitioner' do
      Inferno::Models::ResourceReference.create(
        resource_type: 'Practitioner',
        resource_id: @practitioner_id,
        testing_instance: @instance
      )

      stub_request(:get, "#{@base_url}/Practitioner/#{@practitioner_id}")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: FHIR::Patient.new.to_json)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Expected resource to be of type Practitioner.', exception.message
    end

    it 'succeeds when a Practitioner resource is read successfully' do
      practitioner = FHIR::Practitioner.new(
        id: @practitioner_id
      )
      Inferno::Models::ResourceReference.create(
        resource_type: 'Practitioner',
        resource_id: @practitioner_id,
        testing_instance: @instance
      )

      stub_request(:get, "#{@base_url}/Practitioner/#{@practitioner_id}")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: practitioner.to_json)

      @sequence.run_test(@test)
    end
  end

  describe 'unauthorized search test' do
    before do
      @test = @sequence_class[:unauthorized_search]
      @sequence = @sequence_class.new(@instance, @client)

      @practitioner_ary = FHIR.from_contents(load_fixture(:us_core_practitioner))
      @sequence.instance_variable_set(:'@practitioner_ary', @practitioner_ary)

      @query = {
        'name': @sequence.get_value_for_search_param(@sequence.resolve_element_from_path(@practitioner_ary, 'name'))
      }
    end

    it 'skips if the Practitioner search interaction is not supported' do
      @instance.server_capabilities.destroy
      @instance.reload
      exception = assert_raises(Inferno::SkipException) { @sequence.run_test(@test) }

      skip_message = 'This server does not support Practitioner search operation(s) according to conformance statement.'
      assert_equal skip_message, exception.message
    end

    it 'fails when the token refresh response has a success status' do
      stub_request(:get, "#{@base_url}/Practitioner")
        .with(query: @query)
        .to_return(status: 200)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Bad response code: expected 401, but found 200', exception.message
    end

    it 'succeeds when the token refresh response has an error status' do
      stub_request(:get, "#{@base_url}/Practitioner")
        .with(query: @query)
        .to_return(status: 401)

      @sequence.run_test(@test)
    end

    it 'is omitted when no token is set' do
      @instance.token = ''

      exception = assert_raises(Inferno::OmitException) { @sequence.run_test(@test) }

      assert_equal 'Do not test if no bearer token set', exception.message
    end
  end
end
