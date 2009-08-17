module FleskPlugins

  # A CAPTCHA challenge where an image with text is
  # generated. A human can read the text with relative
  # ease, while most robots can not. There are accessibility
  # problems with this challenge, though, as people
  # with reduced or no vision are unlikely to pass the test.
  class CaptchaImageChallenge < CaptchaChallenge
  
    register_name :image

    WORDS = 'gorilla costume, superman, chuck norris, xray vision, ahoy me hearties,
         chunky bacon, latex, rupert murdoch, clap your hands, year 2000, disco rocks,
         sugar coated, staple my ears, rastafarian, airbus a380, good old days'.split(/,\s+/)
    DEFAULT_DIR = 'captcha'#public/images/captcha
    WRITE_DIR = File.join(RAILS_ROOT, 'public', 'images')
    DEFAULT_FILETYPE = 'jpg'

    attr_reader :image
    attr_accessor :string, :dir, :filename, :filetype


    # Creates an image challenge. It takes an optional
    # hash parameter with the following options:
    # 
    # - :ttl - Time to live. The challenge expires after +ttl+ seconds.
    #   Default is 1200 (20 minutes).
    # - :string - The text to generate in the image. This option probably
    #   has limited use.
    # - :dir - The directory in which to store the generated image.
    # - :filename - The filename to use for the generated image (without the
    #   extension like png or jpg). Default is to generate a random filename.
    # - :filetype - The file extension (and file type) to use for the generated
    #   image. Default is "jpg".
    def initialize(options = {})
      super
      
      options.reverse_merge!(
        :string => config['words'] ? config['words'][rand(config['words'].size)] : WORDS[rand(WORDS.size)],
        :dir => config['default_dir'] || DEFAULT_DIR,
        :filetype => config['default_filetype'] || DEFAULT_FILETYPE
      ).symbolize_keys!

      self.string = options[:string]
      self.dir = options[:dir]
      self.filetype = options[:filetype]
      self.filename = options[:filename] || generate_filename

      write_to_store
    end


    # Generates the image. Takes an optional parameter containing
    # options used when generating the image. These are:
    # 
    # - :fontsize - The font size of the generated text in pt. Default 25.
    # - :padding - The padding put around the text (in px). Should not
    #   be too small if the text is rotated. Default is 20.
    # - :color - Text colour. Default is '#000000' (black).
    # - :background - Background colour. Default is '#ffffff' (white).
    # - :fontweight - Font weight of generated text. Can be "normal"
    #   or "bold". Default is "bold".
    # - :rotate - Whether the text should be rotated or not.
    #   Default is +true+.
    # - :font - The font to use. Can be a font name or the full path
    #   to a font file.
    def generate(options = {})
      options.reverse_merge!(
        :fontsize => 25,
        :padding => 20,
        :color => '#000',
        :background => '#fff',
        :fontweight => 'bold',
        :rotate => true,
        :font => config['font']
      ).symbolize_keys!

      options[:fontweight] = case options[:fontweight]
        when 'bold' then 700
        else 400
      end
      
      text = Magick::Draw.new
      text.pointsize = options[:fontsize]
      text.font_weight = options[:fontweight]
      text.fill = options[:color]
      text.gravity = Magick::CenterGravity
      text.font = options[:font] if options[:font]
      
      #rotate text 5 degrees left or right
      text.rotation = (rand(2)==1 ? 5 : -5) if options[:rotate]
      
      metric = text.get_type_metrics(self.string)

      #add bg
      canvas = Magick::ImageList.new
      canvas << Magick::Image.new(metric.width+options[:padding], metric.height+options[:padding]){
        self.background_color = options[:background]
      }

      #add text
      canvas << Magick::Image.new(metric.width+options[:padding], metric.height+options[:padding]){
        self.background_color = 'transparent'
      }.annotate(text, 0, 0, 0, 0, self.string).wave(5, 50)

      #add noise
      canvas << Magick::Image.new(metric.width+options[:padding], metric.height+options[:padding]){
        p = Magick::Pixel.from_color(options[:background])
        p.opacity = Magick::MaxRGB/2
        self.background_color = p
      }.add_noise(Magick::LaplacianNoise)

      self.image = canvas.flatten_images.blur_image(1)
    end


    # Writes image to file. 
    def write(dir = self.dir, filename = self.filename)
      self.image.write(File.join(WRITE_DIR, dir, filename))
    end


    # Determine if the supplied +string+ matches
    # that used when generating the image.
    def correct?(string)
      string.downcase == self.string.downcase
    end


    # The full path to the image file, relative
    # to <tt>public/images</tt>.
    def file_path
      File.join(dir,filename)
    end



  class << self
  
    # Deletes old image files. Also calls CaptchaChallenge.prune
    def prune
      store.transaction{
        if store.root?(:captchas)
          store[:captchas].each_with_index{|c,i|
            if c.is_a?(self.class) && c.expired?
              if File.exists?(File.join(WRITE_DIR, c.file_path))
                begin
                  File.unlink(File.join(WRITE_DIR, c.file_path))
                rescue Exception
                end
              end
            end
          }
        end
      }
      super
    end#prune
  end#class << self
    


  private

    def generate_filename #:nodoc:
      self.id+'.'+self.filetype
    end


    def image=(i) #:nodoc:
      @image = i
    end


  end#class CaptchaImageChallenge

end#module FleskPlugins