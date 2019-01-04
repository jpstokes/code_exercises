class CodeExercise1
  RANGE = (-100000..100000).to_a
  def smallest_absent_int(ary)
    num_array = (RANGE - ary).sort
    num_array.find { |i| i > 0 }
  end
end
