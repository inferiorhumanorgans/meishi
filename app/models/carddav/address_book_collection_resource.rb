module Carddav
  class AddressBookCollectionResource < AddressBookBaseResource

      def collection?
        true
      end

      def children
        Rails.logger.error "ABCR::children(#{public_path})"
          AddressBook.find_all_by_user_id(current_user.id).collect do |book|
            Rails.logger.error "trying to create this child (child should be AB): #{book.id.to_s}"
            child book.id.to_s
          end
      end

      def setup
        super
      end

      def resource_type
        s='<resourcetype><D:collection /></resourcetype>'
        return Nokogiri::XML::DocumentFragment.parse(s)
      end

      def exist?
        Rails.logger.error "ABCR::exist?(#{public_path});"
        return true
      end
  end
end