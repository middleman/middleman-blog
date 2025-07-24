# Adds to_toml methods to base Ruby classes used by the generator.
class Object
  def toml_table?
    self.kind_of?(Hash)
  end
  def toml_table_array?
    self.kind_of?(Array) && self.first.toml_table?
  end
end
class Hash
  def to_toml(path = "")
    return "" if self.empty?

    tables = {}
    values = {}
    self.keys.sort.each do |key|
      val = self[key]
      if val.kind_of?(NilClass)
        next
      elsif val.toml_table? || val.toml_table_array?
        tables[key] = val
      else
        values[key] = val
      end
    end

    toml = ""
    values.each do |key, val|
      toml << "#{key} = #{val.to_toml(key)}\n"
    end

    tables.each do |key, val|
      key = "#{path}.#{key}" unless path.empty?
      toml_val = val.to_toml(key)
      unless toml_val.empty?
        if val.toml_table?
          non_table_vals = val.values.reject do |v|
            v.toml_table? || v.toml_table_array?
          end

          # Only add the table key if there are non table values.
          if non_table_vals.length > 0
            toml << "\n[#{key}]\n"
          end
        end
        toml << toml_val
      end
    end

    toml
  end
end
class Array
  def to_toml(path = "")
    unless self.map(&:class).uniq.length == 1
      raise "All array values must be the same type"
    end

    if self.first.toml_table?
      toml = ""
      self.each do |val|
        toml << "\n[[#{path}]]\n"
        toml << val.to_toml(path)
      end
      return toml
    else
      "[" + self.map {|v| v.to_toml(path) }.join(",") + "]"
    end
  end
end
class TrueClass
  def to_toml(path = ""); "true"; end
end
class FalseClass
  def to_toml(path = ""); "false"; end
end
class String
  def to_toml(path = ""); self.inspect; end
end
class Numeric
  def to_toml(path = ""); self.to_s; end
end
class DateTime
  def to_toml(path = "")
    self.rfc3339
  end
end
