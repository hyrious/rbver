def dig x=Object, v={}, me=method(:dig)
  return if v.key? x
  v[x] = 1
  if x.kind_of? Module
    # s: x::child-mod
    # t: x::constants
    # i: instance methods
    # c: class methods
    # a: ancestors
    ret = {
      :s => {}, :t => [], :a => x.ancestors.map(&:to_s),
      :i => x.instance_methods(false),
      :c => x.singleton_methods(false)
    }
    if [Module, Class, Object].include? x
      ret[:i] = (ret[:i] + x.private_instance_methods(false)).uniq
    end
    x.constants.each { |e|
      begin
        y = dig x.const_get(e), v
        if y.nil?
          ret[:t] << e
        else
          ret[:s][e] = y
        end
      rescue NameError
      rescue RuntimeError
      end
    }
    if ret[:i].include?(:dig) and x.method(:dig) == me
      ret[:i].delete :dig
    end
    [:s, :t, :i, :c, :a].each { |e|
      ret.delete e if ret[e].empty?
    }
    ret
  end
end

open 'dig.ri', 'wb' do |f|
  Marshal.dump dig, f
end
