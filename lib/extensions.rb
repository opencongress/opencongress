class Array
  def shuffle
    clone.shuffle!
  end

  def shuffle!
    size.downto(2) do |i|
      r = rand(i)
        tmp = self[i-1]
      self[i-1] = self[r]
      self[r] = tmp
    end
    self
  end
end

