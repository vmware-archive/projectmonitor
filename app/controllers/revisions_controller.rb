class RevisionsController < ApplicationController
  DEFAULT_REVISION = '1'
  REVISION_PATH    = File.join(Rails.root, 'REVISION')

  def show
    render :text => revision
  end

  private

  def revision
    File.read(REVISION_PATH)
  rescue Errno::ENOENT
    DEFAULT_REVISION
  end
end
