module AV
  class Metadata
    class Link
      attr_reader :body
      attr_reader :url

      def initialize(body:, url:)
        @body = body
        @url = url
      end

      def to_s
        "[#{body}](#{url})"
      end
    end
  end
end
