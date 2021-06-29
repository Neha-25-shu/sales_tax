class ApplicationModel
  def self.has_many(*args)
    define_method args[0].to_sym do
      klass = args[0][0,7]
      klass = Object.const_get(klass.capitalize)
      ObjectSpace.each_object(klass).select {|x| x.order_id == self.object_id }
    end
  end
end

class Order < ApplicationModel
  has_many :products
  def initialize
  end
  
  def add(item, quantity, price, order_id, exempted, imported)
    Product.new(item,quantity,price ,order_id, exempted, imported)
  end


  def calculation_tax(lists)
    sales_tax = 0
    lists.each do |list|
      exempt = list.exempted
      import = list.imported
      item = list.item
      price = list.price
      if exempt == false && import == true
        sales_tax = sales_tax + list.price * 0.15
      elsif exempt == true && import == true
        sales_tax = sales_tax + list.price * 0.05
      elsif exempt == false && import == false
        sales_tax =  sales_tax + list.price * 0.10
      elsif exempt == true && import == false
        sales_tax = sales_tax + 0
      end
    end
    sales_tax.round(2)
  end

  def total_price(lists)
    total_cost = 0 
    lists.each do |list|
      total_cost+=list.price
    end
    total_cost
  end	

  def total(to_tax,to_price)
    total = to_tax + to_price
    total.round(2)
  end

  def recipt(lists)
    lists.each do |list|
      item = list.item
      price = list.price
      puts "1 #{item} : #{price}"
    end
    tax = calculation_tax(lists)
    price = total_price(lists)
    puts "Sales Taxes: #{tax}"
    total = total(tax , price)
    puts "Total : #{total}"
  end
end

class Product < ApplicationModel
  attr_accessor :item , :price , :quantity , :order_id ,:imported , :exempted
  def initialize(item, quantity, price, order_id, exempted, imported)
    @item = item
    @price = price
    @quantity = quantity
    @order_id = order_id
    @imported = imported
    @exempted = exempted
  end
 
end



o1 = Order.new

o1.add("chocolate bar",1,0.85, o1.object_id , true, false)
o1.add("music CD",1,14.99, o1.object_id , false, false)
o1.add("book",1,12.49, o1.object_id ,true , false )

# o1.add("imported bottle of perfume at",1,47.50, o1.object_id , false,true)
# o1.add("imported box of chocolates at",1,10.00, o1.object_id , true, true)

# o1.add("box of imported chocolates at",1,11.25, o1.object_id , true, true)
# o1.add("packet of headache pills at",1,9.75, o1.object_id , true, false)
# o1.add("bottle of perfume at",1,18.99, o1.object_id , false, false)
# o1.add("imported bottle of perfume at",1,27.99, o1.object_id , false,true)


lists = o1.products
to_tax = o1.calculation_tax(lists)
to_price = o1.total_price(lists)
o1.total(to_tax,to_price)
o1.recipt(lists)
