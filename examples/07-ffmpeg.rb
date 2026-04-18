require_relative "support/cli_concat"

puts CLI.build(:ffmpeg)
  .i("input.mp4")
  .vf("scale=1920:1080")
  .c(:v, :libx264)
  .crf(23)
  .preset(:fast)
  .("output.mp4")
  .to_s
# => ffmpeg -i input.mp4 --vf scale=1920:1080 -c v,libx264 --crf 23 --preset fast output.mp4

puts CLI.build(:ffmpeg)
  .i("video.mkv")
  .ss("00:01:30")
  .t("00:00:45")
  .c(:copy)
  .("clip.mkv")
  .to_s
# => ffmpeg -i video.mkv --ss 00:01:30 -t 00:00:45 -c copy clip.mkv

puts CLI.build(:ffmpeg)
  .i("input.mp4")
  .vn(true)
  .ar(44100)
  .ac(2)
  .("output.mp3")
  .to_s
# => ffmpeg -i input.mp4 --vn --ar 44100 --ac 2 output.mp3

puts CLI.build(:ffmpeg)
  .i("input.mp4")
  .r(30)
  .s("1280x720")
  .("output.gif")
  .to_s
# => ffmpeg -i input.mp4 -r 30 -s 1280x720 output.gif
