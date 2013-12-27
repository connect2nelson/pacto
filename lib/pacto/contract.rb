module Pacto
  class Contract
    attr_reader :values
    attr_reader :request, :response, :file

    def initialize(request, response, file = nil)
      @request = request
      @response = response
      @file = file
    end

    def stub_contract!(values = {})
      @values = values
      @request_pattern = Pacto.configuration.provider.stub_request!(@request, stub_response)
    end

    def validate(actual_response = provider_response, opts = {})
      # Missing actual request
      Pacto::ContractValidator.validate self, nil, actual_response, opts
    end

    def matches?(request_signature)
      @request_pattern.matches? request_signature unless @request_pattern.nil?
    end

    private

    def provider_response
      @request.execute
    end

    def stub_response
      @response.instantiate
    end
  end
end
