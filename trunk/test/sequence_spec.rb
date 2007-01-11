require 'rubygems'
require 'spec/runner'

dir = File.dirname(__FILE__)
require "#{dir}/spec_helper"

context "A sequence parsing expression with one element" do
  setup do
    @elt = mock("Parsing expression in sequence")
    @sequence = Sequence.new([@elt])
  end
  
  specify "is a kind of CompositeParsingExpression" do
    @sequence.should_be_a_kind_of CompositeParsingExpression
  end
  
  specify "attempts to parse its single element upon a call to parse_at" do
    setup_sequence_element_to_successfully_parse
    @sequence.parse_at(@input, @index, @parser)
  end
  
  specify "returns a SequenceSyntaxNode with the element's parse result as an element if the parse is successful" do
    setup_sequence_element_to_successfully_parse
    result = @sequence.parse_at(@input, @index, @parser)
    result.should_be_a_kind_of SequenceSyntaxNode
    result.elements.should_eql [@elt_result]
  end
  
  specify "returns a parse failure if the parse of an element fails" do
    input = "foo"
    index = 0
    parser = mock("Parser")
  
    @elt.should_receive(:parse_at).with(input, index, parser).and_return(ParseFailure.new(index))
    
    result = @sequence.parse_at(input, index, parser)
  end
  
  def setup_sequence_element_to_successfully_parse
    @input = "foo"
    @index = 0
    @parser = mock("Parser")
    
    @elt_result = mock("First element's parse result")
    @elt_interval = 0...5
    @elt_result.should_receive(:interval).and_return(@elt_interval)
  
    @elt.should_receive(:parse_at).with(@input, @index, @parser).and_return(@elt_result)
  end
end

context "A sequence parsing expression with multiple terminal symbols as elements" do
  setup do
    @elts = ["foo", "bar", "baz"]
    @sequence = Sequence.new(@elts.collect { |w| TerminalSymbol.new(w) })
  end
  
  specify "returns a successful result with correct elements when matching input is parsed" do
    input = @elts.join
    index = 0
    result = @sequence.parse_at(input, index, mock("Parser"))
    result.should_be_success
    (result.elements.collect {|elt| elt.text_value}).should_eql @elts
    result.interval.end.should_equal index + input.size
  end
  
  specify "returns a successful result with correct elements when matching input is parsed when starting at a non-zero index" do
    input = "----" + @elts.join
    index = 4
    result = @sequence.parse_at(input, index, mock("Parser"))
    result.should_be_success
    (result.elements.collect {|elt| elt.text_value}).should_eql @elts
    result.interval.end.should_equal index + @elts.join.size
  end
end

context "A sequence parsing expression with one element and a method defined in its node class" do
  setup do
    @elt = mock("Parsing expression in sequence")
    @sequence = Sequence.new([@elt])
    @sequence.node_class_eval do
      def method
      end
    end
  end
  
  specify "returns a SequenceSyntaxNode with the element's parse result as an element if the parse is successful" do
    setup_sequence_element_to_successfully_parse
    result = @sequence.parse_at(@input, @index, @parser)
    result.should_respond_to :method
  end
  
  def setup_sequence_element_to_successfully_parse
    @input = "foo"
    @index = 0
    @parser = mock("Parser")
    
    @elt_result = mock("First element's parse result")
    @elt_interval = 0...5
    @elt_result.should_receive(:interval).and_return(@elt_interval)
  
    @elt.should_receive(:parse_at).with(@input, @index, @parser).and_return(@elt_result)
  end
end
