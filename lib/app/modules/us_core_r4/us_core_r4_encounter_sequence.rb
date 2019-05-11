module Inferno
  module Sequence
    class USCoreR4EncounterSequence < SequenceBase

      group 'US Core R4 Profile Conformance'

      title 'US Core R4 Encounter Profile Tests'

      description 'Verify that Encounter resources on the FHIR server follow US Core R4.'

      test_id_prefix 'R4EN'

      requires :token, :patient_id
      conformance_supports :Encounter

      def validate_resource_item (resource, property, value)
        case property
        when "patient"
          assert (resource.subject && resource.subject.reference.include?(value)), "Patient on resource does not match patient requested"
        end
      end

      details %(

        Encounter profile requirements from [US Core R4 Server Capability Statement](http://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-r4-server.html#encounter).

        Search requirements (as of 1 May 19):

        | Conformance | Parameter         | Type             | Modifiers
        |-------------|-------------------|------------------|----------------------
        | SHALL       | patient           | reference        |
        | SHALL       | patient + date    | reference + date | date modifiers: ge, le, gt, lt

        Note: Terminology validation currently disabled.

        TODO:
        * Validating responses are between correct dates
        * date modifiers
      )

      @resources_found = false

      test 'Server rejects Encounter search without authorization' do

        metadata {
          id '01'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          desc %(
            An Encounter search does not work without proper authorization.
          )
          versions :r4
        }

        @client.set_no_auth
        skip 'Could not verify this functionality when bearer token is not set' if @instance.token.blank?

        reply = get_resource_by_params(versioned_resource_class('Encounter'), {patient: @instance.patient_id})
        @client.set_bearer_token(@instance.token)
        assert_response_unauthorized reply

      end

      test 'Server returns expected results from Encounter search by patient' do

        metadata {
          id '02'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          desc %(
            A server is capable of returning a patient's allergies.
          )
          versions :r4
        }

        search_params = {patient: @instance.patient_id}
        reply = get_resource_by_params(versioned_resource_class('Encounter'), search_params)
        assert_response_ok(reply)
        assert_bundle_response(reply)

        resource_count = reply.try(:resource).try(:entry).try(:length) || 0
        if resource_count > 0
          @resources_found = true
        end

        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        @encounter = reply.try(:resource).try(:entry).try(:first).try(:resource)
        validate_search_reply(versioned_resource_class('Encounter'), reply, {subject: @instance.patient_id})
        save_resource_ids_in_bundle(versioned_resource_class('Encounter'), reply)

      end


      test 'Server returns expected results from Encounter Results search by patient + date' do

        metadata {
          id '03'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          desc %(
            A server SHOULD be capable of returning all of a patient's laboratory results queried by category and one or more codes and date range.
          )
          versions :r4
        }

        skip_if_not_supported(:Encounter, [:search, :read])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        assert !@encounter.nil?, 'Expected valid Observation resource to be present'
        date = @encounter&.period&.start
        assert !date.nil?, "Encounter period not returned"
        search_params = {patient: @instance.patient_id, date: date}
        reply = get_resource_by_params(versioned_resource_class('Encounter'), search_params)
        validate_search_reply(versioned_resource_class('Encounter'), reply, search_params)

      end


      test 'Server returns expected results from Encounter read resource' do

        metadata {
          id '04'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          desc %(
            All servers SHALL make available the read interactions for the Argonaut Profiles the server chooses to support.
          )
          versions :r4
        }

        skip_if_not_supported(:Encounter, [:search, :read])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        validate_read_reply(@encounter, versioned_resource_class('Encounter'))

      end

      test 'Encounter history resource supported' do

        metadata {
          id '05'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          optional
          desc %(
            All servers SHOULD make available the vread and history-instance interactions for the Argonaut Profiles the server chooses to support.
          )
          versions :r4
        }

        skip_if_not_supported(:Encounter, [:history])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found
        validate_history_reply(@encounter, versioned_resource_class('Encounter'))

      end

      test 'Encounter vread resource supported' do

        metadata {
          id '06'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          optional
          desc %(
            All servers SHOULD make available the vread and history-instance interactions for the Argonaut Profiles the server chooses to support.
          )
          versions :r4
        }

        skip_if_not_supported(:Encounter, [:vread])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        validate_vread_reply(@encounter, versioned_resource_class('Encounter'))

      end

      test 'Encounter resources associated with Patient conform to Argonaut profiles' do

        metadata {
          id '07'
          link 'http://www.fhir.org/guides/argonaut/r2/StructureDefinition-argo-encounter.html'
          desc %(
            Encounter resources associated with Patient conform to Argonaut profiles
          )
          versions :r4
        }
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found
        test_resources_against_profile('Encounter')
      end

      test 'All references can be resolved' do

        metadata {
          id '08'
          link 'https://www.hl7.org/fhir/DSTU2/references.html'
          desc %(
            All references in the Encounter resource should be resolveable.
          )
          versions :r4
        }

        skip_if_not_supported(:Encounter, [:search, :read])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        validate_reference_resolutions(@encounter)

      end


    end

  end
end
