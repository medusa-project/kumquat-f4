module MIME

  ##
  # Reopen MIME::Type to add friendly() which exists in 2.x but not in 1.x
  # which is currently required by Yomu.
  #
  class Type

    unless self.respond_to?(:friendly)

      @@friendlies = {
          'application/octet-stream' => 'Binary data',
          'application/pdf' => 'PDF',
          'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'PowerPoint document',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'Word document',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'Excel spreadsheet',
          'application/xml' => 'XML document',
          'audio/aiff' => 'AIFF audio',
          'audio/wave' => 'Wave audio',
          'image/jp2' => 'JPEG2000 image',
          'image/jpeg' => 'JPEG image',
          'image/png' => 'PNG image',
          'image/tiff' => 'TIFF image',
          'image/webp' => 'WebP image',
          'text/html' => 'HTML document',
          'text/plain' => 'Plain text',
          'video/mp4' => 'MPEG-4 video',
          'video/mpeg' => 'MPEG video',
          'video/quicktime' => 'QuickTime video'
      }

      ##
      # @return Human-readable name for the MIME type.
      #
      def friendly
        tmp = @@friendlies[self.content_type]
        tmp ? tmp : self.content_type
      end

    end

  end

end