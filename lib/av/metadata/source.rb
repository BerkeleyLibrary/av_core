require 'rest_client'
require 'typesafe_enum'
require 'av/config'
require 'av/logger'
require 'av/record_not_found'
require 'av/marc'
require 'av/marc/millennium'
require 'av/util'
require 'av/metadata/readers'

module AV
  class Metadata
    class Source < TypesafeEnum::Base
      new :TIND
      new :MILLENNIUM

      LINK_TEXT_MILLENNIUM = 'View library catalog record.'.freeze
      LINK_TEXT_TIND = 'View record in Berkeley Library Digital Collections.'.freeze

      class << self
        def for_record_id(record_id)
          record_id =~ Readers::MILLENNIUM_RECORD_RE ? Source::MILLENNIUM : Source::TIND
        end
      end

      def reader
        return Readers::Millennium if self == MILLENNIUM
        return Readers::TIND if self == TIND

        raise ArgumentError, "Unsupported metadata source: #{self}"
      end

      def catalog_link_text
        return LINK_TEXT_MILLENNIUM if self == MILLENNIUM
        return LINK_TEXT_TIND if self == TIND

        raise ArgumentError, "Unsupported metadata source: #{self}"
      end

      def record_for(record_id)
        record_id = ensure_valid_id(record_id)
        reader.record_for(record_id)
      end

      def display_uri_for(metadata)
        record_id = record_id_from(metadata)
        reader.display_uri_for(record_id)
      end

      def marc_uri_for(record_id)
        record_id = ensure_valid_id(record_id)
        reader.marc_uri_for(record_id)
      end

      def record_for_bib(bib_number)
        bib_number = MILLENNIUM.ensure_valid_id(bib_number)
        reader.record_for(bib_number) # TIND can detect and handle Millennium bibs
      end

      def ensure_valid_id(record_id)
        return record_id if Source.for_record_id(record_id) == self

        raise ArgumentError, "Not a valid record ID for source #{value.inspect}: #{record_id}"
      end

      private

      def record_id_from(metadata)
        return metadata.bib_number if self == MILLENNIUM && metadata.respond_to?(:bib_number)
        return metadata.tind_id if self == TIND && metadata.respond_to?(:tind_id)

        raise ArgumentError, "#{self}: unable to determine record ID from metadata #{metadata.inspect}"
      end

    end
  end
end
