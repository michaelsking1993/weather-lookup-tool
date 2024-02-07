# frozen_string_literal: true

class ApplicationService
  include ActiveSupport::Rescuable
  include Rails.application.routes.url_helpers

  def self.call(*args)
    new(*args).call
  end

  def call
    raise NotImplementedError
  end
end
