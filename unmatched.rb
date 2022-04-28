require 'csv'
require 'yaml'

style_dir = ARGV[0]
theme = ARGV[1]

csv = CSV.new(STDIN, headers: true).collect{ |row| row.to_h.transform_values{ |v| v == '' ? nil : v } }.collect{ |row|
  row.to_h.slice("#{theme}_superclass", "#{theme}_class", "#{theme}_style", "#{theme}_priority", 'key', 'value', 'extra_tags')
}.select{ |row|
  row["#{theme}_superclass"]
}.collect{ |row|
  [row["#{theme}_superclass"], row["#{theme}_class"] || row['value'], row["#{theme}_class"].nil? ? nil : row['value']]
}.group_by{ |r|
  r[0]
}.transform_values{ |r|
  r.group_by{ |rr|
    rr[1]
  }.transform_values{ |rr|
    rr.collect{ |rrr| rrr[2] }.compact
  }.to_h
}

# svg = Dir['icons/*⬤.svg'].collect{ |s| s.split('/')[-1].reverse.split('-', 3)[-1].reverse }
svg = Dir["#{style_dir}/icons/*⬤.svg"].collect{ |s| s.split('/')[-1].split('⬤')[0] }

csv.each{ |spc, c_|
  svg -= [spc]

  c_.each{ |c, ssc_|
    ssc_.uniq!
    p = [spc, c].join('-')

    puts "Missing class '#{c}'" if ssc_.empty? && !svg.include?(p)

    svg -= [p]

    missing_ssc = []
    ssc_.each{ |ssc|
      p = [spc, c, ssc].join('-')
      #      puts p
      missing_ssc << ssc if !svg.include?(p)
      svg -= [p]
    }
    if !svg.include?(c) && !missing_ssc.empty?
      puts "Missing class '#{c}' or subclasses #{missing_ssc}"
    else
      svg -= [c]
    end
  }
}

puts 'Extras'
puts svg.map{ |s| s.gsub('-', '/') + '.svg' }.sort.join(' ')
