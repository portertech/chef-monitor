#!/usr/bin/env ruby
#
# Check HTTP
# ===
#
# Takes either a URL or a combination of host/path/port/ssl, and checks for
# a 200 response (that matches a pattern, if given). Can use client certs.
#
# Copyright 2011 Sonian, Inc <chefs@sonian.net>
# Updated by Lewis Preson 2012 to accept basic auth credentials
# Updated by SweetSpot 2012 to require specified redirect
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'net/http'
require 'net/https'

class CheckHTTP < Sensu::Plugin::Check::CLI

  option :url, 
    :short => '-u URL',
    :long => '--url URL',
    :description => 'A URL to connect to'
    
  option :host, 
    :short => '-h HOST',
    :long => '--hostname HOSTNAME',
    :description => 'A HOSTNAME to connect to'
    
  option :path,
    :short => '-p PATH',
    :long => '--path PATH',
    :description => 'Check a PATH'
    
  option :port, 
    :short => '-P PORT', 
    :long => '--port PORT',
    :proc => proc { |a| a.to_i },
    :description => 'Select another port',
    :default => 80
    
  option :header, 
    :short => '-H HEADER', 
    :long => '--header HEADER',
    :description => 'Check for a HEADER'
    
  option :ssl, 
    :short => '-s', 
    :boolean => true, 
    :description => 'Enabling SSL connections',
    :default => false
    
  option :insecure, 
    :short => '-k', 
    :boolean => true, 
    :description => 'Enabling insecure connections',
    :default => false
    
  option :user, 
    :short => '-U', 
    :long => '--username USER',
    :description => 'A username to connect as'
    
  option :password, 
    :short => '-a', 
    :long => '--password PASS',
    :description => 'A password to use for the username'
    
  option :cert, 
    :short => '-c FILE',
    :long => '--cert FILE',
    :description => 'Cert to use'

  option :cacert, 
    :short => '-C FILE',
    :long => '--cacert FILE',
    :description => 'A CA Cert to use'

  option :pattern, 
    :short => '-q PAT',
    :long => '--query PAT',
    :description => 'Query for a specific pattern'
    
  option :timeout, 
    :short => '-t SECS', 
    :long => '--timeout SECS',
    :proc => proc { |a| a.to_i }, 
    :description => 'Set the timeout',
    :default => 15
    
  option :redirectok, 
    :short => '-r', 
    :boolean => true,
    :description => 'Check if a redirect is ok',
    :default => false
    
  option :redirectto, 
    :short => '-R URL',
    :long => '--redirect-to URL',
    :description => 'Redirect to another page'

  def run
    if config[:url]
      uri = URI.parse(config[:url])
      config[:host] = uri.host
      config[:path] = uri.path
      config[:port] = uri.port
      config[:ssl] = uri.scheme == 'https'
    else
      unless config[:host] and config[:path]
        unknown 'No URL specified'
      end
      config[:port] ||= config[:ssl] ? 443 : 80
    end

    begin
      timeout(config[:timeout]) do
        get_resource
      end
    rescue Timeout::Error
      critical "Connection timed out"
    rescue => e
      critical "Connection error: #{e.message}"
    end
  end

  def get_resource
    http = Net::HTTP.new(config[:host], config[:port])

    if config[:ssl]
      http.use_ssl = true
      if config[:cert]
        cert_data = File.read(config[:cert])
        http.cert = OpenSSL::X509::Certificate.new(cert_data)
        http.key = OpenSSL::PKey::RSA.new(cert_data, nil)
      end
      if config[:cacert]
        http.ca_file = config[:cacert]
      end
      if config[:insecure]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    req = Net::HTTP::Get.new(config[:path])
    if (config[:user] != nil and config[:password] != nil)
      req.basic_auth config[:user], config[:password]
    end
    if config[:header]
      header, value = config[:header].split(':', 2)
      req[header] = value.strip
    end
    res = http.request(req)

    case res.code
      when /^2/
        if config[:redirectto]
          critical "expected redirect to #{config[:redirectto]} but got #{res.code}"
        elsif config[:pattern]
          if res.body =~ /#{config[:pattern]}/
            ok "#{res.code}, found /#{config[:pattern]}/ in #{res.body.size} bytes"
          else
            critical "#{res.code}, did not find /#{config[:pattern]}/ in #{res.body.size} bytes: #{res.body[0...200]}..."
          end
        else
          ok "#{res.code}, #{res.body.size} bytes"
        end
      when /^3/
        if config[:redirectok] || config[:redirectto]
          if config[:redirectok]
            ok "#{res.code}, #{res.body.size} bytes"
          elsif config[:redirectto]
            if config[:redirectto] == res['Location']
              ok "#{res.code} found redirect to #{res['Location']}"
            else
              critical "expected redirect to #{config[:redirectto]} instead redirected to #{res['Location']}"
            end
          end
        else
          warning res.code
        end
      when /^4/, /^5/
        critical res.code
      else
        warning res.code
      end
  end
end
