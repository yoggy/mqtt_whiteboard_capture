#!/usr/bin/ruby
#
#  mqtt_whiteboard_capture.rb
#
require 'mqtt'
require 'logger'
require 'fileutils'
require 'mail'
require 'yaml'
require 'ostruct'

$stdout.sync = true
Dir.chdir(File.dirname($0))

$conf = OpenStruct.new(YAML.load_file(File.dirname($0) + '/config.yaml'))

$log = Logger.new(STDOUT)
$log.level = Logger::DEBUG

$image_dir = File.dirname($0) + './images/'
FileUtils.mkdir_p($image_dir)

def capture_image(filename)
  cmd = "python ./capture_uvc.py #{$conf.capture_resolution} #{filename} >/dev/null 2>&1"
  $log.debug "capture_image cmd=" + cmd
  system(cmd)
end

def send_mail(f, path)
  mail = Mail.new do
    from    $conf.gmail_username
    to      $conf.evernote_mail
    subject "#{f} @" + $conf.evernote_notebook_name
    body    "this image was uploaded by mqtt_whiteboard_capture.rb ."
    add_file path
  end

  mail.delivery_method(:smtp,{
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => "smtp.gmail.com",
    :user_name            => $conf.gmail_username,
    :password             => $conf.gmail_password,
    :authentication       => :plain,
    :enable_starttls_auto => true
  })

  mail.deliver
end

def main
  conn_opts = {
    remote_host: $conf.mqtt_host,
    remote_port: $conf.mqtt_port,
    username:    $conf.mqtt_username,
    password:    $conf.mqtt_password,
  }
  $log.info "connecting..."
  MQTT::Client.connect(conn_opts) do |c|
    $log.info "connected"
    $log.info "subscribe topic=" + $conf.mqtt_topic
    c.get($conf.mqtt_topic) do |t, msg|
      t = Time.now
      $log.info "received message : msg=" + msg
      filename = $image_dir + "whiteboard-" + t.strftime("%Y%m%d-%H%M%S") + ".jpg"
      $log.info "capture image. filename=" + filename
      capture_image(filename)
      subject = "white board " + t.strftime("%Y/%m/%d %H:%M:%S")
      $log.info "start send_mail..." + filename
      send_mail(subject, filename)
      $log.info "finish send_mail!" + filename
    end
  end
end

if __FILE__ == $0
  loop do
    begin
      main
      sleep 1
    rescue Exception => e
      exit(0) if e.class.to_s == "Interrupt"
      $log.error e
      $log.info "reconnect after 5 second..."
      sleep 5
    end
  end
end
