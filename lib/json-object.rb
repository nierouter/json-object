require 'json'
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
  def each
    (@array || @hash.to_a).each { |i|
      yield i if block_given?
    }
  end
  def is_array?; @hash.nil?; end
  def is_hash?; @array.nil?; end
  def to_s mode=nil
   if :pretty == mode
     JSON.pretty_generate(@source)
   else
     JSON.generate(@source)
   end
  end
  def method_missing indexer, arg=nil
    if @array
      if arg
        if /\A<<\z/ =~ indexer.to_s
          @source << arg
          if arg.is_a?(Array) || arg.is_a?(Hash)
            @array << JsonObject.new(arg)
          else
            @array << arg
          end
          @array
        elsif /\A\+\z/ =~ indexer.to_s
          if arg.is_a?(JsonObject)
            JsonObject.new(@source + arg.source)
          else
            JsonObject.new(@source + arg)
          end
        elsif /\A(\d+)=\z/ =~ indexer.to_s
          indexer = $1.to_i
          @source[indexer] = arg
          if arg.is_a?(Array) || arg.is_a?(Hash)
            @array[indexer] = JsonObject.new(arg)
          else
            @array[indexer] = arg
          end
          @array[indexer]
        end
      elsif /\A(\d+)=\z/ =~ indexer.to_s
        @array[indexer]
      else
        @array.method(indexer.to_sym).call
      end
    elsif @hash
      if /\A(.+)=\z/ =~ indexer.to_s && arg
        indexer = $1.to_sym
        @source[indexer] = arg
        if arg.is_a?(Array) || arg.is_a?(Hash)
          @hash[indexer] = JsonObject.new(arg)
        else
          @hash[indexer] = arg
        end
      end
      @hash[indexer]
    else
      raise NoMethodError.new("undefined method `#{indexer}' for #{source}", indexer)
    end
  end
end
