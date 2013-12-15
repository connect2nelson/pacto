module Pacto
  module Validators
    class ResponseHeaderValidator
      def initialize(app)
        @app = app
      end

      def call env
        expected_headers = env[:contract].response.headers
        actual_headers = env[:actual_response].headers
        env[:validation_results] << self.class.validate(expected_headers, actual_headers)
        @app.call env
      end

      def self.validate expected_headers, actual_headers
        headers_to_validate = expected_headers.dup
        expected_location = headers_to_validate.delete 'Location'
        unless headers_to_validate.normalize_keys.subset_of?(actual_headers.normalize_keys)
          return ["Invalid headers: expected #{expected_headers.inspect} to be a subset of #{actual_headers.inspect}"]
        end

        if expected_location
          location_template = Addressable::Template.new(expected_location)
          location = actual_headers['Location']
          if location.nil?
            return ['Expected a Location Header in the response']
          elsif !location_template.match(Addressable::URI.parse(location))
            return ["Location mismatch: expected URI #{location} to match URI Template #{location_template.pattern}"]
          end
        end
      end
    end
  end
end