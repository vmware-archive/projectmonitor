class VersionsController < ApplicationController
  DEFAULT_VERSION = '1'
  VERSION_PATH    = File.join(Rails.root, 'VERSION')

  def show
    render :text => version
  end

  private

  def version
    File.read(VERSION_PATH)
  rescue Errno::ENOENT
    DEFAULT_VERSION
  end
end
