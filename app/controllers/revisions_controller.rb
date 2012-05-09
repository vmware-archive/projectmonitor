class RevisionsController < ApplicationController
  DEFAULT_REVISION = '1'

  def show
    render :text => revision
  end

  private

  def revision
    File.read(File.join(Rails.root, 'REVISION'))
  rescue Errno::ENOENT
    DEFAULT_REVISION
  end
end
