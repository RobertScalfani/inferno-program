# frozen_string_literal: true

require_relative '../core/capability_statement_sequence'

module Inferno
  module Sequence
    class UsCoreR4CapabilityStatementSequence < CapabilityStatementSequence
      extends_sequence CapabilityStatementSequence

      title 'Capability Statement'

      test_id_prefix 'C'

      requires :url
      defines :oauth_authorize_endpoint, :oauth_token_endpoint, :oauth_register_endpoint

      description 'Retrieve information about supported server functionality in the Capability Statement.'
      details %(
        # Background
        The #{title} Sequence tests a FHIR server's ability to formally describe features supported by the API by
        using the [Capability Statement](https://www.hl7.org/fhir/capabilitystatement.html) resource.
        The features described in the Capability Statement must be consistent with the required capabilities of a
        US Core server.  The Capability Statement must also advertise the location of the required SMART on FHIR endpoints
        that enable authenticated access to the FHIR server resources.

        The Capability Statement resource allows clients to determine which resources are supported by a FHIR Server.
        Not all servers are expected to implement all possible queries and data elements described in the US Core API.
        For example, the US Core Implementation Guide requires that the Patient resource and
        only one additional resource profile from the US Core Profiles.


        Note that the name of this resource changed to from 'Conformance Statement' to 'CapabilityStatement' in STU3
        to better describe the intent of this resource.
        This test refers to it as the Capability Statement.

        # Test Methodology

        This test suite accesses the server endpoint at `/metadata` using a `GET` request.
        It parses the Capability Statement and verifies that :

        * The endpoint is secured by an appropriate cryptographic protocol
        * The resource matches the expected FHIR version defined by the tests
        * The resource is a valid FHIR resource
        * The server claims support for JSON encoding of resources
        * The server claims support for the Patient resource

        It collects the following information that is saved in the testing session for use by later tests:

        * List of resources supported
        * List of queries parameters supported

        For more information of the Capability Statement, visit these links:

        * [Capability Statement](https://www.hl7.org/fhir/capabilitystatement.html)
        * [DSTU2 Conformance Statement](https://www.hl7.org/fhir/DSTU2/conformance.html)
      )

      test 'FHIR server capability states JSON support' do
        metadata do
          id '04'
          link 'http://hl7.org/fhir/us/core/2019Jan/CapabilityStatement-us-core-server.html'
          description %(

            FHIR provides multiple [representation formats](https://www.hl7.org/fhir/formats.html) for resources, including JSON and XML.
            US Core profiles require servers to use the [JSON representation](https://www.hl7.org/fhir/json.html):

            [```The US Core Server **SHALL** Support json source formats for all US Core interactions.```](https://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-server.html)

            The FHIR capability interaction require servers to describe which formats are available for clients to use.
            The server must explicitly state that JSON is supported.  This is located in the
            [format element](https://www.hl7.org/fhir/capabilitystatement-definitions.html#CapabilityStatement.format)
            of the Capability Resource.

            This test checks that one of the following values are located in the format field.

            * json
            * application/json
            * application/fhir+json

          )
        end

        assert_valid_conformance

        assert json_formats.any? { |format| @conformance.format.include? format }, 'Conformance does not state support for json.'
      end

      test 'Capability Statement lists supported US Core profiles, operations and search parameters' do
        metadata do
          id '05'
          link 'http://hl7.org/fhir/us/core/2019Jan/CapabilityStatement-us-core-server.html'
          desc %(
           The US Core Implementation Guide states:

           ```
           The US Core Server SHALL:

               1. Support the US Core Patient resource profile.
               2. Support at least one additional resource profile from the list of US Core Profiles.
           ```

          )
        end

        assert_valid_conformance

        assert @instance.conformance_supported?(:Patient, [:read]), 'Patient resource with read interaction is not listed in capability statement.'
      end
    end
  end
end
