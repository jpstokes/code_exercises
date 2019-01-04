require 'minitest/autorun'
require_relative '../lib/code_exercise_1.rb'

class CodeExercise1Test < Minitest::Test
  def setup
    @ce = CodeExercise1.new
  end
  def test_arrays
    # simple cases
    assert_equal(4, @ce.smallest_absent_int([1,2,3]))
    assert_equal(4, @ce.smallest_absent_int([3,2,1]))
    assert_equal(2, @ce.smallest_absent_int([1,3,4]))
    assert_equal(2, @ce.smallest_absent_int([4,1,3]))
    assert_equal(1, @ce.smallest_absent_int([-1,-5]))

    # handle duplicate values
    assert_equal(1, @ce.smallest_absent_int([3,4,4,6,3]))
    assert_equal(2, @ce.smallest_absent_int([-1,0,-1,0,1,0]))

    # larger datasets
    assert_equal(1001, @ce.smallest_absent_int((-1000..1000).to_a))
    assert_equal(101, @ce.smallest_absent_int((-10..100).to_a + (102..150).to_a))
  end
end
