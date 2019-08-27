RGSS = !!(ARGV.delete '--rgss')
PREFIX = RGSS ? 'rgss/' : ''

unless %w(versions ancestors).all? { |e| File.exist? "#{PREFIX}#{e}.ri" }
  puts 'run rbver.rb first'
  exit
end

# { "Object" => { i: { func: 87 }, c: {}, a: {}, _: 87 } }
Versions = open "#{PREFIX}versions.ri", 'rb' do |f|
  Marshal.load f
end

def ver num
  if RGSS
    num.to_s
  else
    (num + 100).to_s.chars.join '.'
  end
end

# { "Object" => [ "Object", "Kernel", "BasicObject" ] }
Ancestors = open "#{PREFIX}ancestors.ri", 'rb' do |f|
  Marshal.load f
end

def methver klass, type, name
  Ancestors[klass].each do |k|
    if v = Versions[k][type][name]
      return k, v
    end
  end
  nil
end

require 'rdoc/ri/driver'

if ARGV[0]
  klass, type, meth = RDoc::RI::Driver.allocate.parse_name ARGV[0]
  klass = 'Object' if klass.empty?
  unless Ancestors.key? klass
    puts "don't know class #{klass}"
    exit
  end
  print Ancestors[klass].join(' -> '), " "
  puts ver Versions[klass][:_]
  t = { '.' => :c, '#' => :i }[type]
  if type
    meth = meth.to_sym
    if (k, v = methver klass, t, meth)
      puts "#{type}#{meth} #{ver v}"
    else
      puts "don't know #{ARGV[0]}"
    end
  else
    width, ret = 0, {}
    { '.' => :c, '#' => :i }.each do |type, t|
      Versions[klass][t].each do |f, v|
        k = "#{type}#{f}"
        width = [k.size, width].max
        ret[k] = ver v
      end
    end
    ret.sort_by { |k, v| [v, k] }.each do |k, v|
      puts "%-#{width}s #{v}" % k
    end
  end
else
  puts "usage: #$0 String#unpack1 [--rgss]"
end
