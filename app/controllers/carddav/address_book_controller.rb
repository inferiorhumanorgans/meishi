=begin
RFC 4918
16. Precondition/Postcondition XML Elements
  In a 207 Multi-Status response, the XML element
  MUST appear inside an 'error' element in the appropriate 'propstat or
  'response' element depending on whether the condition applies to one
  or more properties or to the resource as a whole.  In all other error
  responses where this specification's 'error' body is used, the
  precondition/postcondition XML element MUST be returned as the child
  of a top-level 'error' element in the response body, unless otherwise
  negotiated by the request, along with an appropriate response status.
  The most common response status codes are 403 (Forbidden) if the
  request should not be repeated because it will always fail, and 409
  (Conflict) if it is expected that the user might be able to resolve
  the conflict and resubmit the request.  The 'error' element MAY
  contain child elements with specific error information and MAY be
  extended with any custom child elements.
=end

=begin
RFC 3253
3.6 REPORT Method
  Preconditions:

    (DAV:supported-report): The specified report MUST be supported by
    the resource identified by the request-URL.
=end

=begin
RFC 6352
8.7. CARDDAV:addressbook-multiget Report
  Preconditions:

    (CARDDAV:supported-address-data): The attributes "content-type"
    and "version" of the CARDDAV:address-data XML elements (see
    Section 10.4) specify a media type supported by the server for
    address object resources.
