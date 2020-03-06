class String
  def snakeify
    self
    .split(/\W/).reject { |s| s.nil? || s.length.zero? }
    .map(&:downcase)
    .join("_")
    .to_s
  end

  def camelify(initialCap: false)
    self
    .split(/\W/).reject { |s| s.nil? || s.length.zero? }
    .map(&:capitalize).tap do |parts|
      parts.first.downcase! unless initialCap
    end
    .join
    .to_s
  end
end

