class JsonObject
  attr_reader :source
  def initialize object
    @source = object
    if object.is_a? Array
      @array = []
      object.each { |item|
        if item.is_a?(Array) || item.is_a?(Hash)
          @array << JsonObject.new(item)
        else
          @array << item
        end
      }
    elsif object.is_a? Hash
      @hash = {}
      object.to_a.each { |key, value|
        if value.is_a?(Array) || value.is_a?(Hash)
          @hash[key] = JsonObject.new(value)
        else
          @hash[key] = value
        end
      }
    else
      raise ArgumentError.new("#{object} is neither Array nor Hash.")
    end
  end
  def is_array?; @hash.nil?; end
  def is_hash?; @array.nil?; end
  def method_missing indexer, arg=nil
    if @hash.nil?
      @array[$1.to_i] = arg if /\A(\d+)=\z/ =~ indexer.to_s && arg
      @array[indexer]
    elsif @array.nil?
      @hash[$1.to_sym] = arg if /\A(.+)=\z/ =~ name.to_s && arg
      @hash[name]
    else
      raise NoMethodError.new("undefined method `#{indexer}' for #{source}", indexer)
    end
  end
end
