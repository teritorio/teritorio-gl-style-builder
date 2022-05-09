require 'json'

ontology = ARGV[0]
ontology = JSON.parse(File.read(ontology))
prefix_in = ARGV[1]
prefix_out = ARGV[2]

class_set = []


ontology_ids = ontology['superclass'].transform_values{ |superclass|
  superclass['class'].transform_values{ |classes|
    classes['subclass']&.keys
  }
}

mv = ontology_ids.collect{ |superclass_id, superclass|
  class_set << "#{prefix_out}/#{superclass_id}"
  mv = superclass.collect{ |classs_id, classes|
    subclass = if classes
      class_set << "#{prefix_out}/#{superclass_id}/#{classs_id}"
      classes.collect{ |subclass_id|
        file_in = "#{prefix_in}/#{subclass_id}.svg"
        file_out = "#{prefix_out}/#{superclass_id}/#{classs_id}/#{subclass_id}.svg"
        if File.exist?(file_in)
          "mv #{file_in} #{file_out}"
        else
          warn "MISSING #{file_in} -> #{file_out}"
        end
      }
    end || []

    file_in = "#{prefix_in}/#{classs_id}.svg"
    file_out = "#{prefix_out}/#{superclass_id}/#{classs_id}.svg"
    if File.exist?(file_in)
      subclass << "mv #{file_in} #{file_out}"
    elsif !classes
      warn "MISSING #{file_in} -> #{file_out}"
    end
    subclass
  }

  file_in = "#{prefix_in}/#{superclass_id}.svg"
  file_out = "#{prefix_out}/#{superclass_id}.svg"
  if File.exist?(file_in)
    mv += ["mv #{file_in} #{file_out}"]
  else
    warn "MISSING #{file_in} -> #{file_out}"
  end

  mv
}.flatten.compact

puts "mkdir -p #{class_set.join(' ')}"
puts mv
