class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@weareunicorn.org'
  layout 'mailer'
end
