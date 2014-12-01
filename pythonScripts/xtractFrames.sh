for f in *.flv
      do 
      ffmpeg -i "$f" -r 1 -an "frames/${f%}_%d.jpeg"
done
