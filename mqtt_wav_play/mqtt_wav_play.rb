#!/usr/bin/ruby
require 'mqtt'
require 'logger'
require 'fileutils'
require 'yaml'
require 'ostruct'

$stdout.sync = true
Dir.chdir(File.dirname($0))

$conf = OpenStruct.new(YAML.load_file(File.dirname($0) + '/config.yaml'))

$log = Logger.new(STDOUT)
$log.level = Logger::DEBUG

def play_wav(msg)
  cmd = "aplay charp.wav"
  $log.info "play wav...cmd=" + cmd
  system(cmd)
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
      $log.info "received message : msg=" + msg
      play_wav(msg)
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

