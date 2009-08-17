#
# = uformatparser.rb - Microformat parser
#
#--
# Author:: Assaf Arkin assaf@labnotes.org
# Documentation:: http://trac.labnotes.org/cgi-bin/trac.cgi/wiki/Ruby/MicroformatParser
# Copyright:: Copyright (c) 2005 Assaf Arkin
# License:: Creative Commons Attribution-ShareAlike
#
#++

require 'rexml/document'


# Implements a microformat parser by extending a class that includes this module.
#
# === The Basics
#
# To create a microformat parser, extend a class with this module and use the
# +rule+ method to define parsing rules for that class. Call +parse+ to parse the
# content, returning a new instance of the class holding all values extracted from
# parsing. You can parse a document or an element.
#
# For example:
#   class Microformats
#     include MicroformatParser
#
#     class HCalendar
#       include MicroformatParser
#
#       # Extract ISO date/time
#       extractor :dt_extractor do |node|
#         value = node.attributes['title'] if node.name == 'abbr'
#         value = text(node) unless value
#         value ? Time.parse(value) : nil
#       end
#
#       rule_1 :dtstart, nil, :dt_extractor
#       rule_1 :dtend, nil, :dt_extractor
#       rule_1 :summary, nil, :text
#       rule_1 :description, nil, :xml
#       rule_1 :url, nil, "a@href"
#     end
#
#     rule :tags, "a[rel~=tag]", "text()"
#     rule :events, ".vevent", HCalendar
#   end
#
#   content = Microformats.parse(doc)
#   puts content.tags
#   puts content.events
#
module MicroformatParser


    # Create a new rule.
    #
    # There are two ways to define a rule:
    #   * rule name, selector?, extractor?, limit?
    #   * rule name, limit? { block }
    #
    # The +name+ argument specifies an instance variable that holds the value
    # (or values) extracted from processing this rule. It can be a string or
    # a symbol. An attribute accessor is created with that name.
    #
    # The +selector+ argument identifies all nodes that match the rule. It can
    # be an CSS-style selector (string) or a method/proc. A symbol specifies
    # a method to use from this class. The method/proc receives a single argument
    # with the node and must return true/false.
    #
    # If selector is absent, the default selector will match any element with
    # a class of the same name as the name argument. For example:
    #   rule :dtstart
    # Matches all elements with the class _dtstart_.
    #
    # The +extractor+ argument specifies how to extract a value from a selected
    # node. It can be a list of extract rules (string), a method/proc, or a class.
    # A symbol specifies a method to use from this class. The method/proce receives
    # a single argument with the node and returns the extracted value, or nil.
    #
    # If the extractor is a class, it references a microformat parser which is
    # then called to parse the content of a matching element.
    #
    # If extractor is absent, the default extractor is used:
    #   abbr@title|a@href|text()
    #
    # The +limit+ argument specifies the cardinality of the rule's value:
    #   0  The rule is never applied
    #   1  The rule is applied once, the first extracted value is set
    #   -1 The rule is applied multiple times, extracted values are set in an array
    #   n  The rule is applied up to _n_ times, extracted values are set in an array
    #
    # In the second form, a block is specified instead of the selector/extractor.
    # The block is called with a node and returns the extracted value, or nil.
    def rule(name, selector = nil, extractor = nil, limit = -1, &proc)
        raise InvalidRuleException, "First argument (rule name) is required" unless name
        if proc
            # The rule processing is taken from the block, everything else must be nil
            raise InvalidRuleException, "Can't specify selector/extractor in combination with proc" if selector or extractor
            rule = Rule.new(name, nil, proc, limit)
        else
            # Determine the selector.
            selector = case selector
            when NilClass
                # Absent selector: create a selector that matches element with the same
                # class as the rule name
                match = Regexp.new("\\b#{name.to_s}\\b")
                proc { |node| node.attributes['class'] =~ match }
            when String
                # CSS-style selector
                Selector.create(selector)
            when Proc, Method
                # Use as is
                selector
            when Symbol
                # Find named method and use that as the selector
                # Since the instance method is unbound, we bind it to this class
                selector = method(selector)
                raise InvalidSelectorException, "Method #{name.to_s} is not a valid selector" unless selector
                selector
            else
                raise InvalidSelectorException, "Invalid selector type: must be a string, symbol, proc/method or nil"
            end

            # Determine the extractor
            extractor = case extractor
            when NilClass
                # Absent extractor: either block if provided, otherwise default extractor
                default_extractor
            when String
                # Extractor expression
                Extractor.new(self, extractor)
            when Proc, Method
                # Use as is
                extractor
            when Symbol
                # Find named method and use that as the extractor
                # Since the instance method is unbound, we bind it to this class
                extractor = method(extractor)
                raise InvalidExtractorException, "Method #{name.to_s} is not a valid extractor" unless extractor
                extractor
            when Class
                # Extractor is a class, generally another ruleset, so we call
                # its parse method (must exist).
                begin
                    extractor.method(:parse)
                rescue NameError=>error
                    raise InvalidExtractorException, "Extractor class must implement the method parse", error.backtrace
                end
                extractor
            else
                raise InvalidExtractorException, "Invalid extractor type: must be a string, parser class, block or nil"
            end

            # Create a new rule, to invoke its process method
            rule = Rule.new(name, selector, extractor, limit)
        end

        # Create an accessor for an attribute with the same name as the rule
        # The accessor will hold the rule value
        attr name, true
        # Add this rule to class's ruleset
        self.rules << rule
    end


    # Create a new rule that extracts at most one value.
    #
    # Same as calling +rule+ with +limit+=1
    def rule_1(name, selector = nil, extractor = nil, &proc)
        # Rule with limit of one value
        rule(name, selector, extractor, 1, &proc)
    end


    # Creates a new selector.
    #
    # There are two ways to create a selector:
    #   * selector name, statement
    #   * selector name { block }
    #
    # The +name+ argument (a string or symbol) specifies the selector name,
    # defining a class method with that name that can be used to identify matching
    # element.
    #
    # The selector can be a CSS-style selector (string) or a block that accepts a
    # single argument (element) and returns true or false.
    #
    # For example:
    #   selector :select_link { |node| node.name == 'a' }
    #   extractor :extract_link { |node| node.attributes['href'] }
    #   rule :links, :select_link, :extract_link
    def selector(name, selector = nil, &proc)
        raise InvalidSelectorException, "First argument (rule name) is required" unless name
        selector = case selector
        when NilClass
            # Absent selector: either block is provided, or we create a selector
            # that matches element with the same class as the selector name
            if proc
                proc
            else
                match = Regexp.new("\\b#{name.to_s}\\b")
                proc { |node| node.attributes['class'] =~ match }
            end
        when String
            # CSS-style selector
            Selector.create(selector)
        else
            raise InvalidSelectorException, "Invalid selector type: must be a string, block or nil"
        end
        # Create a class method using the selector name that calls the
        # selector's match method.
        class << self
            self
        end.instance_eval { define_method(name) { |node| selector.call(node) } }
    end


    # Creates a new extractor.
    #
    # There are two ways to create an extractor:
    #   * extractor name, statement
    #   * extractor selector name { block }
    #
    # The +name+ argument (string or symbol) specifies the extractor name,
    # defining a class method with that name that can be used to extract the
    # value of a node.
    #
    # The extractor can be an expression (string) or a block that accepts a
    # single argument (element) and returns the extracted value, or nil.
    #
    # For example:
    #   selector :select_link { |node| node.name == 'a' }
    #   extractor :extract_link { |node| node.attributes['href'] }
    #   rule :links, :select_link, :extract_link
    #
    # The expression takes the form of:
    #   extractor := extract (|extract)*
    #   extract   := element | @attribute | element@attribute | method()
    #
    # If multiple extracts are specified, the first extracted value is used.
    #
    # If an element is specified, the text value is extracted only if the selected
    # node is an element of that type. If an attribute is specified, the extracted
    # value is the attribute's value. If both element and attribute are used, the
    # attribute value is extracted only if the selected node is an element of that
    # type.
    #
    # If a method is specified, that method is called for the node. There are two
    # methods available in any class: +text+ and +xml+.
    def extractor(name, extractor = nil, &proc)
        raise InvalidExtractorException, "First argument (rule name) is required" unless name
        extractor = case extractor
        when NilClass
            # Absent extractor: either block if provided, otherwise default extractor
            proc ? proc : default_extractor
        when String
            # Extractor expression
            Extractor.new(extractor)
        else
            raise InvalidExtractorException, "Invalid extractor type: must be a string, parser class, block or nil"
        end
        # Create a class method using the extractor name that calls the
        # extractor's extract method.
        class << self
            self
        end.instance_eval { define_method(name) { |node| extractor.call(node) } }
    end

    # Returns the default extractor.
    def default_extractor()
        return DEFAULT_EXTRACTOR
    end

    # Called to parse a node.
    #
    # The node may be an element (REXML::Element) or a document (REXML::Document).
    #
    # For example:
    #   class ParseLinks
    #     include MicroformatParser
    #
    #     rule :links, "a", "@href"
    #     rule :ids, "a[@id]", "a@id"
    #    end
    #
    #    parsed = ParseLinks.parse(doc)
    #    puts parsed.links
    #    puts parsed.ids
    def parse(node, context = nil, rules = nil)
        # Create a new object unless one is provided. This method can be
        # called on the class (creating a new instance) or on an object (recursive)
        context = self.new() unless context
        # Obtain the rules for this class unless provided by caller.
        rules = self.rules unless rules
        # Rules are reduced during processing. If a rule matches a node, that rule
        # is not applied to any child nodes (structured rules will process child nodes
        # directly). However, other rules are allowed to process the child nodes.
        # Removing a rule modifies the ruleset, requiring it to be cloned.
        less_rules = nil
        # We must have rules and the node must be an element/document
        if rules and node.kind_of? REXML::Element
            # Iterate over all the rules and process them. Remove any matching rules
            # from this ruleset -- the new ruleset will be used on child nodes.
            rules.each_with_index do |rule, index|
                if rule and rule.process(node, context)
                    less_rules = rules.clone unless less_rules
                    less_rules[index] = nil
                end
            end
            rules = less_rules if less_rules
            node.elements.each { |child| parse(child, context, less_rules) }
        end
        context
    end

    # Returns all the rules for this class.
    #
    # Returns an array of rules defined with +rule+.
    #
    # You can use this method to inspect rules, add/remove rules, etc. Rules are
    # processed in the order in which they are added.
    def rules
        rules = @microparser_rules
        @microparser_rules = rules = Array.new() unless rules
        rules
    end

    # Returns the text value of a node.
    def text(node)
        value = ''
        for child in node.children
            if child.instance_of? REXML::Text
                value += child.value
            elsif child.instance_of? REXML::Element
                value += text(child)
            end
        end
        value
    end

    # Returns the XML value of a node (the node itself).
    def xml(node)
        node
    end

    module_function :text, :xml



