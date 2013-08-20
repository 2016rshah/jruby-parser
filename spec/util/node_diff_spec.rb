require_relative '../helpers'
import org.jrubyparser.util.diff.SequenceMatcher
import org.jrubyparser.util.diff.Change

describe org.jrubyparser.util.diff.SequenceMatcher do

  before(:each) do
    SequenceMatcher.__persistent__ = true
  end

  it 'should take two nodes at creation' do
    nodeA = parse('a = "a"')
    nodeB = parse('b = "b"')
    sm = SequenceMatcher.new(nodeA, nodeB)
    sm.new_node.should == nodeA
    sm.old_node.should == nodeB
  end

  it 'should calculate the complexity of a node' do
    nodeA = parse("def foo(bar)\n bar\n end\n foo('astring')")
    nodeB = parse('b = "b"')
    sm = SequenceMatcher.new(nodeA, nodeB)
    sm.calc_complexity(nodeA).should == 14
  end


  it 'should call a callback passed in' do
    nodeA = parse('a = "a"')
    nodeB = parse('b = "b"')
    check = false
    sm = SequenceMatcher.new(nodeA, nodeB) do |node|
      check = true
    end
    sm.diff_nodes
    check.should == true
  end

  it 'should diff two Strings of different value' do
    nodeA = parse("'The rain in Spain falls mainly on the plain. -- My Fair Lady'")
    nodeB = parse("'The life of the wife is ended by the knife. -- Stewie, Family Guy'")
    seqm = SequenceMatcher.new(nodeA, nodeB)
    seqm.diff_nodes.size.should == 1
  end

  it 'should diff fcalls' do
    nodeA = parse('a()')
    nodeB = parse('b()')
    seqm = SequenceMatcher.new(nodeA, nodeB)
    seqm.diff_nodes.size.should == 1
  end

  it 'should diff massgnnodes' do
    nodeA = parse('ninjas.each {|x,y,z| puts "#{x}, #{y}, #{z}"}')
    nodeB = parse('ninjas.each {|m,n,o| puts "#{x}, #{y}, #{z}"}')
    seqm = SequenceMatcher.new(nodeA, nodeB)
    seqm.diff_nodes.size.should >= 1


    nodeC = parse('ninjas.each {|m,n,o| puts "#{x}, #{y}, #{z}"}')
    nodeD = parse('ninjas.each {|m| puts "#{x}, #{y}, #{z}"}')
    seqmtoo = SequenceMatcher.new(nodeC, nodeD)
    seqmtoo.diff_nodes.size.should >= 1
  end

  it 'should not diff matching if statements' do
    nodeA = parse("if 1 == 1\nputs 1\nelse\n1\nend")
    nodeB = parse("if 1 == 1\nputs 1\nelse\n1\nend")
    seqm = SequenceMatcher.new(nodeA, nodeB)
    seqm.diff_nodes.size.should == 0
  end

  it 'should diff a changed if statement' do
    nodeA = parse("if 1 == 1\nputs 1\nelse\n1\nend")
    nodeB = parse("if 2 == 2\nputs 1\nelse\n1\nend")
    nodeC = parse("if 2 == 2\nputs 3\nelse\n1\nend")
    nodeD = parse("if 2 == 2\nputs 1\nelse\n2\nend")
    seqm = SequenceMatcher.new(nodeA, nodeB)
    seqm2 = SequenceMatcher.new(nodeB, nodeC)
    seqm3 = SequenceMatcher.new(nodeB, nodeD)
    seqm.diff_nodes.size.should >= 1
    seqm2.diff_nodes.size.should >= 1
    seqm3.diff_nodes.size.should >= 1
  end

end

describe "Change" do
  nodeA = parse("b = 'b'")
  nodeB = parse("b = 'a'")
  change = Change.new(nodeA, 4, nodeB, 4)

  it 'should hold the old node' do
    change.old_node.should == nodeB
  end

  it 'should hold the new node' do
    change.new_node.should == nodeA
  end

  it 'should hold the complexity of the nodes' do
    change.old_cost.should == 4
    change.new_cost.should == 4
    change.total_cost.should == 8
  end
end
