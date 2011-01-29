module OCLogger
  def OCLogger.log(message)
    puts "[#{Time.now}] #{message}"
  end
end
