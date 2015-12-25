module Reality
  class Measure
    %w[unit].each{|mod| require_relative "measure/#{mod}"}
    
    attr_reader :amount, :unit
    
    def initialize(amount, unit)
      @amount, @unit = amount, Unit.parse(unit)
    end

    def <=>(other)
      check_compatibility!(other)
      
      amount <=> other.amount
    end

    def -@
      self.class.new(-amount, unit)
    end

    def +(other)
      check_compatibility!(other)

      self.class.new(amount + other.amount, unit)
    end

    def -(other)
      self + (-other)
    end

    def *(other)
      case other
      when Numeric
        self.class.new(amount * other, unit)
      when self.class
        self.class.new(amount * other.amount, unit * other.unit)
      else
        fail ArgumentError, "Can't multiply by #{other.class}"
      end
    end

    def /(other)
      case other
      when Numeric
        self.class.new(amount / other, unit)
      when self.class
        un = unit / other.unit
        un.scalar? ?
          amount / other.amount :
          self.class.new(amount / other.amount, un)
      else
        fail ArgumentError, "Can't divide by #{other.class}"
      end
    end

    def **(num)
      (num-1).times.inject(self){|res| res*self}
    end

    include Comparable

    def to_s
      [amount, unit].join
    end

    def inspect
      "#<#{self.class}(#{amount} #{unit})>"
    end

    private

    def check_compatibility!(other)
      unless other.kind_of?(self.class) && other.unit == unit
        fail ArgumentError, "#{self} incompatible with #{other}"
      end
    end
  end

  def Reality.Measure(*arg)
    Measure.new(*arg)
  end
end