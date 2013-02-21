class TitleCaseForPayloadLogEntries < ActiveRecord::Migration
  class PayloadLogEntry < ActiveRecord::Base; end

  def up
    PayloadLogEntry.where(method: "polling").update_all(method: "Polling")
    PayloadLogEntry.where(method: "webhooks").update_all(method: "Webhooks")
  end

  def down
    PayloadLogEntry.where(method: "Polling").update_all(method: "polling")
    PayloadLogEntry.where(method: "Webhooks").update_all(method: "webhooks")
  end
end