private

    def self.included(mod)
        mod.extend(self)
    end


    # Implements a rule.
    #
    # A rule identifies matching nodes using a selector, and a means to extract their value
    # using an extractor. The rule also identifies an instance variable and attribute accessor
    # to retrieve the extracted value, and the cardinality of that value.
    #
    # For more information see MicroformatParser.rule.
    class Rule

        # The instance variable/attribute accessor name.
        attr :name
        # The rule cardinality (or value limit)
        # 0:: No value (disabled)
        # 1:: First value extracted
        # n:: Up to n values (array)
        # -1:: Unbound (array)
        attr :limit,true
        # The rule selector
        attr :selector
        # The rule extractor
        attr :extractor

        def initialize(name, selector, extractor, limit)
            # Change the rule name to the attribute name holding the result
            @name = "@#{name.to_s}".to_sym
            @selector = selector
            @extractor = extractor
            @limit = limit
        end

        # Called to process this rule on a node with a context object.
        #
        # Returns true if the rule was processed and should be reduced (not applied to
        # any child nodes). Otherwise, returns false.
        def process(node, context)
            # Do nothing if rule is disabled (limit = 0), reduce it.
            return true if @limit == 0
            # Do nothing if rule is singular (limit = 1) and a value was already set
            current = context.instance_variable_get(@name)
            return true if @limit == 1 and current
            # Match the current node, do nothing if not matched
            # (Selector may be nil if rule created to wrap a proc)
            if @selector
                return false unless @selector.instance_of?(UnboundMethod) ? @selector.bind(context).call(node) :
                    @selector.instance_of?(Selector) ? @selector.match(node) : @selector.call(node)
            end
            # Extract the value. Do nothing if nothing extracted
            value = case @extractor
            when UnboundMethod
                @extractor.bind(context).call(node)
            when Extractor
                @extractor.extract(node)
            when Proc, Method
                @extractor.call(node)
            when Class
                @extractor.parse(node)
            end
            return false unless value
            # If limit=1, set the new value (singular)
            # If no current value, create new array with new value
            # Otherwise, if no limit or limit not reach, append value to
            # existing array
            if @limit == 1
                context.instance_variable_set(@name, value)
            elsif not current
                context.instance_variable_set(@name, [value])
            elsif current.instance_of? Array and (@limit < 0 or current.size < @limit)
                current << value
            end
            # We always return true, since there's no point in applying
            # the rule to any child nodes.
            return true
        end

        def inspect
            @selector ? "[to #{@name} from #{@selector.inspect}, #{@extractor.inspect}, limit #{@limit}]" : "[to #{@name} from #{@extractor.inspect}, limit #{@limit}]"
        end

    end


    # Implements a selector using a CSS-style expression.
    #
    # For more information see MicroformatParser.selector.
    class Selector

        # :stopdoc:

        # Parse each selector into five parts:
        # $1 element name or * (optional)
        # $2 ID name (including leading #, optional)
        # $3 class names (including leading ., zero or more)
        # $4 attribute expressions (zero or more)
        # $5 anything else (no leading spaces)
        REGEX = /^(\*|[A-Za-z][A-Za-z0-9_\-:]*)?(#[A-Za-z][A-Za-z0-9_\-:]*)?((?:\.[A-Za-z][A-Za-z0-9_\-:]*){0,})((?:\[[A-Za-z][A-Za-z0-9_\-:]*(?:(?:~|\|)?=.*)?\]){0,})\s*(.*)$/

        # Parse each attribute expression into three parts:
        # $1 attribute name
        # $2 matching operation
        # $3 matched value
        # Matching operation may be =, ~= or |=. Value may be empty.
        ATTR_REGEX = /^([A-Za-z][A-Za-z0-9_\-:]*)((?:~|\|)?=)?(.*)$/

        # :startdoc:

        def initialize(tag_name, attrs, alt = nil, &depends)
            @tag_name = tag_name
            @attrs = attrs
            @alt = alt
            @depends = depends
        end


    public
        # Creates a new selector.
        def Selector.create(statement, alt = nil, &depends)
            statement.strip!
            # Parse the first selector expression into $1-$4, anything else goes in $5
            parts = REGEX.match(statement)
            raise InvalidSelectorException, "Invalid (empty) selector statement" if parts[0].length == 0

            # Set tag_name to the element name if specified and not *
            tag_name = parts[1] if parts[1] and !parts[1].empty? and parts[1] != '*'
            # This array holds the regular expressions for matching attributes.
            # We use an array since we allow multiple expressions on the same attribute,
            # e.g. to find an element with both class 'foo' and class 'bar'.
            attrs = []
            # Match the ID attribute if specified
            attrs << ['id', Regexp.new('^' + parts[2] + '$')] if parts[2]
            # The third part is a collection of class names, prefixed with dot
            # Create an attribute matching regular expression for each class
            # The class attribute is a set of space-separated names, so match accordingly
            if !parts[3].empty?
                parts[3].split('.').each { |cls| attrs << ['class', Regexp.new('\b' + cls + '\b')] if !cls.empty? }
            end
            # Process the remaining attribute expressions. Each expression is enclosed
            # within square brackets, so split the expressions into anything between the
            # square brackets. The result may include empty elements, skip those.
            parts[4].split(/\[|\]/).each do |expr|
                if not expr.empty?
                    # Parse the attribute expression and created a regular expression
                    # for matching the attribute value, based on the operation.
                    name, type, value = ATTR_REGEX.match(expr)[1..3]
                    case type
                    when '=' then
                        # Match the attribute value in full
                        match = Regexp.new('^' + value + '$')
                    when '~=' then
                        # Match a space-separated word within the attribute value
                        match = Regexp.new('\b' + value + '\b')
                    when '|=' then
                        # Match the beginning of the attribute value
                        match = Regexp.new('^' + value)
                    else
                        # Match all attributes values (existence check)
                        match = Regexp.new('')
                    end
                    attrs << [name, match]
                end
            end
            # If there's nothing else in the statement, return this selector.
            selector = Selector.new(tag_name, attrs, alt, &depends)
            return selector if parts[5].empty?

            # Create a compound selector based on the remainder of the statement.
            # This is also why we need the factory and can't call new directly.
            return case parts[5][0]
            when ?,
                # Alternative selector: second statement is alternative to the first one
                Selector.create(parts[5][1..-1], selector)
            when ?+
                # Sibling selector: second statement is returned that will match node
                # followed by previous sibling node based on first statement
                Selector.create(parts[5][1..-1]) do |node|
                    node.previous_element and selector.match(node.previous_element)
                end
            when ?>
                # Child selector: second statement is returned that will match node
                # followed by parent node based on the first statement
                Selector.create(parts[5][1..-1]) do |node|
                    node.parent? and selector.match(node.parent)
                end
            else
                # Descendant selector: second statement is returned that will match node
                # followed by ascendant node based on the first statement
                Selector.create(parts[5]) do |node|
                    parent = node.parent
                    match = false
                    while parent
                        break if match = selector.match(parent)
                        parent = parent.parent
                    end
                    match
                end
            end
        end

        # Creates a new selector for the given class name.
        def Selector.for_class(cls)
            Selector.new(nil, [["class", Regexp.new('\b' + cls + '\b')]])
        end

        # Identifies all matching nodes.
        def match(node)
            # Match node if no element name or element name same as node name
            match = (!@tag_name or @tag_name == node.name)
            # No match if one of the attribute matches failed
            for attr in @attrs
                if attr[1] !~ node.attributes[attr[0]]
                    match = false
                    break
                end
            end
            # If the node did not match, but we have an alternative match
            # (x+y), apply the alternative match instead
            return @alt.match(node) if not match and @alt
            # If the node did match, but depends on another match (parent,
            # sibling, etc), apply the dependent match as well
            return @depends.call(node) if match and @depends
            match
        end

        def inspect
            stmt = @tag_name ? @tag_name : '';
            @attrs.each do |attr|
                stmt += "[#{attr[0]}"
                stmt += "~=#{$1}" if attr[1].source =~ /^\\b(.*)\\b$/
                stmt += "=#{$1}" if attr[1].source =~ /^\^(.*)\$$/
                stmt += "|=#{$1}" if attr[1].source =~ /^\^[^$]*$/
            end
            stmt += ']'
            stmt += ',' + @alt.inspect if @alt
            stmt
        end

    end


    # Implements an extractor using a simple expression format.
    #
    # For more information see MicroformatParser.extractor.
    class Extractor

        # :stopdoc:

        # Parse each extractor into three parts:
        # $1 function name (excluding parentheses)
        # $2 element name
        # $3 attribute name (including leading @)
        # If a match is found the result is either $1, or $2 and/or $3
        REGEX = /^(\w+)\(\)|([A-Za-z][A-Za-z0-9_\-:]*)?(@[A-Za-z][A-Za-z0-9_\-:]*)?$/

        # :startdoc:

        def initialize(context, statement)
            statement.strip!
            @extracts = []
            # Break the statement into multiple extraction rules, separated by |.
            statement.split('|').each do |extract|
                parts = REGEX.match(extract)
                if parts[1] then
                    # Function. Find a method in the context object (the rule class),
                    # report an error is not found.
                    begin
                        @extracts << context.method(parts[1]) # context.
                    rescue NameError=>error
                        raise InvalidExtractorException, error.message, error.backtrace
                    end
                elsif parts[2] and parts[3]
                    # Apply only if element of this type, and extract the named attribute.
                    attr_name = parts[3][1..-1]
                    @extracts << proc { |node| node.attributes[attr_name] if node.name == parts[2] }
                elsif parts[2]
                    # Apply only if element of this type, and extract the text value.
                    @extracts << proc { |node| text(node) if node.name == parts[2] }
                elsif parts[3]
                    # Extract the named attribute.
                    attr_name = parts[3][1..-1]
                    @extracts << proc { |node| node.attributes[attr_name] }
                else
                    raise InvalidExtractorException, "Invalid extraction statement"
                end
            end
            raise InvalidExtractorException, "Invalid (empty) extraction statement" if @extracts.size == 0
        end

    public
        # Extracts a value from the node based on the extractor expression.
        def extract(node)
            # Iterate over all extraction rules, returning the first value.
            value = nil
            @extracts.each do |extract|
                value = extract.call(node)
                break if value
            end
            value
        end

        def inspect
            @extracts.join('|')
        end

    end

    DEFAULT_EXTRACTOR = Extractor.new(self, "abbr@title|a@href|text()")

    # Base class for InvalidSelectorException and InvalidExtractorException.
    # Also raised when a rule is defined with invalid arguments.
    class InvalidRuleException < Exception
    end

    # Raised to indicate an invalid selector statement.
    class InvalidSelectorException < InvalidRuleException
    end

    # Raised to indicate an invalid extractor statement.
    class InvalidExtractorException < InvalidRuleException
    end


end


# A parser for several microformats.
#
# Defines rules for the following attributes:
# tags:: A list of tags based on relTag (array of String)
# events:: A list of events based on hCalendar (array of HCalendar)
#
# For example:
#   content = Microformats.parse(doc)
#   puts "Tagged with " + content.tags.join(", ") if content.tags
class Microformats

    include MicroformatParser

    # Parses the fields of an hCalendar element.
    #
    # Defines rules for the following attributes:
    # dtstart:: The event's start date/time (a Time object)
    # dtend:: The event's end date/time (a Time object)
    # summary:: The event's summary (text value)
    # description:: The event's description (XML node)
    # url:: The event's URL (string)
    #
    # For example:
    #   content = Microformats.parse(doc)
    #   content.events.each do |event}
    #     put "Event on " + event.dtstart
    #   end
    class HCalendar

        include MicroformatParser

        extractor :dt_extractor do |node|
            value = node.attributes['title'] if node.name == 'abbr'
            value = text(node) unless value
            value ? Time.parse(value) : nil
        end

        rule_1 :dtstart, nil, :dt_extractor
        rule_1 :dtend, nil, :dt_extractor
        rule_1 :summary, nil, :text
        rule_1 :description, nil, :xml
        rule_1 :url, nil, "a@href"
        rule_1 :location, nil, :xml
        rule_1 :contact, nil, :xml

    end

    rule :tags, "a[rel~=tag]", "text()"
    rule :events, ".vevent", HCalendar

end
