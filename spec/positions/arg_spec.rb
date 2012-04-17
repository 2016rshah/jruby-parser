$LOAD_PATH.unshift File.dirname(__FILE__) + "/../helpers"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../lib"
require 'jruby-parser'
require 'parser_helpers'
require 'node_helpers'

describe Parser do
  [1.8, 1.9].each do |v|
    it "parses a 0-arg method sans parens [#{v}]" do
      parse("def foo\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 11)
        defn.args_node.should have_arg_counts(0, 0, false, false)
      end
    end

    it "parses a 0-arg method with parens [#{v}]" do
      parse("def foo()\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 13)
        defn.args_node.should have_arg_counts(0, 0, false, false)
      end
    end

    it "parses a 1-arg method sans parens [#{v}]" do
      parse("def foo a\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 13)
        defn.args_node.should have_arg_counts(1, 0, false, false)
        defn.args_node.pre.tap do |pre|
          pre.should have_position(0, 0, 8, 9)
          pre[0].should have_name_and_position("a", 0, 0, 8, 9)
        end
      end
    end

    it "parses a 1-arg method with parens [#{v}]" do
      parse("def foo(a)\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 14)
        defn.args_node.should have_arg_counts(1, 0, false, false)
        defn.args_node.pre.tap do |pre|
          pre.should have_position(0, 0, 8, 9)
          pre[0].should have_name_and_position("a", 0, 0, 8, 9)
        end
      end
    end

    it "parses a 2-arg method sans parens [#{v}]" do
      parse("def foo a, b\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 16)
        defn.args_node.should have_arg_counts(2, 0, false, false)
        defn.args_node.pre.tap do |pre|
          pre.should have_position(0, 0, 8, 12)
          pre[0].should have_name_and_position("a", 0, 0, 8, 9)
          pre[1].should have_name_and_position("b", 0, 0, 11, 12)
        end
      end
    end

    it "parses a 2-arg method with parens [#{v}]" do
      parse("def foo(a, b)\nend\n", v).find_node(:defn) do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 17)
        defn.args_node.should have_arg_counts(2, 0, false, false)
        defn.args_node.pre.tap do |pre|
          pre.should have_position(0, 0, 8, 12)
          pre[0].should have_name_and_position("a", 0, 0, 8, 9)
          pre[1].should have_name_and_position("b", 0, 0, 11, 12)
        end
      end
    end

    it "parses a 1-optarg method sans parens [#{v}]" do
      parse("def foo a=1\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 15)
        defn.args_node.should have_arg_counts(0, 1, false, false)
        lasgn = defn.args_node.optional.find_node(:localasgn)
        lasgn.should have_name_and_position("a", 0, 0, 8, 11)
      end
    end

    it "parses a 1-optarg method with parens [#{v}]" do
      parse("def foo(a=1)\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 16)
        defn.args_node.should have_arg_counts(0, 1, false, false)
        lasgn = defn.args_node.optional.find_node(:localasgn)
        lasgn.should have_name_and_position("a", 0, 0, 8, 11)
      end
    end

    it "parses a rest-arg method sans parens [#{v}]" do
      parse("def foo *a\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 14)
        defn.args_node.should have_arg_counts(0, 0, true, false)
      end
    end

    it "parses a rest-arg method with parens [#{v}]" do
      parse("def foo(*a)\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 15)
        defn.args_node.should have_arg_counts(0, 0, true, false)
      end
    end

    it "parses a block-arg method sans parens [#{v}]" do
      parse("def foo &a\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 14)
        defn.args_node.should have_arg_counts(0, 0, false, true)
      end
    end

    it "parses a block-arg method with parens [#{v}]" do
      parse("def foo(&a)\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 15)
        defn.args_node.should have_arg_counts(0, 0, false, true)
      end
    end

    it "parses a mixed-arg method sans parens [#{v}]" do
      parse("def foo a, b, c = 1, *d\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 27)
        defn.args_node.should have_arg_counts(2, 1, true, false)
      end
    end

    it "parses a mixed-arg method with parens [#{v}]" do
      parse("def foo(a, b, c = 1, *d)\nend\n", v).find_node(:defn).tap do |defn|
        defn.should have_name_and_position("foo", 0, 1, 0, 28)
        defn.args_node.should have_arg_counts(2, 1, true, false)
      end
    end
  end
end
