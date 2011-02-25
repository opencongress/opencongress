module ActsAsSolr
  class LazyDocument
    attr_reader :id, :clazz
    
    def initialize(id, clazz)
      @id = id
      @clazz = clazz
    end
  
    def method_missing(name, *args)
      unless @__instance
        @__instance = @clazz.find(@id)
      end
      
      @__instance.send(name, *args)
    end
  end
end