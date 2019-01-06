require './test/test_helper.rb'

class CodeExercise1Test < Minitest::Test

  RULES = [{
    product: 'A',
    unit: 50,
    special: '3 for 130'
  }, {
    product: 'B',
    unit: 30,
    special: '2 for 45'
  }, {
    product: 'C',
    unit: 20
  }, {
    product: 'D',
    unit: 15
  }]

  def price(goods)
    co = CheckOut.new(RULES)
    goods.split(//).each { |product| co.scan(product) }
    co.total
  end

  def test_totals
    assert_equal(0, price(""))
    assert_equal(50, price("A"))
    assert_equal(80, price("AB"))
    assert_equal(115, price("CDBA"))
    assert_equal(100, price("AA"))
    assert_equal(130, price("AAA"))
    assert_equal(180, price("AAAA"))
    assert_equal(230, price("AAAAA"))
    assert_equal(260, price("AAAAAA"))
    assert_equal(160, price("AAAB"))
    assert_equal(175, price("AAABB"))
    assert_equal(190, price("AAABBD"))
    assert_equal(190, price("DABABA"))
  end

  def test_incremental
    co = CheckOut.new(RULES)
    assert_equal(0, co.total)
    co.scan("A");  assert_equal(50, co.total)
    co.scan("B");  assert_equal(80, co.total)
    co.scan("A");  assert_equal(130, co.total)
    co.scan("A");  assert_equal(160, co.total)
    co.scan("B");  assert_equal(175, co.total)
  end
end
