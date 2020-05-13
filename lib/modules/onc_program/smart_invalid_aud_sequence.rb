# frozen_string_literal: true

module Inferno
  module Sequence
    class SMARTInvalidAudSequence < SequenceBase
      title 'SMART App Launch Error Condition: Invalid AUD'
      description 'Demonstrate that the server properly validates AUD parameter'

      test_id_prefix 'SIA'

      requires :bulk_client_id, :bulk_jwks_url_auth, :bulk_encryption_method, :bulk_token_endpoint, :bulk_scope
      defines :bulk_access_token

      test 'Test to be implemented by v1.0' do
        metadata do
          id '01'
          link 'http://www.hl7.org/fhir/smart-app-launch/'
          description %(
            Test description
        )
        end
      end
    end
  end
end