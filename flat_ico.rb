require 'json'

ontology = ARGV[0]
ontology = JSON.parse(File.read(ontology))
input = ARGV[1]

`
  rm -fr /tmp/ico_i && mkdir /tmp/ico_i
  rm -fr /tmp/ico && mkdir /tmp/ico
`

Dir.chdir(input)
Dir.glob('**/*.svg').each{ |icon|
    superclass = icon.gsub('.svg', '').split('/')[0]
    out = icon.gsub('.svg', '').gsub('/', '-')
    puts([icon, superclass, out].inspect)

    wh = `identify -format '%w-%h' "#{icon}"`
    w, h = wh.split('-').map(&:to_f)

    resize = h > w ? '-h' : '-w'

    out_p = "#{out}•.svg"
    `
      rsvg-convert --keep-aspect-ratio #{resize} 11 -f svg "#{icon}" -o "/tmp/ico/#{out_p}"
      sed -i 's/fill="[^"]*"/fill="rgb(30%,30%,30%)"/g' "/tmp/ico/#{out_p}"
    `

    color_fill = ontology['superclass'][superclass]['color_fill']
    color_line = ontology['superclass'][superclass]['color_line']

    out_b = "#{out}◯.svg"
    out_w = "#{out}⬤.svg"
    `
      rsvg-convert --keep-aspect-ratio #{resize} 17 -f svg "#{icon}" -o "/tmp/ico_i/#{out_b}"
    `

    wh = `identify -format '%w-%h' "/tmp/ico_i/#{out_b}"`
    w, h = wh.split('-').map(&:to_f)
    x = (30 - w) / 2
    y = (30 - h) / 2

    File.new("/tmp/ico/#{out_b}", 'w').write(
      File.read('../container.svg')
        .gsub('<g transform="translate(1,1)"></g>', '<g transform="translate(1,1)">' + File.readlines("/tmp/ico_i/#{out_b}")[2..-2].join + '</g>')
        .gsub(/fill="[^"]*"/, 'fill="rgb(30%,30%,30%)"')
        .gsub('translate(1,1)', "translate(#{x},#{y})")
        .gsub('#ff0000', color_line)
        .gsub('#00ff00', '#ffffff')
    )

    File.new("/tmp/ico/#{out_w}", 'w').write(
      File.read('../container.svg')
        .gsub('<g transform="translate(1,1)"></g>', '<g transform="translate(1,1)">' + File.readlines("/tmp/ico_i/#{out_b}")[2..-2].join + '</g>')
        .gsub(/fill="[^"]*"/, 'fill="#FFFFFF"')
        .gsub('translate(1,1)', "translate(#{x},#{y})")
        .gsub('#00ff00', color_fill)
        .gsub('#ff0000', '#ffffff')
    )
}
