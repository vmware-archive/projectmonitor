class TitleCaseForPayloadLogEntries < ActiveRecord::Migration
  class PayloadLogEntry < ActiveRecord::Base; end

  def up
    PayloadLogEntry.where(update_method: "polling").update_all(update_method: "Polling")
    PayloadLogEntry.where(update_method: "webhooks").update_all(update_method: "Webhooks")
  end

  def down
    PayloadLogEntry.where(update_method: "Polling").update_all(update_method: "polling")
    PayloadLogEntry.where(update_method: "Webhooks").update_all(update_method: "webhooks")
  end
end
