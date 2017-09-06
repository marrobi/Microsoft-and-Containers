echo ${1}
echo ${2}
echo ${3}

dim=$(convert -ping -format '%wx%h' ${1} info:)
echo $dim
convert ${1} \( ${2} -resize $dim \) -transparent white -gravity center -density 150x150 -composite  ${3}