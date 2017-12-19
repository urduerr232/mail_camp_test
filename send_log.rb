require 'sendgrid-ruby'
include SendGrid
require 'json'
require 'rest-client'

LOGFILE = IO.sysopen("/var/log/motiond/image-rec.log", "a")
LOGOUT = IO.new(LOGFILE, "a")

def extract_latest()
  begin
    data = RestClient.get("localhost:5210/motiond/latest")
  rescue => e
    LOGFILE.puts "Could not reach log source -- please check connection/process on server."
  end
  data
end

def send_logs(to_addr)
  data = extract_latest()

  from = Email.new(email: 'no-reply@ir-motion.com')
  subject = '#{Time.new} - IR Matrices'
  to = Email.new(email: '260124-motion@gmail.com')
  mail = Mail.new(from, subject, to)

  mail.template_id = '18h8a01z-pgd9-m3js-l009-16d05dd6p6m0'
  personalization = Personalization.new
  personalization.add_substitution(Substitution.new(key: '%raw_telemetry%', value: data))

  sg = SendGrid::API.new(api_key: ENV['MAIL'], host: 'https://api.sendgrid.com')

  begin
    response = sg.client.mail._('mail').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  rescue => e
    LOGFILE.puts "Please check request body configuration."
  end
end