=end
class Carddav::AddressBookController < Carddav::BaseController

  def initialize(request, response, options={})
    super

    @verbs = 'OPTIONS,PROPFIND,PROPPATCH,REPORT,LOCK,UNLOCK'

    self
  end

  def options
    @response['Allow'] = @verbs
    OK
  end

  def report
    debug_report = ENV['MEISHI_DEBUG_REPORT'].to_i
    debug_request = ENV['MEISHI_DEBUG_XML_REQUEST'].to_i
    debug_response = ENV['MEISHI_DEBUG_XML_RESPONSE'].to_i

    unless resource.exist?
      return NotFound
    end

    Rails.logger.debug "REPORT DEPTH IS: #{depth.inspect}" if debug_report >= 1

    if request_document.nil? or request_document.root.nil?
      xml_error(BadRequest) do |err|
        err.send :'empty-request'
      end
    end

    Rails.logger.debug "REPORT type: #{request_document.root.name}" if debug_report >= 1

    if debug_request >= 1
      Rails.logger.debug "*** REQUEST BEGIN"
      Rails.logger.debug request_document.to_xml((debug_request >= 2) ? YES_INDENT_FLAGS : NO_INDENT_FLAGS)
      Rails.logger.debug "*** REQUEST END"
    end

    case request_document.root.name
    when 'addressbook-multiget'
      addressbook_multiget
    when 'addressbook-query'
      addressbook_query
    else
      xml_error do |err|
        err.send :'supported-report'
      end
    end

    if debug_response >= 1
      Rails.logger.debug "*** RESPONSE BEGIN"
      x = Nokogiri::XML(response.body) do |config|
        config.default_xml.noblanks
      end
      Rails.logger.debug x.to_xml((debug_response >= 2) ? YES_INDENT_FLAGS : NO_INDENT_FLAGS)

      Rails.logger.debug "*** RESPONSE END"
    end

  end

  protected
  def addressbook_multiget
    debug_multiget = ENV['MEISHI_DEBUG_REPORT_LIST'] =~ /multiget/

    # CardDAV §8.7 clearly states Depth must equal zero for this report
    # But Apple's AddressBook.app (OSX 10.6) and emClient 5.x don't set the
    # depth header.
    # BB10.2 sets depth to 1 for some unknown reason.
    ignore_depth = Quirks.match(:IGNORE_ADDRESS_BOOK_MULTIGET_DEPTH, request.user_agent)

    unless (depth == 0) or ignore_depth
      xml_error(BadRequest) do |err|
        err.send :'invalid-depth'
      end
    end

    # Handle the address-data element
    # - Check for child properties (vCard fields)
    # - Check for mime-type and version.  If present they must match vCard 3.0 for now since we don't support anything else.
    hrefs = request_document.xpath("/#{xpath_element('addressbook-multiget', :carddav)}/#{xpath_element('href')}").collect{|n| 
      text = n.text
      # TODO: Make sure that the hrefs passed into the report are either paths or fully qualified URLs with the right host+protocol+port prefix
      path = URI.parse(text).path
      Rails.logger.debug "Scanned this HREF: #{text} PATH: #{path}" if debug_multiget
      text
    }.compact
    
    if hrefs.empty?
      xml_error(BadRequest) do |err|
        err.send :'href-missing'
      end
    end

    multistatus do |xml|
      hrefs.each do |_href|
        xml.response do
          xml.href _href

          path = File.split(URI.parse(_href).path).last
          Rails.logger.error "Creating child w/ ORIG=#{resource.public_path} HREF=#{_href} FILE=#{path}!" if debug_multiget

          # TODO: Write a test to cover asking for a report expecting contact objects but given an address book path
          # Yes, CardDAVMate does this.
          cur_resource = resource.is_self?(_href) ? resource : resource.child(File.split(path).last)
          
          if cur_resource.exist?
            propstats(xml, get_properties(cur_resource, get_request_props_hash('addressbook-multiget', request_document)))
          else
            xml.status "#{http_version} #{NotFound.status_line}"
          end

        end
      end
    end
  end

  def addressbook_query
    debug_report = ENV['MEISHI_DEBUG_REPORT_LIST'] =~ /query/

    Rails.logger.debug "addressbook-query depth: #{depth.inspect}, should be 1 or infinity" if debug_report

    fields = Field.arel_table

    limit = nil
    limits = request_document.xpath("/#{xpath_element('addressbook-query', :carddav)}/#{xpath_element('limit', :carddav)}")

    # Not RFC compliant, but it helps us enforce sane requests
    if limits.count > 1
      xml_error(BadRequest) do |err|
        err['C'].send :'conflicting-limits-specified'
      end
    elsif limits.count == 1
      limits = limits.first.xpath('./*')
      # Not RFC compliant, but it helps us enforce sane requests
      if limits.count != 1
        xml_error(BadRequest) do |err|
          err['C'].send :'conflicting-limits-specified'
        end
      end

      limits = limits.first
      if limits.name != 'nresults'
        # Not RFC compliant, but it helps us enforce sane requests
        xml_error(BadRequest) do |err|
          err['C'].send :'only-nresults-supported'
        end
      end

      limit = limits.text.to_i
    end

    filter_def = request_document.xpath("/#{xpath_element('addressbook-query', :carddav)}/#{xpath_element('filter', :carddav)}").first
    filters = filter_def.xpath("./#{xpath_element('prop-filter', :carddav)}")

    global_test = nil
    case (filter_def[:test] || 'anyof')
    when 'allof'
      global_test = :and
    when 'anyof'
      global_test = :or
    end
    raise BadRequest unless global_test

    filter_query = []

    filters.each do |prop_filter|
      prop_name = prop_filter[:name]
      prop_query = fields[:name].eq(prop_name)
      conditions = []

      prop_test = nil
      case (prop_filter[:test] || 'anyof')
      when 'anyof'
        prop_test = :or
      when 'allof'
        prop_test = :and
      end
      
      raise BadRequest unless prop_test

      case (prop_filter[:collation] || 'i;unicode-casemap')
      when 'i;ascii-casemap'
        collation_type = :ascii
      when 'i;unicode-casemap'
        collation_type = :unicode
      end
      # RFC 6352 §8.3
      unless collation_type
        xml_error(PreconditionFailed) do |err|
          err['C'].send :'supported-collation'
        end
      end

      prop_filter.xpath('*').each do |condition|
        match_type = nil
        case (condition[:'match-type'] || 'equals')
        when 'contains'
          match_type = :contains
        when 'ends-with'
          match_type = :ends_with
        when 'equals'
          match_type = :equals
        when 'starts-with'
          match_type = :starts_with
        end
        # RFC 6352 §8.6
        unless match_type
          xml_error(PreconditionFailed) do |err|
            err['C'].send :'supported-filter'
          end
        end

        value_field = nil
        match_value = nil
        case collation_type
        when :ascii
          value_field = :ascii_casemap
          match_value = Comparators::ASCIICasemap.prepare(condition.text)
        when :unicode
          value_field = :unicode_casemap
          match_value = Comparators::UnicodeCasemap.prepare(condition.text)
        end

        case match_type
        when :contains
          conditions << fields[value_field].matches("%#{match_value}%")
        when :ends_with
          conditions << fields[value_field].matches("%#{match_value}")
        when :equals
          conditions << fields[value_field].eq(match_value)
        when :starts_with
          conditions << fields[value_field].matches("#{match_value}%")
        end

      end

      next if conditions.empty?

      cur_filter_query = conditions.shift
      conditions.each do |condition|
        cur_filter_query = cur_filter_query.send(prop_test, condition)
      end

      filter_query << prop_query.and(cur_filter_query)
    end

    query = Arel::Nodes::Grouping.new(filter_query.shift)
    filter_query.each do |condition|
      query = query.send(global_test, Arel::Nodes::Grouping.new(condition))
    end

    contacts = Contact.joins(:address_book)
                      .where('address_books.id' => resource.address_book.id)
                      .where('address_books.user_id' => current_user.id)
                      .joins(:fields)
                      .where(query)
                      .uniq

    if contacts.length > Meishi::Application.config.max_number_of_results_per_report
      # RFC 6352 §8.6
      xml_error(Conflict) do |err|
        err.send :'number-of-matches-within-limits'
      end
    end

    over_limit = nil
    if limit and limit > 0
      over_limit = contacts.count if contacts.count > limit
      contacts = contacts[0..(limit-1)]
    end

    multistatus do |xml|
      if over_limit
        xml.response do
          xml.href resource.public_path
          xml.status "#{http_version} #{InsufficientStorage.status_line}"
          xml.error do
            xml.send :'number-of-matches-within-limits'
          end

          xml.responsedescription "Only #{contacts.count} of #{TextHelper.pluralize(over_limit, 'matching record')} were returned.", :'xml:lang' => :en
        end
      end

      contacts.each do |contact|
        xml.response do
          href = URLHelpers.contact_path(resource.address_book, contacts.first)
          xml.href href

          cur_resource = resource.is_self?(href) ? resource : resource.child(contact.uid)

          if cur_resource.exist?
            propstats(xml, get_properties(cur_resource, get_request_props_hash('addressbook-query', request_document)))
          else
            xml.status "#{http_version} #{NotFound.status_line}"
          end

        end
      end
    end
  end

  protected
  def get_request_props_hash(root_element, request_document)
    request_document.xpath("/#{xpath_element(root_element, :carddav)}/#{xpath_element('prop')}").children.find_all{|n| n.element?}.map{|n|
      to_element_hash(n)
    }
  end

end
