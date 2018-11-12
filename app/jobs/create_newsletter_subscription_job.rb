# frozen_string_literal: true

class CreateNewsletterSubscriptionJob < ApplicationJob
  queue_as :default

  def perform(email)
    begin
      gibbon = Gibbon::Request.new(api_key: ENV["MAILCHIMP_API_KEY"])
      gibbon.lists(ENV["MAILCHIMP_NEWSLETTER_ID"]).members.create(body: { email_address: email, status: "subscribed" })
      CreateSlackNotificationJob.perform_later ":email: #{email} just signed up for the newsletter"
    rescue Gibbon::MailChimpError => ex
      CreateSlackNotificationJob.perform_later ":email: #{email} tried to sign up for the newsletter but is already signed up"
    end
  end
end
