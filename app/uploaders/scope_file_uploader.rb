require "image_processing/mini_magick"

include ImageProcessing::MiniMagick

class ScopeFileUploader < Shrine
  plugin :store_dimensions
  plugin :processing
  plugin :default_url
  plugin :validation_helpers
  plugin :remove_invalid

end
