# frozen_string_literal: true

require "image_processing/mini_magick"

include ImageProcessing::MiniMagick

class ProfileHeaderUploader < Shrine

  plugin :store_dimensions
  plugin :processing
  plugin :default_url
  plugin :validation_helpers
  plugin :remove_invalid
  plugin :determine_mime_type

  process(:store) do |io, _context|
    resize_to_limit!(io.download, 800, 800) if image?(io)
  end

  Attacher.default_url do
    "#{name}/missing.png"
  end

  Attacher.validate do
    validate_mime_type_inclusion %w[image/png image/gif image/jpg image/jpeg]
  end

  protected

  def image?(new_file)
    new_file.content_type.start_with? "image"
  end

end
