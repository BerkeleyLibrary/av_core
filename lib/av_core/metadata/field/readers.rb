require 'json'

module AVCore
  module Metadata
    module Field
      module Readers
        TITLE = Reader.new(label: 'Title', marc_tag: '245%%', order: 1, subfield_order: 'a')
        DESCRIPTION = Reader.new(label: 'Description', marc_tag: '520%%', order: 2, subfield_order: 'a')
        CREATOR_PERSONAL = Reader.new(label: 'Creator', marc_tag: '700%%', order: 2)
        CREATOR_CORPORATE = Reader.new(label: 'Creator', marc_tag: '710%%', order: 2)
        LINKS_HTTP = Reader.new(label: 'Linked Resources', marc_tag: '85641', order: 11)
        DEFAULT_FIELDS = [TITLE, DESCRIPTION, CREATOR_PERSONAL, CREATOR_CORPORATE, LINKS_HTTP].freeze

        class << self
          def all
            @factories ||= begin
              json_config_path = File.join(__dir__, 'tind_html_metadata_da.json')
              json_config = File.read(json_config_path)
              json = JSON.parse(json_config)

              configured = json['config'].map { |jf| Reader.from_json(jf) }.compact
              readers = (DEFAULT_FIELDS + configured).sort

              unique_readers = []
              readers.each do |f|
                next if unique_readers.any? { |u| u.same_field?(f) }
                unique_readers << f
              end
              unique_readers
            end
          end
        end
      end
    end
  end
end
