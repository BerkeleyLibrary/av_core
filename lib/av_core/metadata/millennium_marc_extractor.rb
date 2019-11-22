require 'cgi'
require 'marc'

module AVCore
  module Metadata
    class MillenniumMARCExtractor

      attr_reader :marc_txt

      PRE_TAG_REGEXP = %r{<pre>(((?!</pre>).)*)</pre>}m.freeze

      def initialize(html)
        match_data = html.match(PRE_TAG_REGEXP)
        raise ArgumentError, 'MARC <pre/> tag not found in HTML' unless match_data

        marc_txt = match_data[1].strip
        @marc_txt = CGI.unescape_html(marc_txt)
      end

      # @return [MARC::Record] The extracted record
      def extract_marc_record
        self.record = MARC::Record.new
        self.current_field = nil
        marc_txt.lines.each { |line| process_line(line) }
        record
      end

      private

      TAG_REGEXP = /([0-9]{3}) ([0-9 ])([0-9 ]) (.*)/.freeze
      SUBFIELD_REGEXP = /(\|[^ ])?([^|]+)/.freeze

      attr_accessor :record
      attr_accessor :current_field
      attr_accessor :current_text

      def process_line(line)
        tag_match_data = line.match(TAG_REGEXP)
        if tag_match_data
          tag, ind_1, ind_2, text = tag_match_data[1, 4]
          start_next_tag(tag, ind_1, ind_2, text)
        elsif line.start_with?('       ')
          add_text(line.strip)
        end
      end

      def start_next_tag(tag, ind_1, ind_2, text)
        finalize_current_field if current_field
        return if tag.start_with?('00') # skip control fields

        self.current_field = MARC::DataField.new(tag, ind_1, ind_2)
        add_text(text.strip)
      end

      def finalize_current_field
        raise 'No current field to finalize' unless current_field

        current_field.subfields = finalize_subfields
        record.append(current_field)

        self.current_text = nil
        self.current_field = nil
      end

      def add_text(text)
        self.current_text = current_text ? current_text + ' ' + text : text
      end

      def finalize_subfields
        current_field.subfields = current_text.scan(SUBFIELD_REGEXP).map do |identifier, value|
          code = identifier ? identifier[1] : 'a'
          MARC::Subfield.new(code, value)
        end
      end
    end
  end
end
