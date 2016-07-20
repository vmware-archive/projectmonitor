class VersionsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  DEFAULT_VERSION = '1'
  VERSION_PATH    = File.join(Rails.root, 'VERSION')

  def show
    render plain: version
  end

  private

  def version
    @@version ||= fetch_version
  end

  def fetch_version
    if File.exists?(VERSION_PATH)
      File.read(VERSION_PATH)
    else
      DEFAULT_VERSION
    end
  end
end
