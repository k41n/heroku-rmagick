class MergesController < ApplicationController
  def new
  end

  def create
    require 'open-uri'
    bucket_name = 'herokumagick'
    file_name = "merge_#{SecureRandom.hex}.png"

    photo1 = Magick::ImageList.new
    photo1.from_blob(open(params[:url1]).read)

    photo2 = Magick::ImageList.new
    photo2.from_blob(open(params[:url2]).read)


    result = Magick::Image.new(photo1.columns + photo2.columns, [photo1.rows, photo2.rows].max) { self.background_color = 'red' }
    result = result.composite!(photo1, 0, 0, Magick::OverCompositeOp)
    result = result.composite!(photo2, photo1.columns, 0, Magick::OverCompositeOp)

    AWS.config({
      access_key_id: App.aws_access_key,
      secret_access_key: App.aws_secret_key,
      region: 'us-east-1'
    })

    # Get an instance of the S3 interface.
    s3 = AWS::S3.new

    # Upload a file.
    key = File.basename(file_name)
    s3.buckets[bucket_name].objects[key].write(:data => result.to_blob{ self.format = 'jpg' })
    puts "Uploading file #{file_name} to bucket #{bucket_name}."
    @url = s3.buckets[bucket_name].objects[key].url_for(:read)
  end

private
  def download_file(url)
    host = URI.parse(url).host.downcase
    path = URI.parse(url).path
    tmp  = File.join(Dir.tmpdir, Digest::SHA1.hexdigest(url))

    Net::HTTP.start(host) do |http|
      begin
        file = open(tmp, 'wb')
        http.request_get(path) do |response|
          response.read_body do |segment|
            file.write(segment)
          end
        end
      ensure
        file.close
      end
    end
    tmp
  end
end