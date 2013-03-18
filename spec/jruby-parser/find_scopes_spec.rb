$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../lib"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../helpers"
require 'java'
require 'jruby-parser'
require 'parser_helpers'

describe JRubyParser do
  [JRubyParser::Compat::RUBY1_8, JRubyParser::Compat::RUBY1_9].each do |v|
    it "children can ask for the method it is contained in [#{v}]" do
      JRubyParser.parse("def foo; true if false; end").find_node(:defn) do |defn|
        defn.find_node(:true).method_for.should == defn
        defn.find_node(:false).method_for.should == defn
        defn.find_node(:if).method_for.should == defn
      end
    end

    it "children can ask for the iter/block it is contained in [#{v}]" do
      JRubyParser.parse("proc { |a| proc { |b| true } }").find_node(:iter) do |iter1|
        iter1.find_node(:true).innermost_iter.should_not == iter1
        iter1.find_node(:true).outermost_iter.should == iter1
      end
    end
  end
end
