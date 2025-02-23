require 'sendgrid-ruby'
class Esp32Controller < ApplicationController
  @@alert = false;
  include SendGrid
   skip_before_action :verify_authenticity_token
  def index
    if params[:gas_alert] == 'true'
      @@alert = true
    else
      @@alert = false
    end
  end


  def post_data
    data_arr = request.body.read.split('|')

    @humidity = data_arr[1]
    @temperature = data_arr[2]
    @gas = data_arr[3]

    ArduinoChannel.send_data(@humidity, @temperature, @gas)

    if @gas.to_i > 600 && @@alert == true
      puts "---------------------send mail-------------------------------------"
      send_email('phuonghao1705@gmail.com', @gas)
    end
    render json: {}, status: 200
  end

  def send_email(email, gas)
    from = Email.new(email: 'thesis@gmail.com')
    to = Email.new(email: email)

    subject = 'Gas level alarm.'
    content = Content.new(type: 'text/plain', value: "Warning!!! Gas level is #{gas}.")
    mail = Mail.new(from, subject, to, content)

    sg = SendGrid::API.new(api_key: sendgrid_api_key)
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end

  private

  def sendgrid_api_key
    return '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'
  end

end
