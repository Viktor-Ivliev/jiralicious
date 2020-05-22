module Jiralicious
  class ParamsEncoder #:nodoc:
    class << self
      # @return <String> This hash as a query string
      #
      # @example
      #   ParamsEncoder.encode(
      #     name: "Bob",
      #     address: {
      #       street: '111 Ruby Ave.',
      #       city: 'Ruby Central',
      #       phones: ['111-111-1111', '222-222-2222']
      #     }
      #   )
      #   #=> "name=Bob&address[city]=Ruby Central&address[phones][]=111-111-1111&address[phones][]=222-222-2222&address[street]=111 Ruby Ave."

      def encode(params)
        encoded_params = params.map { |k, v| encode_param(k, v) }.join
        encoded_params.chop! # trailing &
        encoded_params
      end

      # @param key<Object> The key for the param.
      # @param value<Object> The value for the param.
      #
      # @return <String> This key value pair as a param
      #
      # @example encode_param(:name, "Bob Jones") #=> "name=Bob%20Jones&"

      def encode_param(key, value)
        param = ''
        stack = []

        if value.is_a?(Array)
          param << value.map { |element| encode_param("#{key}[]", element) }.join
        elsif value.is_a?(Hash)
          stack << [key, value]
        else
          param << "#{key}=#{URI.encode(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}&"
        end

        stack.each do |parent, hash|
          hash.each do |key, value|
            if value.is_a?(Hash)
              stack << ["#{parent}[#{key}]", value]
            else
              param << encode_param("#{parent}[#{key}]", value)
            end
          end
        end

        param
      end
    end
  end
end
