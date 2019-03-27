require 'json'

Ancestors = {}
def build_ancestors x={}, *n
  k = n.empty? ? 'Object' : n.join('::')
  k.slice!(/^(Class::|Module::Class::|Module::)/)
  Ancestors[k] = x[:a].map(&:to_s)
  x[:s]&.each { |m, y| build_ancestors y, *n, m }
end

@ver = 0
Versions = {}
def build_versions x={}, *n
  k = n.empty? ? 'Object' : n.join('::')
  k.slice!(/^(Class::|Module::Class::|Module::)/)
  o = (Versions[k] ||= { i: {}, c: {}, a: {}, _: @ver })
  x[:i]&.each { |i| o[:i][i.to_sym] ||= @ver }
  x[:c]&.each { |c| o[:c][c.to_sym] ||= @ver }
  x[:i]&.grep(/^\w+=/) { |a| o[:a][a[0..-2].to_sym] ||= @ver }
  x[:s]&.each { |m, y| build_versions y, *n, m }
end

Dir.glob('?.ri') do |f|
  @ver = f[/\d/].to_i
  a = open(f) { |f| Marshal.load f }
  build_ancestors a
  build_versions a
end

open 'ancestors.ri', 'wb' do |f|
  Marshal.dump Ancestors, f
end

open 'ancestors.json', 'w' do |f|
  f.write JSON.generate Ancestors
end

open 'versions.ri', 'wb' do |f|
  Marshal.dump Versions, f
end

open 'versions.json', 'w' do |f|
  f.write JSON.generate Versions
end
