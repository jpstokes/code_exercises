class CheckOut

  def initialize(rules)
    @rules = rules
    @count = {}
    @specials = {}
  end

  def scan(item)
    # count occurences of products
    if @count[item].nil?
      @count[item] = 1
    else
      @count[item] += 1
    end

    # if qty matches requred quantity save in specials list
    if find_rule(item).has_key?(:special) && @count[item] == required_quantity(item)
      if @specials[item].nil?
        @specials[item] = 1
      else
        @specials[item] += 1
      end
      @count.delete(item)
    end
  end

  def total
    sum = 0

    # process regular orders
    @count.keys.each do |key|
      sum += @count[key] * unit_price(key)
    end

    # process specials
    @specials.keys.each do |key|
      sum += @specials[key] * special_price(key)
    end

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
