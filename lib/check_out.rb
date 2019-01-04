class CheckOut

  def initialize(rules)
    @rules = rules
    @item_list = {}
    @on_special_list = {}
  end

  def scan(item)
    # item_list occurences of products
    @item_list[item].nil?  ? @item_list[item] = 1 : @item_list[item] += 1

    # if qty matches requred quantity save in on_special_list list
    if find_rule(item).has_key?(:special) && @item_list[item] == required_quantity(item)
      @on_special_list[item].nil?  ? @on_special_list[item] = 1 : @on_special_list[item] += 1
      @item_list.delete(item)
    end
  end

  def total
    sum = 0

    # process regular orders
    @item_list.keys.each { |key| sum += @item_list[key] * unit_price(key) }

    # process on_special_list
    @on_special_list.keys.each { |key| sum += @on_special_list[key] * special_price(key) }

    sum
  end

  private

    def find_rule(key)
       @rules.find { |i| i[:product] == key }
    end

    def special_price(key)
      find_rule(key)[:special].split(' ').last.to_i
    end

    def unit_price(key)
       find_rule(key)[:unit]
    end

    def required_quantity(key)
      find_rule(key)[:special].split(' ').first.to_i
    end
end
